xquery version "3.0" encoding "UTF-8";


import module namespace lbl="http://kb.dk/this/lbl" at "./label-hits.xqm";
import module namespace paths="http://kb.dk/this/paths" at "./get-paths.xqm";

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

declare variable  $path     := request:get-parameter("path","");

declare variable  $frag     := paths:frag($path);
declare variable  $c        := paths:c($path);
declare variable  $document := paths:document($path);
declare variable  $inferred_path := paths:inferred_path($path);

declare variable  $o        := request:get-parameter("op","render");
declare variable  $coll     := concat("/db/text-retriever/",$c);
declare variable  $op       := doc(concat($coll,"/", $o, ".xsl"));
declare variable  $au_url   := concat($c,'/',$document);
declare variable  $q        := request:get-parameter('q','');
declare variable  $targetOp := request:get-parameter('targetOp','');
declare variable  $hostport := request:get-parameter('hostport','');

declare option exist:serialize "method=xml encoding=UTF-8 media-type=text/html";

let $author_id := doc(concat($coll,"/","creator-relations.xml"))//t:row[t:cell/t:ref = $document]/t:cell[@role='author']

let $auid := 
  if (contains($document,"txt.xml") or contains($document,"texts")) then
     let $id := substring-before($author_id,'.xml') 
     return $id
  else if (contains($document,"authors")) then
     let $id := concat($coll,'/',$document)
     return $id
  else ()

let $period_id :=
    if ($auid) then
	let $id := substring-before(substring-after(doc(concat($coll,'/','author-and-period.xml'))//t:row[contains(t:cell,$auid)]/t:cell[@role='period'],'/'),'.xml')
        return $id
    else ()

let $doc := doc(concat("./",$c,"/",$document))

let $params := 
<parameters>
   <param name="hostname"  value="{request:get-header('HOST')}"/>
   <param name="path"      value="{$inferred_path}"/>
   <param name="doc"       value="{$document}"/>
   <param name="id"        value="{$frag}"/>
   <param name="c"         value="{$c}"/>
   <param name="coll"      value="{$coll}"/>
   <param name="auid"      value="{$author_id}"/>
   <param name="auid_used" value="{$auid}"/>
   <param name="au_url"    value="{$au_url}"/>
   <param name="perioid"   value="{$period_id}"/>
   <param name="targetOp"  value="{$targetOp}"/>
   <param name="style"     value="{concat($coll,"/", $o, ".xsl")}"/>
   <param name="crearel"   value="{concat($coll,"/","creator-relations.xml")}"/>
</parameters>

let $hdoc := transform:transform($doc,$op,$params)
return 
  if(request:get-parameter("debug","")) then
     <d>{$params,concat("./",$c,"/",$document),$hdoc}</d>  
  else
     if(request:get-parameter('q','')) then lbl:label-hits($hdoc) else $hdoc