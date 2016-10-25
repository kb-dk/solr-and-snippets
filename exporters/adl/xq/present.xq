xquery version "3.0" encoding "UTF-8";

declare namespace local="http://kb.dk/this/app";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace app="http://kb.dk/this/app";
declare namespace t="http://www.tei-c.org/ns/1.0";
declare namespace ft="http://exist-db.org/xquery/lucene";

declare variable  $document := request:get-parameter("doc","");
declare variable  $frag     := request:get-parameter("id","");
declare variable  $c        := request:get-parameter("c","texts");
declare variable  $o        := request:get-parameter("op","render");
declare variable  $coll     := concat("/db/adl/",$c);
declare variable  $op       := doc(concat("/db/adl/", $o,".xsl"));
declare variable  $au_url   := concat($c,'/',$document);
declare variable  $q        := request:get-parameter('q','');

declare option exist:serialize "method=xml encoding=UTF-8 media-type=text/html";

declare function local:label-hits( $doc  as node() ) as node()* {
	let $p := 
	<parameters>
	<param name="q"  value="{request:get-parameter('q','')}"/>
	</parameters>

	return transform:transform($doc,doc("/db/adl/label-hits.xsl"),$p) 
};


(: I cannot extract a fragment from the database both here and in the transform
 used for rendering. I leave the code below, though, as an aid for memory :)

let $list := 
 (: if($frag and not($o = "facsimile")) then
    for $doc in collection($coll)//node()[ft:query(@xml:id,$frag)]
    where util:document-name($doc)=$document
    return $doc
  else :)
    for $doc in collection($coll)
    where util:document-name($doc)=$document
    return $doc

let $author_id := doc('/db/adl/creator-relations.xml')//t:row[t:cell/t:ref = $au_url]/t:cell[@role='author']

let $auid := 
	if ($c = "texts") then
		let $id := substring-before($author_id,'.xml') 
		return $id
	else if ($c = "authors") then
		let $id := concat($c,'/',$document)
		return $id
	else ()

let $period_id :=
    if ($auid) then
	let $id := substring-before(substring-after(doc('/db/adl/author-and-period.xml')//t:row[contains(t:cell,$auid)]/t:cell[@role='period'],'/'),'.xml')
        return $id
    else ()

let $params := 
<parameters>
   <param name="hostname"  value="{request:get-header('HOST')}"/>
   <param name="doc"       value="{$document}"/>
   <param name="id"        value="{$frag}"/>
   <param name="c"         value="{$c}"/>
   <param name="coll"      value="{$coll}"/>
   <param name="auid"      value="{$author_id}"/>
   <param name="perioid"   value="{$period_id}"/>
</parameters>

for $doc in $list
let $hdoc := transform:transform($doc,$op,$params)
return if(request:get-parameter('q','')) then local:label-hits($hdoc) 
else $hdoc
