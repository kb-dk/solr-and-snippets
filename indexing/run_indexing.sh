

indexing/solr_updater.pl \
    --file-list=files_no_facs_to_be_indexed.text \
    --param exist_host=localhost \
    --param exist_port=8080 \
    --param service=adl \
    --param op=solrize \
    --param solr_host=localhost \
    --param solr_port=8983 \
    --param collection=adl
