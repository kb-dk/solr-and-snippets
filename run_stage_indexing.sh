#!/bin/sh



if [ -f "$1" ]; then
    FILES=$1
else
    FILES=files_to_be_indexed.text
fi

#
# Mind you. Make sure that the '\' are followed by a newline directly, not whitespace
#     

#    --file-list=$FILES \
#    --delete-query=id:michs_01-workid59390 \
#    --delete-query='*:*' \
#    --delete-query='subcollection_ssi:pmm' \
#     --delete-query='volume_id_ssi:adl-holberg-*' \
#    --delete-query='subcollection_ssi:textclass_genre_ssim:"Journaler og papirer"' \
#    --delete-query='volume_id_ssi:sks-jj-txt-root' \
#    --delete-query='subcollection_ssi:letters' \
#

./indexing/solr_updater.pl \
    --file-list=$FILES \
    --param exist_host=xstorage-stage-01.kb.dk \
    --param exist_port=8080 \
    --param service=text-retriever \
    --param op=solrize \
    --param solr_host=index-stage-03.kb.dk \
    --param user=solradmin \
    --param passwd=admin123 \
    --param solr_port=8983 \
    --param collection=text-retriever-core 

