#!/bin/bash

ant clean; ant service

SAXON=saxonb-xslt

declare -A specimen

specimen[adl]="../public-adl-text-sources/texts/richardt03.xml"
specimen[sks]="../SKS_tei/data/v1.9/ee1/txt.xml"
specimen[grundtvig]="../other_tei_projects/grundtvig/1816_297/txt.xml"
specimen[holberg]="../other_tei_projects/holberg/niels_klim/niels_klim.xml"
specimen[pmm]="../other_tei_projects/pmm/txt006.xml"
specimen[abbyy]="../OCR_TEI/abbyy/txt.xml"

for t in "${!specimen[@]}"
do
    echo "$t":
    $SAXON -xsl:"build/text-retriever/$t/solrize.xsl" -s:"${specimen[$t]}" | xmllint - | tail -8
    $SAXON -xsl:"build/text-retriever/$t/toc.xsl" -s:"${specimen[$t]}" | xmllint - | tail -8
done

