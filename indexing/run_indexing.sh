#!/bin/sh

if [ -f "$1" ]; then
    FILES=$1
else
    FILES=files_to_be_indexed.text
fi

#
# Mind you. Make sure that the '\' are followed by a newline directly, not whitespace
#     

./indexing/solr_updater.pl \
    --file-list=$FILES \
    --param exist_host=bifrost-test-01\
    --param exist_port=8080 \
    --param service=adl \
    --param op=solrize \
    --param solr_host=index-test-01\
    --param solr_port=80 \
    --param collection=adl-core > adl-indexing.log &
