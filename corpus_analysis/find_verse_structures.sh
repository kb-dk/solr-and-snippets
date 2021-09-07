#!/bin/bash

SAXON="java -jar  /home/slu/saxon/saxon9he.jar"

HERE="/home/slu/projects/solr-and-snippets/corpus_analysis"

XSL="$HERE/verse_structure.xsl"

$SAXON -xsl:"$XSL" -s:sonnet_candidates.xml | xmllint --format -
