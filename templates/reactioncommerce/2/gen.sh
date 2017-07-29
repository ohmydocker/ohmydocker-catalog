#!/bin/bash
TMP=$(mktemp -d --suffix=DOCKERTMP)
cat docker-compose.yml.tpl \
  |sed 's/\${\(REACTION_DOMAIN\)}/{{.\1}}/g' \
  |sed 's/\${\(REACTION_HOST\)}/{{.\1}}/g' \
  |sed 's/\${\(.*\)}/{{.\1}}/g' \
  > $TMP/inter.tpl
echo ' '
#cat $TMP/inter.tpl
#vim $TMP/inter.tpl
gotpl $TMP/inter.tpl < local.yml
rm $TMP/inter.tpl
rmdir $TMP
