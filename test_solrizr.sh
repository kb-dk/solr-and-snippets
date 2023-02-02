#!/bin/bash

#ant base_service

SAXON="java -jar  /home/slu/saxon/saxon9he.jar"

FILE1=/home/slu/projects/GV/shared/registre/pers.xml
FILE2=/home/slu/projects/GV/shared/registre/place.xml
PARAMS=" per_reg=$FILE1 pla_reg=$FILE2 "

declare -A specimen

specimen[jura]="build/text-retriever/jura/texts/g02.xml"
specimen[adl]="../public-adl-text-sources/texts/richardt03.xml"
specimen[sks]="../SKS_tei/data/v1.9/ee1/txt.xml"
specimen[tfs]="../trykkefrihedsskrifter/tei_dir/1_013.xml"
#specimen[gv]="build_gv_added/text-retriever/gv/1817_306_12/txt.xml"
specimen[gv]="build_gv_added/text-retriever/gv/1840_668/txt.xml"
#specimen[gv]="build_gv_added/text-retriever/gv/1815_255/txt.xml"
#specimen[gv]="build_gv_added/text-retriever/gv/1837_575/intro.xml"
specimen[letters]="../letter-corpus/letter_books/001541111/001541111_000.xml"
speciment[lhv]="../other_tei_projects/holberg/jeppe/jeppe.xml"

ed=jura
echo $PARAMS
$SAXON -xsl:"build/text-retriever/$ed/solrize.xsl" -s:"${specimen[$ed]}" $PARAMS | xmllint --format  - 
exit()


for t in "${!specimen[@]}"
do
    echo "$t":

    $SAXON -xsl:"build/text-retriever/$t/solrize.xsl" -s:"${specimen[$t]}" | xmllint --format  - | tail -8

done

