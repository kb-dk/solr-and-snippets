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
#    --delete-query='volume_id_ssi:sks-kk-ekom-*' \
#  --delete-query='subcollection_ssi:gv' \
#  --delete-query='subcollection_ssi:tfs' \
#  --delete-query='subcollection_ssi:letters' \
#  --delete-query='volume_id_ssi:tfs-texts-2_003-root' \
#  --delete-query='subcollection_ssi:sks' \
#  --delete-query='subcollection_ssi:jura' \
#  --delete-query='volume_id_ssi:letters-002207661-007-root' \
#  

./indexing/solr_updater.pl \
    --file-list=$FILES \
    --param exist_host=xstorage-test-01.kb.dk \
    --param exist_port=8080 \
    --param service=text-retriever \
    --param op=solrize \
    --param solr_host=index-test-01.kb.dk \
    --param user=solradmin \
    --param passwd=admin123 \
    --param solr_port=8983 \
    --param collection=text-retriever-core 

