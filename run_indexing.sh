EXIST_HOST=${EXIST_HOST:-localhost}
EXIST_PORT=${EXIST_PORT:-8080}
EXIST_USER=${EXIST_USER:-admin}
EXIST_PASSWD=${EXIST_PASSWD:-}
SOLR_HOST=${SOLR_HOST:-localhost}
SOLR_PORT=${SOLR_PORT:-8983}
SOLR_COLLECTION=${SOLR_COLLECTION:-text-retriever-core}

FILES=$1

./indexing/solr_updater.pl \
    --file-list="$FILES" \
    --param exist_host="$EXIST_HOST" \
    --param exist_port="$EXIST_PORT" \
    --param exist_user="$EXIST_USER" \
    --param exist_passwd="$EXIST_PASSWD" \
    --param service=text-retriever \
    --param op=solrize \
    --param solr_host="$SOLR_HOST" \
    --param solr_port="$SOLR_PORT" \
    --param collection="$SOLR_COLLECTION"

# Build the suggester FST once, now that the whole corpus is indexed.
# (buildOnCommit is off in solrconfig.xml so the load itself doesn't OOM
# rebuilding the in-RAM FST on every commit.)
echo "Building suggester dictionary..." >&2
curl -sf "http://$SOLR_HOST:$SOLR_PORT/solr/$SOLR_COLLECTION/suggest?suggest.build=true&wt=json" >/dev/null \
    && echo "Suggester built." >&2 \
    || echo "WARNING: suggester build failed" >&2
