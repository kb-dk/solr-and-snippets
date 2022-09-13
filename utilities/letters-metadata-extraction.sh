#!/bin/bash

cd build/text-retriever

find . -name '0*.xml' -exec xsltproc --stringparam file {} ../../utilities/letters-metadata-extraction.xsl  {} \;
