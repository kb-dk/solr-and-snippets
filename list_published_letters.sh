#!/bin/sh
#
# List the letter XML documents that are ready for indexing, i.e. whose root
# <TEI> element carries a given status (default "published").
#
# The letters live under build/text-retriever/letters/<id>/<doc>.xml, each
# with a TEI root like:
#
#   <TEI xmlns="http://www.tei-c.org/ns/1.0" ... xml:id="root" status="published">
#
# Paths are emitted relative to build/text-retriever (e.g.
# "letters/000561541/000.xml"), matching the doc paths the indexers expect.
# Feed the output straight into run_local_indexing.sh (or the stage/prod/test
# variants), which take a file list as their first argument:
#
#   ./list_published_letters.sh > published_letters.text
#   ./run_local_indexing.sh published_letters.text
#
# Usage:
#   ./list_published_letters.sh                 # status="published" to stdout
#   STATUS=ready ./list_published_letters.sh    # pick a different status
#   ./list_published_letters.sh > files.text    # capture to a file

BUILD_SERVICE=${BUILD_SERVICE:-build/text-retriever}
LETTERS_DIR="$BUILD_SERVICE/letters"
STATUS=${STATUS:-published}

if [ ! -d "$LETTERS_DIR" ]; then
    echo "ERROR: $LETTERS_DIR not found (run from the repo root)" >&2
    exit 1
fi

count=0
# Only the root <TEI> element carries the document status, and it sits on a
# single line, so we test the first <TEI ...> line of each file.
find "$LETTERS_DIR" -name '*.xml' \
    ! -name capabilities.xml \
    ! -name toc.xml \
    | sort \
    | while IFS= read -r f; do
        tei_line=$(grep -m1 '<TEI[^>]*status=' "$f")
        case "$tei_line" in
            *status=\"$STATUS\"*)
                # Emit the path relative to $BUILD_SERVICE.
                echo "${f#"$BUILD_SERVICE"/}"
                count=$((count + 1))
                ;;
        esac
    done

# Note: $count above lives in the while subshell, so recount for the summary.
n=$(find "$LETTERS_DIR" -name '*.xml' ! -name capabilities.xml ! -name toc.xml \
    -exec grep -lm1 "<TEI[^>]*status=\"$STATUS\"" {} + 2>/dev/null | wc -l)
echo "Listed $n letter document(s) with status=\"$STATUS\"" >&2
