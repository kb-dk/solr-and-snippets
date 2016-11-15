# Solrs and Snippets 

All the software are variations upon a single theme. The theme can be
described as follows:

Assume that we have (semi)structured (meta)data in a database or
repository of some kind.  Then the snippet server is used for
performing various operations upon those data.

Examples of such operations are

* returning documents prepared for indexing
* pieces of texts for reading
* image URIs for viewing pages
* pieces of metadata for a detailed presentation 


We refer to the store as being the _Snippet Server_, the data inside
it as _data_ and the results returned from the operations as
_Snippets_. The word snippet comes from the fact that it is usually
just a part of a document returned.

Currently 

* the data is often in XML format
* the snippet server functionalities are written in XSLT or Xquery or both
* the snippets are returned in JSON, HTML or XML

The Snippet Server has to support CRUD basic functionalities. The
indexing is is currently SOLR and the snippet crud eXist

## The Snippet Server and its arguments

The scripts and transforms are in the directory exports. For ADL the following are
available

* open-seadragon-config.xq (web service providing JSON for OSD)
* present.xq (general purpose presentation script)

For letters we have in addition

* save.xq (updates the TEI header in the letter project. Data recieved in JSON). Returns a SOLR document in XML
* volume.xq (renders a table of content for a volume

Most the Snippet Server scripts support these arguments

* doc -- the name of the document to be rendered or transformed
* c   -- if there are more sub-collections inside the data set, c is the name of the dirctory where doc is to be retrieved. Default is 'texts' for ADL, other are 'periods' and 'authors'
* op  -- is the operation to be performed upon the document doc. Possible op are
  * 'render' which implies that doc is transformed into HTML. http://bifrost-test-01.kb.dk:8080/exist/rest/db/adl/present.xq?doc=aakjaer01val.xml&op=render
  * 'solrize' which returns a solr <add> ... </add> which is ready to be sent to SOLR. C.f., http://bifrost-test-01.kb.dk:8080/exist/rest/db/adl/present.xq?doc=aakjaer01val.xml&op=solrize
  * 'facsimile' which returns a HTML document with images of the pages. Since we introduced OSD, it is only used for PDF generation. http://bifrost-test-01.kb.dk:8080/exist/rest/db/adl/present.xq?doc=aakjaer01val.xml&op=facsimile
  * 'toc' returns a HTML table of contents http://bifrost-test-01.kb.dk:8080/exist/rest/db/adl/present.xq?doc=aakjaer01val.xml&op=toc* 
* id  -- the id of a part inside the doc which is to be treated. 

Some more examples

* Holberg, vol 3, HTML: http://bifrost-test-01.kb.dk:8080/exist/rest/db/adl/present.xq?doc=holb03val.xml&op=render
* Den politiske Kandstøber, Actus II http://bifrost-test-01.kb.dk:8080/exist/rest/db/adl/present.xq?doc=holb03val.xml&op=render&id=idm140583366846000
* A single 'speak' in that play, 
  * as HTML http://bifrost-test-01.kb.dk:8080/exist/rest/db/adl/present.xq?doc=holb03val.xml&op=render&id=idm140583366681648
  * or as SOLR doc http://bifrost-test-01.kb.dk:8080/exist/rest/db/adl/present.xq?doc=holb03val.xml&op=solrize&id=idm140583366681648
* A TOC for a small work http://bifrost-test-01.kb.dk:8080/exist/rest/db/adl/present.xq?doc=aakjaer01val.xml&op=toc&id=workid59384

## Minor utilities

* xslt transform all files with `--suffix xml` in the `--directory ./periods/` with a style `--sheet` preprocess.xsl 
```
indexing/transform-all.pl --sheet exporters/common/preprocess.xsl --directory ./periods/ --suffix xml
```
