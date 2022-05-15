#!/bin/bash

###
#
# Sample script to export all languages
#
# Usage: bash export.sh http://directus http://hookserver
#
# Example: bash export.sh http://localhost:8055 http://localhost:4111
#
###
export $(cat .env | xargs);

curl -s "$1/fields/i18n?access_token=${DIRECTUS_TOKEN}" | jq -r '.data[].field'  | grep -v 'key\|user_\|context\|completion\|category\|autotranslate\|divider\|date_' | while read l; do
   echo "# $l"
   curl -s $2/export/$l;
done
