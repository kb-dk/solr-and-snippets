#!/bin/sh

#
# Mind you. Make sure that the '\' are followed by a newline directly, not whitespace
#

./indexing/solr_updater.pl \
    --file-list=last_files.text \
    --param exist_host=localhost \
    --param exist_port=8080 \
    --param service=adl \
    --param op=solrize \
    --param solr_host=localhost \
    --param solr_port=80 \
    --param collection=adl
