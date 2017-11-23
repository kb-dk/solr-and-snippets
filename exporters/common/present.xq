xquery version "3.0" encoding "UTF-8";


import module namespace lbl="http://kb.dk/this/lbl" at "./label-hits.xqm";

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

declare variable  $frag     := 
                  if($path) then
                    let $lfrag := replace($path,"(^[^-]*)-(.*)-([^-]*)-([^-]*$)","$4","mi")
                    return if ($lfrag = "root") then $lfrag else substring-after($lfrag,"shoot-")
                  else
                    request:get-parameter("id","root");

declare variable  $c        := 
                  if($path) then
                    replace($path,"(^[^-]*)-(.*)-([^-]*)-([^-]*$)","$1","mi")
                  else
                    request:get-parameter("c","adl");

declare variable  $document := 
                  if($path) then
                    let $d := replace($path,"(^[^-]*)-(.*)-([^-]*)-([^-]*$)","$2/$3","mi")
                    return concat(replace($d,"-","/"),".xml")
                  else
                    request:get-parameter("doc","");

declare variable $inferred_path :=  if($path) then $path else replace(concat($c,'-',substring-before($document,'.xml'),'-',$frag),'/','-');


declare variable  $o        := request:get-parameter("op","render");
declare variable  $coll     := concat("/db/text-retriever/",$c);
declare variable  $op       := doc(concat($coll,"/", $o, ".xsl"));
declare variable  $au_url   := concat($c,'/',$document);
declare variable  $q        := request:get-parameter('q','');
declare variable  $targetOp := request:get-parameter('targetOp','');

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

(: I cannot extract a fragment from the database both here and in the transform
 used for rendering. I leave the code below, though, as an aid for memory :)

(:let $list := 
for $doc in collection($coll)
where contains($document,util:document-name($doc))
return $doc:)

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
   <param name="auid used" value="{$auid}"/>
   <param name="au url"    value="{$au_url}"/>
   <param name="perioid"   value="{$period_id}"/>
   <param name="targetOp"  value="{$targetOp}"/>
   <param name="style"     value="{concat($coll,"/", $o, ".xsl")}"/>
   <param name="crearel"   value="{concat($coll,"/","creator-relations.xml")}"/>
</parameters>

(:return $params:)


let $hdoc := transform:transform($doc,$op,$params)
return if(request:get-parameter('q','')) then lbl:label-hits($hdoc) else $hdoc
