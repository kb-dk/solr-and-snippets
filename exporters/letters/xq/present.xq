xquery version "3.0" encoding "UTF-8";

import module namespace json="http://xqilla.sourceforge.net/lib/xqjson";
declare namespace xdb        = "http://exist-db.org/xquery/xmldb";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace app="http://kb.dk/this/app";
declare namespace t="http://www.tei-c.org/ns/1.0";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare variable  $document := request:get-parameter("doc","");
declare variable  $frag     := request:get-parameter("id","");
declare variable  $work_id  := request:get-parameter("work_id","");
declare variable  $c        := request:get-parameter("c","texts");
declare variable  $o        := request:get-parameter("op","render");
declare variable  $status   := request:get-parameter("status","");
declare variable  $app      := request:get-parameter("app","");
declare variable  $prefix   := request:get-parameter("prefix","");
declare variable  $coll     := concat($c,'/');
declare variable  $op       := doc(concat("/db/letter_books/", $o,".xsl"));
declare variable  $file     := substring-after(concat($coll,$document),"/db");
declare variable  $vol      := substring-before($file,".xml");

declare option exist:serialize "method=xml encoding=UTF-8 media-type=text/html";



let $list := 
    for $doc in collection("/db/letter_books")
    where util:document-name($doc)=$document
    return $doc

let $prev := 
  if($frag) then
    for $doc in collection($coll)//node()[@decls and ft:query(@xml:id,$frag)]
    where util:document-name($doc)=$document 
    return $doc/preceding::t:div[1]/@xml:id
  else
    ""

let $next := 
  if($frag) then
    for $doc in collection($coll)//node()[@decls and ft:query(@xml:id,$frag)]
    where util:document-name($doc)=$document
    return $doc/following::t:div[1]/@xml:id
  else
    ""

let $prev_encoded := 
  if($prev) then
    concat(replace(substring-before($file,'.xml'),'/','%2F'),'-',$prev)
  else
    ""
let $next_encoded := 
  if($next) then
    concat(replace(substring-before($file,'.xml'),'/','%2F'),'-',$next)
  else
    ""

let $params := 
<parameters>
  <param name="uri_base" value="http://{request:get-header('HOST')}"/>
  <param name="hostname" value="{request:get-header('HOST')}"/>
  <param name="doc"      value="{$document}"/>
  <param name="id"       value="{$frag}"/>
  <param name="prev"     value="{$prev}"/>
  <param name="prev_encoded"
                         value="{$prev_encoded}"/>
  <param name="next"     value="{$next}"/>
  <param name="next_encoded"
                         value="{$next_encoded}"/>
  <param name="work_id"  value="{$work_id}"/>

  <param name="c"        value="{$c}"/>
  <param name="coll"     value="{$coll}"/>
  <param name="file"     value="{$file}"/>
  <param name="volume_id" value="{$vol}"/>
  <param name="status"   value="{$status}"/>
  <param name="prefix"   value="{$prefix}"/>
  <param name="app"      value="{$app}" />
</parameters>

for $doc in $list[1]
  let $res := transform:transform($doc,$op,$params)
  return  
    if($o='json') then
      json:serialize-json($res)
    else
      $res


