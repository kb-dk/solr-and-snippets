
# The TEI file store

## Introduction

This directory contains what is needed for storing and accessing  Lovforarbejder (jura) stuff in
an eXist DB 

## The stuff

* [solrize.xsl](./solrize.xsl) generates a SOLR add document making an
  index for text searching in text-service 
* [present.xq](./present.xq) is retrieving
  piece of XML from the store given the name of the file and the xml:id of the
  fragment. Call it like this
  http://example.org/dir/adl/present.xq?doc=file.xml&id=xml-frag-id It is
  taken for granted that all files live in /dir/adl/texts 
* [render.xsl](./render.xsl) is an xslt script creating an html fragment out
  of the TEI upon delivery.
* [collection.xconf](../index/collection.xconf) is the [definition of the index in eXist DB](http://exist-db.org/exist/apps/doc/indexing.xml) for the store.

Further info at [diswiki](http://diswiki.kb.dk/w/index.php/ADL_Udvikling#File_.2F_Fragment_.2F_TOC_server_and_HTML)

