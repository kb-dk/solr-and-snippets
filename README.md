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

## Granularity, Identifiers and indices


All the texts that can be searched in using the API are in [Text Encoding Initiative, TEI for short, markup](http://www.tei-c.org/release/doc/tei-p5-doc/en/html/index.html).

* The text documents are basically [ordered hierarchies of overlapping
content objects](http://cds.library.brown.edu/resources/stg/monographs/ohco.html)

* In particular we can not easily **simultaneously** 
ascertain what content there is on a given page and see what
content there is in a paragraph starting on that page. However,
we can always know on what page a given chapter, paragraph or
whatever commences. That is a fundamental property of text.

* In text service the objects in the content hierarchy are 
  * A <kbd>work</kbd> is an entity someone has decided to annotate using metadata. It is hence the unit the search engine returns in the result set. The granularity is an editorial issue. The more <kbd>work</kbd>s there are in a <kbd>volume</kbd> the less text there is in each <kbd>works</kbd>, the higher the granularity.
  * The <kbd>leaf</kbd> is the smallest unit of the tree which can be identified and therefore retrievable and possible to index. The user interface gives for each <kbd>work</kbd> in a result set a list of <kbd>leaf</kbd>s that are relevant for the search. <kbd>leaf</kbd>s are possible to quote but they do usually not appear in table of contents.
  * The <kbd>trunk</kbd>s are contained in <kbd>work</kbd>s. They may contain other <kbd>trunk</kbd> nodes, or <kbd>work</kbd>s or <kbd>leaf</kbd>s. It is possible to address a <kbd>trunk</kbd> so it is possible to send a URI to someone and say: <q>Read chapter 5, it is so good!</q> They are indexed and searchable in principle. However, the user interface only support them in table of contents and quotation services.
  * A <kbd>volume</kbd> is what comes close to a physical book. It contains one or more <kbd>work</kbd>s. If a <kbd>volume</kbd> contains only one work, we refer to it as a <kbd>monograph</kbd>

* All text is indexed down to <kbd>leaf</kbd>, basically <q>paragraph</q>, level, which implies
  * Paragraph in prose: <kbd>&lt;p&gt; ... &lt;/p&gt;</kbd>
  * Speech in drama: <kbd>&lt;sp&gt; ... &lt;/sp&gt;</kbd>
  * Strophe in poetry: <kbd>&lt;lg&gt; ... &lt;/lg&gt;</kbd>

  The distinctions here between prose, drama and poetry is not based on philological analysis, rather, it is determined by what markup was used to represent the text. There are other leaf nodes, like table rows, list items etc.  <em>If the markup is made stringently, then this way of indexing will be stringent.</em>

* The same text may appear on multiple levels in the index, and hence be addressed as, for example, paragraph, chapter and volume. In particular, <kbd>work</kbd>s will contain all text from its <kbd>leaf</kbd> nodes.
          
* The index granularity differs between literary genres. For instance can poems and individual short stories or essays be treated as individual works, and a single volume contain hundreds of such items, whereas there are usually only one novel in a volume.
          
Note that this document does not define or describe all fields in the
index. The index is far too rich for that, but I believe that it
contains what it takes to use it. The thing I have left out is
basically more of the same.

Finally, all fields are not available for all editions, because the
heterogeneity of the data, or wishes from the projects contributing
data.


## How to install the Snippet Server and its Data

The installation is more or less automatic. It is using the eXist
servers REST API, so all data are sent to the server using PUT
requests.

The installation is taking place by copying the data into a build
directory in the source tree.

```
ant -p
```

show you the targets. The current ones are shown in the tables below.

The data used are stored on github. For example, the Archive for Danish Literature corpus is on

https://github.com/kb-dk/public-adl-text-sources

Many of the corpora used are in private repositories.

### Build and data preparation targets

| Ant command | Description | Depends |
|:------------|:------------|:--------|
| ant clean   | Delete ./build ||
| ant service | Creates ./build/system and ./build/text-retriever. Copies text-service index definition to system all scripts and transforms common for adl, gv and sks into the file system (basically the content of exporters/common) | clean |
| ant base_service | Adds functions specific for  adl, letters, tfs, gv, and sks | service |
| ant other_services | For installing pmm and lhv | service |
| ant add_letters | Adds scripts for Danmarks Breve | | 
| ant add_letter_data | Adds data for Danmarks Breve | | 
| ant add_grundtvig | Copies all gv data into the build area. A complicated task, since it creates an entirely new directory structure and forks external script | base_service |
| ant add_base_data | Copies  adl, tfs and sks  | base_service |
| ant add_other_data | Copies data for pmm and holberg |  other_services |
| ant&nbsp;upload&nbsp;-Dhostport=just.an.example.org:8080 | Installs the text-service backend on http://just.an.example.org:8080. Requires password for the user "admin" on that server | |

The upload function is implemented as a [perl script](#ingest-and-indexing-utilities) executed by ant. Requires perl
library libwww-perl, available as standard package for Linux or from CPAN.

### Example

To install a snippet server on a server with hostname and port number just.an.example.org:8080 use the
following to build and install in the database:

```
 ant service
 ant base_service
 ant add_base_data
 ant upload -Dhostport=just.an.example.org:8080

```

Your new snippet server will contain adl, tfs and sks. To set the permissions of all scripts in one go, "retrieve" the
following URI

```
 http://admin@just.an.example.org:8080/exist/rest/db/text-retriever/xchmod.xq

```

which obviously requires password for "admin" user on just.an.example.org:8080

I sets (at least on some eXist installations) the execute
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

<!-- xstorage-test-01.kb.dk:8080/text-retriever/ is our test snippet server -->
<!-- just.an.example.org doesn't exist -->

Most Snippet Server scripts support the following arguments

* doc -- the name of the document to be rendered or transformed
* c   -- if there are more sub-collections inside the data set, c is the name of the dirctory where doc is to be retrieved. Default is 'texts' for ADL, other are 'periods' and 'authors'
* op  -- is the operation to be performed upon the document doc. Possible op are
  * 'render' which implies that doc is transformed into HTML. http://xstorage-test-01.kb.dk:8080/exist/rest/db/text-retriever/present.xq?doc=texts/aakjaer01val.xml&op=render&c=adl
  * 'solrize' which returns a solr <add> ... </add> which is ready to be sent to SOLR. C.f., http://xstorage-test-01.kb.dk:8080/exist/rest/db/text-retriever/present.xq?doc=texts/aakjaer01val.xml&op=solrize&c=adl
  * 'facsimile' which returns a HTML document with images of the pages. Since we introduced OSD, it is only used for PDF generation. http://xstorage-test-01.kb.dk:8080/exist/rest/db/text-retriever/present.xq?doc=texts/aakjaer01val.xml&op=facsimile&c=adl
  * 'toc' returns a HTML table of contents http://xstorage-test-01.kb.dk:8080/exist/rest/db/text-retriever/present.xq?doc=texts/aakjaer01val.xml&op=toc&c=adl 
* id  -- the id of a part inside the doc which is to be treated. 
* q -- assuming that 'q' is the query, the present.xq is labelling the hits in the text

Some more examples

* Holberg, vol 3, HTML: http://xstorage-test-01.kb.dk:8080/exist/rest/db/text-retriever/present.xq?doc=texts/holb03val.xml&op=render&c=adl
* Heiberg P.A., _Rigsdalers-Sedlens Hændelser_, Andet Kapitel. Detagged (pure text): http://xstorage-test-01.kb.dk:8080/exist/rest/db/text-retriever/present-text.xq?doc=texts/heibergpa01val.xml&id=idm140167182652400&c=adl

* Den politiske Kandstøber, Actus II http://xstorage-test-01.kb.dk:8080/exist/rest/db/text-retriever/present.xq?doc=texts/holb03val.xml&op=render&id=idm140583366846000&c=adl
* A single 'speak' in that play, 
  * as HTML http://xstorage-test-01.kb.dk:8080/exist/rest/db/text-retriever/present.xq?doc=texts/holb03val.xml&op=render&id=idm140583366681648&c=adl
  * or as SOLR doc http://xstorage-test-01.kb.dk:8080/exist/rest/db/text-retriever/present.xq?doc=texts/holb03val.xml&op=solrize&id=idm140583366681648&c=adl
* A TOC for a small work http://xstorage-test-01.kb.dk:8080/exist/rest/db/text-retriever/present.xq?doc=texts/aakjaer01val.xml&op=toc&id=workid59384&c=adl


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
