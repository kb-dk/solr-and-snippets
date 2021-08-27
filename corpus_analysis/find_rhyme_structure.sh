#!/bin/bash

SAXON="java -jar  /home/slu/saxon/saxon9he.jar"
XMLID="workid75376"
THERE="/home/slu/projects/public-adl-text-sources"
FILE="$THERE/texts/aarestrup07val.xml"
XSL="./rhyme_structure.xsl"

$SAXON -xsl:"$XSL" -s:"$FILE" file_name="$FILE" work_id="$XMLID"
