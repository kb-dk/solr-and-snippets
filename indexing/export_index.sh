#!/bin/sh -u

base="http://www.kb.dk/cop/solrizr"
spotlight_exhibition="dvi"
syndication="http://www.kb.dk/cop/syndication"
solrizr="indexing/cop-subject-solrizr.xsl"
solr_baseurl="http://index-test-01.kb.dk/solr/exhibitions"

while read subject ; do
    uri=$syndication$subject
    echo "xsltproc --stringparam base $base --stringparam solr_baseurl $solr_baseurl --stringparam spotlight_exhibition $spotlight_exhibition  --stringparam uri $uri $solrizr $uri"
done

