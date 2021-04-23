#!/bin/bash

ant base_service

SAXON="java -jar  /home/slu/saxon/saxon9he.jar"

declare -A specimen

specimen[adl]="../public-adl-text-sources/texts/richardt03.xml"
specimen[sks]="../SKS_tei/data/v1.9/ee1/txt.xml"
specimen[tfs]="../trykkefrihedsskrifter/tei_dir/1_013.xml"
# specimen[gv]="build/text-retriever/gv/1817_306_12/txt.xml"
specimen[gv]="build/text-retriever/gv/1815_255/txt.xml"
specimen[letters]="../letter-corpus/letter_books/001541111/001541111_000.xml"

ed=letters

$SAXON -xsl:"build/text-retriever/$ed/solrize.xsl" -s:"${specimen[$ed]}" | xmllint --format  - 
exit()

for t in "${!specimen[@]}"
do
    echo "$t":
    $SAXON -xsl:"build/text-retriever/$t/solrize.xsl" -s:"${specimen[$t]}" | xmllint --format  - | tail -8

done

