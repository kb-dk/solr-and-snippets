#!/bin/sh
#
# Index the build tree (e.g. produced by `ant add_base_data`) into local Solr.
#
# The ant targets populate build/text-retriever with one or more editions
# (adl, sks, tfs, gv, lh, jura, letters, ...). This script lists every text
# document under that build tree, across all collections present (paths
# relative to build/text-retriever, which is also how they live in eXist
# under /db/text-retriever), and asks solr_updater.pl to solrize them.
#
# Usage:
#   ./run_local_indexing.sh                 # index all texts in the build
#   ./run_local_indexing.sh my_files.text   # index an explicit file list instead
#
# Note: the documents must already be uploaded to eXist (e.g. `ant upload`),
# since solr_updater.pl fetches the solrized form from eXist, not from disk.

BUILD_SERVICE=${BUILD_SERVICE:-build/text-retriever}

if [ -f "$1" ]; then
    FILES=$1
else
    FILES=$(mktemp)
    trap 'rm -f "$FILES"' EXIT

    # Index every text document in the build, across all collections.
    # We take all *.xml under $BUILD_SERVICE except the non-text files that
    # live alongside the texts and are never indexed:
    #   - edition-root config: creator-relations.xml, author-and-period.xml,
    #     missing_facs.xml
    #   - per-text generated artifacts: capabilities.xml, toc.xml
    # Paths are emitted relative to $BUILD_SERVICE, matching the doc paths
    # solr_updater.pl expects (and how they live under /db/text-retriever).
    find "$BUILD_SERVICE" -name '*.xml' \
        ! -name capabilities.xml \
        ! -name toc.xml \
        ! -name creator-relations.xml \
        ! -name author-and-period.xml \
        ! -name missing_facs.xml \
        | sed "s#^$BUILD_SERVICE/##" | sort > "$FILES"

    echo "Generated file list with $(wc -l < "$FILES") documents from $BUILD_SERVICE" >&2
fi

EXIST_HOST=${EXIST_HOST:-localhost}
EXIST_PORT=${EXIST_PORT:-8080}
EXIST_USER=${EXIST_USER:-admin}
EXIST_PASSWD=${EXIST_PASSWD:-}
SOLR_HOST=${SOLR_HOST:-localhost}
SOLR_PORT=${SOLR_PORT:-8983}
SOLR_COLLECTION=${SOLR_COLLECTION:-text-retriever-core}

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
