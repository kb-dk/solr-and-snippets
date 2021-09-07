#!/bin/bash

SAXON="java -jar  /home/slu/saxon/saxon9he.jar"

HERE="/home/slu/projects/solr-and-snippets/corpus_analysis"
THERE="/home/slu/projects/public-adl-text-sources/texts"

XSL="$HERE/sonnet_candidate.xsl"

(cd $THERE ; find . -name  "*.xml" -exec  $SAXON -xsl:"$XSL" -s:{}  file_name={} \; )
