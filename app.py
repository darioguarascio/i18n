#!/usr/bin/python3

from flask import Flask
from flask import request
import sys, json, os, requests, yaml


import json, re, yaml
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
            # Add dictionaries together
            tree.update({key: value \
                if len(vector) == 1 \
                else branch(tree[key] if key in tree else {},
                            vector[1:],
                            value)})
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
    for target in os.getenv('AUTOTRANSLATE').split(','):
        r = requests.post(os.getenv('LIBRETRANSLATE_URL'), json={"q": data['payload']['en'], "source":"en", "target": target })
        if r.status_code == 200:
            langs[target] = r.json()['translatedText']

    print(langs, file=sys.stderr)
    requests.patch(directus, json=langs )

    return 'ok'

@app.route('/export/<string:lang>')
def export(lang):
    directus = os.getenv('DIRECTUS_I18N').format('', os.getenv('DIRECTUS_TOKEN')).replace('/?','?limit=-1&fields=key,{}&'.format(lang))
    r = requests.get(directus)
    file = {}
    for e in r.json()['data']:
        file[ e['key'] ] = e[lang]

    return yaml.dump(build_job(file), default_flow_style=False)




if __name__ == "__main__":
    app.run(port=80, host="0.0.0.0", debug=True)


