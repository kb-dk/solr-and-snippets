#!/bin/sh

#
# Mind you. Make sure that the '\' are followed by a newline directly, not whitespace
#

./indexing/solr_updater.pl \
    --file-list=files_to_be_indexed.text\
    --param exist_host=bifrost-test-01\
    --param exist_port=8080 \
    --param service=adl \
    --param op=solrize \
    --param solr_host=index-test-01\
    --param solr_port=80 \
    --param collection=adl-core > adl-indexing.log &
