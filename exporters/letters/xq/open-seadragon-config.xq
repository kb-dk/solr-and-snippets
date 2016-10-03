xquery version "3.0" encoding "UTF-8";

import module namespace json="http://xqilla.sourceforge.net/lib/xqjson";

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

declare variable  $mode     := request:get-parameter("mode","section");
declare variable  $document := request:get-parameter("doc","");
declare variable  $frag     := request:get-parameter("id","");
declare variable  $work_id  := request:get-parameter("work_id","");
declare variable  $c        := request:get-parameter("c","texts");
declare variable  $o        := request:get-parameter("op","solrize");
declare variable  $op       := doc(concat("/db/letter_books/", $o,".xsl"));
declare variable  $status   := request:get-parameter("status","");

(: The posted content should actually live in a param with the same name :)
declare variable  $content  := util:base64-decode(request:get-data());

declare variable  $coll     := concat($c,'/');
declare variable  $file     := substring-after(concat($coll,$document),"/db");

declare option    exist:serialize "method=text media-type=application/json";

declare function local:get-section-navigation(
  $frag as xs:string,
  $doc  as node() ) as node()*
{
   for $div in $doc//node()[@decls and (not($frag) or @xml:id=$frag)]
     let $page := if($frag) then 1
	else count($div/preceding::t:pb)

     let $bib_id := $div/@decls
     return 
	for $bibl in //t:bibl[@xml:id=$bib_id]
	let $tit := ("fra ",$bibl/t:respStmt[contains(t:resp,"sender")]/t:name//text(),
			   " til ",$bibl/t:respStmt[contains(t:resp,"recipient")]/t:name//text(),
			   " ",for $d in $bibl/t:date[string()] return concat("(",$d,")"))
               return 
	         <item type="object">
	            <pair type="string"  name="title">{$tit}</pair>
	            <pair type="integer"  name="page">{$page}</pair>
	         </item> 
};

declare function local:get-section-pages(
  $frag as xs:string,
  $doc  as node() ) as node()*
{
	if($frag) then
          for $div in $doc//node()[@decls and @xml:id=$frag]
	    for $p in $div/preceding::t:pb[1] | $div//t:pb
	    return
              <item type="string">
                {string-join(("http://kb-images.kb.dk/public/dk_breve/",substring-after(substring-before($p/@facs/string(),".jp"),"images/"),"info.json"),"/")}
	      </item>
	else
	  for $p in $doc//t:pb
	  return  
          <item type="string">
          {string-join(("http://kb-images.kb.dk/public/dk_breve/",substring-after(substring-before($p/@facs/string(),".jp"),"images/"),"info.json"),"/")}
	  </item>
};

declare function local:get-pages(
  $frag as xs:string,
  $doc  as node() ) as node()*
{
	if($frag) then
          for $div in $doc//node()[@xml:id=$frag]
	    for $p in $div/preceding::t:pb[1] | $div/descendant::t:pb
	    return
              <item type="string">
                {string-join(("http://kb-images.kb.dk/public/dk_breve/",substring-after(substring-before($p/@facs/string(),".jp"),"images/"),"info.json"),"/")}
	      </item>
	else
	  for $p in $doc//t:pb
	  return  
          <item type="string">
          {string-join(("http://kb-images.kb.dk/public/dk_breve/",substring-after(substring-before($p/@facs/string(),".jp"),"images/"),"info.json"),"/")}
	  </item>
};


let $docs := 
   for $doc in collection($coll)
   where util:document-name($doc)=$document
   return $doc

let $osd := 
for $doc in $docs[1]
return
<json type="object"> 
	<pair type="string"  name="id">kbOSDInstance</pair>	
	<pair type="boolean" name="showNavigator">true</pair>
        <pair type="boolean" name="rtl">false</pair>
        <pair type="integer" name="initialPage">1</pair>
        <pair type="integer" name="defaultZoomLevel">0</pair>
        <pair type="boolean" name="sequenceMode">true</pair>
	<pair name="indexPage" type="array">
	{
	local:get-section-navigation($frag,$doc)
	} 
	</pair>
	<pair name="tileSources" type="array">
	{
	if($mode='text') then
	  local:get-pages($frag,$doc)
	else
	  local:get-section-pages($frag,$doc)
        }
	</pair>
 </json>

return replace(replace(json:serialize-json($osd),"\\n"," "),"\\/","/")
