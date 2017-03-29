#!/bin/sh -u

base="http://localhost/cop/syndication"
spotlight_exhibition="dddddvi"
syndication="http://www.kb.dk/cop/syndication"
solrizr="indexing/cop-subject-solrizr.xsl"
solr_baseurl="http://spotlight-test-01.kb.dk:8983/solr/cop-editions"

while read subject ; do
    uri=$syndication$subject
    echo "xsltproc --stringparam base $base --stringparam solr_baseurl $solr_baseurl --stringparam spotlight_exhibition $spotlight_exhibition  --stringparam uri $uri $solrizr $uri"
done

