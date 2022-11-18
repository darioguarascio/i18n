#!/usr/bin/python3

from mtranslate import translate
from flask import Flask
from flask import request
import sys, json, os, requests, yaml, re, binascii, dict2xml
from dotenv import load_dotenv


def build_job(file):

    def branch(tree, vector, value):

        # Originally based on https://stackoverflow.com/a/47276490/2903486

        # Convert Boolean
        if isinstance(value, str):
            value = value.strip()

            if value.lower() in ['true', 'false']:
                value = True if value.lower() == "true" else False

        # Convert JSON
        try:
            value = json.loads(value)
        except:
            pass

        key = vector[0]
        arr = re.search('\[([0-9]+)\]', key)

        if arr:

            # Get the index of the array, and remove it from the key name
            arr = arr.group(0)
            key = key.replace(arr,'')
            arr = int(arr.replace('[','').replace(']',''))

            if key not in tree:

                # If we dont have an array already, turn the dict from the previous
                # recursion into an array and append to it
                tree[key] = []
                tree[key].append(value \
                    if len(vector) == 1 \
                    else branch({} if key in tree else {},
                                vector[1:],
                                value))
            else:

                # Check to see if we are inside of an existing array here
                isInArray = False
                for i in range(len(tree[key])):
                    if tree[key][i].get(vector[1:][0], False):
                        isInArray = tree[key][i][vector[1:][0]]

                if isInArray and arr < len(tree[key]) \
                   and isinstance(tree[key][arr], list):
                    # Respond accordingly by appending or updating the value
                    tree[key][arr].append(value \
                        if len(vector) == 1 \
                        else branch(tree[key] if key in tree else {},
                                    vector[1:],
                                    value))
                else:
                    # Make sure we have an index to attach the requested array to
                    while arr >= len(tree[key]):
                        tree[key].append({})

                    # update the existing array with a dict
                    tree[key][arr].update(value \
                        if len(vector) == 1 \
                        else branch(tree[key][arr] if key in tree else {},
                                    vector[1:],
                                    value))

            # Turn comma deliminated values to lists
            if len(vector) == 1 and len(tree[key]) == 1:
                tree[key] = value.split(",")
        else:
          try:
            tree.update({key: value \
                if len(vector) == 1 \
                else branch(tree[key] if key in tree else {},
                            vector[1:],
                            value)})
          except:
           pass
        return tree

    rowObj = {}
    for colName in file:
        rowValue = file[colName]
        rowObj.update(branch(rowObj, colName.split("."), rowValue))
    return rowObj


app = Flask(__name__)


@app.route('/autotranslate',  methods = ['POST'])
def autotranslate():
    data = json.loads(request.data)
    directus = os.getenv('DIRECTUS_I18N').format(data['payload']['key'], os.getenv('DIRECTUS_TOKEN'))

    langs = { "autotranslate" : True }

    originText = data['payload']['en']
    translatable = originText
    mapping = {}

    for mtch in re.findall("\{\{.*?\}\}", originText):
        iid = "0x{}".format((binascii.b2a_hex(os.urandom(6)).decode('ascii')))
        mapping[iid] = mtch
        translatable = translatable.replace(mtch, iid)

    for target in os.getenv('AUTOTRANSLATE').split(','):
        try:
            try:
                r = requests.post(os.getenv('LIBRETRANSLATE_URL'), json={"q": translatable, "source":"en", "target": target })
                if r.status_code == 200:
                    translated = r.json()['translatedText']

                    for ee in mapping:
                        translated = translated.replace(ee, mapping[ee])

                    langs[target] = translated
                else:
                    raise Exception("Language {} not found".format(target))
            except:
                translated = translate(translatable, target,"en")
                for ee in mapping:
                    translated = translated.replace(ee, mapping[ee])

                langs[target] = translated
                pass

            print(langs, file=sys.stderr)


        except Exception as e:
            print('error', file=sys.stderr)
            print(target, file=sys.stderr)
            print(e, file=sys.stderr)
            pass

    requests.patch(directus, json=langs )

    return 'ok'


@app.route('/export-v2/<string:lang>',  methods=['GET'])
def detailed_export(lang):
    """
    Export all translations to a file
    :param lang: Language to export if ALL export all languages
    :return: File with translations
    """
    args = request.args
    category = args.get('category')
    file_format = args.get('format')
    limit = args.get('limit')
    offset = args.get('offset')

    base_url = os.getenv('DIRECTUS_I18N').format('', os.getenv('DIRECTUS_TOKEN'))

    directus = base_url.replace('/?', '?limit=-1&')

    # All option to return all translations:
    if lang == 'all':
        get_i18n_keys = requests.get(base_url.replace('items', 'fields'))
        languages = [x['field'] for x in get_i18n_keys.json()['data'] if len(x['field']) == 2]
        directus += f'&fields=key,{",".join(languages)}'

    else:
        directus += f'&fields=key,{lang}'

    if category:
        directus += f"&filter[category]={category}"

    r = requests.get(directus)
    file = {'data': []}
    if r.status_code == 200:
        if r.json()['data']:
            if lang != 'all':
                for row in r.json()['data']:
                    single_lang = {}
                    if lang in row:
                        if row[lang]:
                            single_lang[row['key']] = row[lang]
                            file['data'].append(single_lang)

            else:
                for row in r.json()['data']:
                    # Drop keys from row if null:
                    row = {k: v for k, v in row.items() if v is not None}
                    key_value = row.pop('key')
                    multi_lang = {}
                    if row:
                        multi_lang['key'] = key_value
                        multi_lang['translations'] = row
                        file['data'].append(multi_lang)

                if not limit:
                    limit = 2000

                if not offset:
                    offset = 0
                file['data'] = file['data'][int(offset):int(offset) + int(limit)]
                file['offset'] = int(offset)
                file['limit'] = int(limit)

            file['count'] = len(file['data'])
            if file['count'] == 0:
                return dict(error="No data found.")

        else:
            return dict(error="No data found.", status=r.status_code)

    else:
        # Return JSON error
        return dict(error="Error fetching data from Directus", status=r.status_code,
                    response=r.json())

    # Return Various formats:
    if file_format:
        if file_format == 'json':
            return json.dumps(build_job(file))
        elif file_format == 'yaml':
            return yaml.dump(build_job(file), default_flow_style=False)
        elif file_format == 'xml':
            return dict2xml.dict2xml(build_job(file))
        else:
            return 'Format not supported'

    else:
        return yaml.dump(build_job(file), default_flow_style=False)


@app.route('/export/<string:lang>')
def export(lang):
    directus = os.getenv('DIRECTUS_I18N').format('', os.getenv('DIRECTUS_TOKEN')).replace('/?','?limit=-1&fields=key,{}&'.format(lang))
    r = requests.get(directus)
    file = {}
    for e in r.json()['data']:
        if e[lang] is not None and e[lang] != '':
            file[ e['key'] ] = e[lang]
    #return json.dumps(file)
    return yaml.dump(build_job(file), default_flow_style=False)



if __name__ == "__main__":
    load_dotenv()
    app.run(port=80, host="0.0.0.0", debug=True)
