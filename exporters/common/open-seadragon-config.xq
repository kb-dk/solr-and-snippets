xquery version "3.1" encoding "UTF-8";

import module namespace paths="http://kb.dk/this/paths" at "./get-paths.xqm";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace xdb="http://exist-db.org/xquery/xmldb";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace app="http://kb.dk/this/app";
declare namespace t="http://www.tei-c.org/ns/1.0";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace local="http://kb.dk/this/app";

declare variable  $mode     := request:get-parameter("mode","text");
declare variable  $path     := request:get-parameter("path","");

declare variable  $frag     := paths:frag($path);
declare variable  $c        := paths:c($path);
declare variable  $document := paths:document($path);
declare variable  $inferred_path := paths:inferred_path($path);

declare variable  $work_id  := request:get-parameter("work_id","");
declare variable  $o        := request:get-parameter("op","solrize");
declare variable  $status   := request:get-parameter("status","");

(: The posted content should actually live in a param with the same name :)
declare variable  $content  := util:base64-decode(request:get-data());

declare variable  $coll     := concat('/db/adl/',$c,'/');


declare option output:method "json";
declare option output:media-type "application/json";

declare function local:get-section-navigation(
  $frag as xs:string,
  $doc  as node() ) as map()*
{
   for $div in $doc//node()[@decls and (not($frag) or @xml:id=$frag)]
     let $page := if($frag) then 1
	else count($div/preceding::t:pb)
     let $bib_id := substring-after($div/@decls/string(),'#')
     return 
	for $bibl in //t:bibl[@xml:id=$bib_id]
	let $tit := $bibl/t:title/text()
        return 
	map {
	   "title":$tit,
	   "page":$page
        }
};

declare function local:get-section-pages(
  $frag as xs:string,
  $doc  as node() ) as xs:string*
{
	if($frag) then
          for $div in $doc//node()[@decls and @xml:id=$frag]
	    for $p in $div/preceding::t:pb[1] | $div//t:pb
	    return
                string-join(("http://kb-images.kb.dk/public",$p/@facs/string(),"info.json"),'/')
	else
	  for $p in $doc//t:pb
	  return  
             string-join(("http://kb-images.kb.dk/public",$p/@facs/string(),"info.json"),'/')
};

declare function local:get-pages(
  $frag as xs:string,
  $doc  as node() ) as xs:string*
{
	if($frag) then
          for $div in $doc//node()[@xml:id=$frag]
	    for $p in $div/preceding::t:pb[1] | $div/descendant::t:pb
	    return
                string-join(("http://kb-images.kb.dk/public",$p/@facs/string(),"info.json"),'/')
	else
	  for $p in $doc//t:pb
	  return  
          string-join(("http://kb-images.kb.dk/public",$p/@facs/string(),"info.json"),'/')
};

let $doc := doc(concat("./",$c,"/",$document))
let $osd := 
map {
	"id":"kbOSDInstance",
	"showNavigator":"true",
        "rtl":"false",
        "initialPage":1,
        "defaultZoomLevel":0,
        "sequenceMode":"true",
	"indexPage":array {
	local:get-section-navigation($frag,$doc) 
	}, 
	"tileSources":array{
	if($mode='text') then
          local:get-pages($frag,$doc)
	else
	  local:get-section-pages($frag,$doc)
        }
}

return $osd
