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

* all the data is in XML format
* the snippet server functionalities are written in XSLT or Xquery or both
* the snippets are returned in JSON, HTML or XML

The Snippet Server has to support CRUD basic functionalities. The
indexing is is currently SOLR and the snippet crud eXist

## How to install the Snippet Server and its Data

The installation is more or less automatic. It is using the eXist
servers REST API, so all data are sent to the server using PUT
requests.

The installation is taking place by copying the data into a build
directory in the source tree.

```
ant -p
```

show you the targets. The current ones are shown in the table below.

| Ant command | Description |
|:------------|:------------|
| ant clean   | Delete ./build |
| ant service | Creates ./build/system and ./build/text-retriever. Copies text-service index definition to system all scripts and transforms common for ADL, GV and SKS into the file system |

* add_data
* add_letters
* add_letter_data

All the data is on github and can be cloned from there. For example:
To install the text-service backend on http://just.an.example.org:8080

```
 ant clean
 ant service
 ant add_data
 ant upload -Dhostport=just.an.example.org:8080

```

To set the permissions of all scripts in one go, "retrieve" the
following URI

```
 http://just.an.example.org:8080/exist/rest/db/text-retriever/xchmod.xq

```

which (at least on some eXist installations) sets the execute
permissions on all *.xq files. It doesn't work always, and as of
writing this, it is not yet known when and where it works. Then you
have to do that manually according to the eXist manual. See your server

```
http://just.an.example.org:8080/exist/apps/dashboard/index.html

```

## The Snippet Server and its arguments

The scripts and transforms are in the directory exports. For ADL the following are
available

* open-seadragon-config.xq (web service providing JSON for OSD)
* present.xq (general purpose presentation script)
* present-text.xq (a detagger, it extracts raw text from the file)

For letters we have in addition

* save.xq (updates the TEI header in the letter project. Data recieved in JSON). Returns a SOLR document in XML
* volume.xq (renders a table of content for a volume

Most Snippet Server scripts support the following arguments

* doc -- the name of the document to be rendered or transformed
* c   -- if there are more sub-collections inside the data set, c is the name of the dirctory where doc is to be retrieved. Default is 'texts' for ADL, other are 'periods' and 'authors'
* op  -- is the operation to be performed upon the document doc. Possible op are
  * 'render' which implies that doc is transformed into HTML. http://labs.kb.dk/storage/adl/present.xq?doc=aakjaer01val.xml&op=render
  * 'solrize' which returns a solr <add> ... </add> which is ready to be sent to SOLR. C.f., http://labs.kb.dk/storage/adl/present.xq?doc=aakjaer01val.xml&op=solrize
  * 'facsimile' which returns a HTML document with images of the pages. Since we introduced OSD, it is only used for PDF generation. http://labs.kb.dk/storage/adl/present.xq?doc=aakjaer01val.xml&op=facsimile
  * 'toc' returns a HTML table of contents http://labs.kb.dk/storage/adl/present.xq?doc=aakjaer01val.xml&op=toc 
* id  -- the id of a part inside the doc which is to be treated. 
* q -- assuming that 'q' is the query, the present.xq is labelling the hits in the text

Some more examples

* Holberg, vol 3, HTML: http://labs.kb.dk/storage/adl/present.xq?doc=holb03val.xml&op=render
* Heiberg P.A., _Rigsdalers-Sedlens Hændelser_, Andet Kapitel. Detagged (pure text): http://labs.kb.dk/storage/adl/present-text.xq?doc=heibergpa01val.xml&id=idm140167182652400

* Den politiske Kandstøber, Actus II http://labs.kb.dk/storage/adl/present.xq?doc=holb03val.xml&op=render&id=idm140583366846000
* A single 'speak' in that play, 
  * as HTML http://labs.kb.dk/storage/adl/present.xq?doc=holb03val.xml&op=render&id=idm140583366681648
  * or as SOLR doc http://labs.kb.dk/storage/adl/present.xq?doc=holb03val.xml&op=solrize&id=idm140583366681648
* A TOC for a small work http://labs.kb.dk/storage/adl/present.xq?doc=aakjaer01val.xml&op=toc&id=workid59384


## Ingest and Indexing utilities

These utilities require the presence a local file system with stuff to be loaded.

### Storing to exist


```
./indexing/exist_loader.pl <options>
where options are
   --load <directory> 
        from where to read files for loading
   --get <directory>
        where to write retrieved files
   --delete <directory with a backup>
        the files in that are found in the directory will be deleted from the
        database if there exist files with the same name

    --suffix <suffix> 
        file suffix to look for in directory. for example xml

    --target <target name>
        Basically database name. Default is 

    --context <context>
        Root for the rest services. Default is /exist/rest/db/

    --user <user name>
    --password <password of user>
    --host-port <host and port for server>
        Default is localhost:8080

For example

exist_loader.pl --file-list files_to_be_indexed.text \
		--user admin \
		--password secret \
		--host-port localhost:8080  \
		--context /exist/rest/db/adl/

will load the xml-files named in files_to_be_indexed.text into a database with base URI

http://localhost:8080/exist/rest/db/adl/
 
```

### Running solrizr and loading solr docs into cloud

```
indexing/solr_updater.pl \
    --file-list=files_to_be_indexed.text \
    --param exist_host=localhost \
    --param exist_port=8080 \
    --param service=adl \
    --param op=solrize \
    --param solr_host=localhost \
    --param solr_port=8983 \
    --param collection=adl

```

This software is dependent on the module URI::Template

```
sudo cpan -e install URI::Template

```

## Minor utilities

* xslt transform all files with `--suffix xml` in the `--directory ./periods/` with a style `--sheet` preprocess.xsl 
```
indexing/transform-all.pl --sheet exporters/common/preprocess.xsl --directory ./periods/ --suffix xml
```

* Validate bagit create or validate bagit manifests
  * create-bag.rb  
  * validate-bag.rb
