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
declare variable  $status   := request:get-parameter("status","");

(: The posted content should actually live in a param with the same name :)
declare variable  $content  := util:base64-decode(request:get-data());

declare variable  $uri_scheme := "https";

declare variable  $missing  := "https://kb-images.kb.dk/public/sks/other/copyright/info.json";

declare option output:method "json";
declare option output:media-type "application/json";



declare function local:get-facs($pid as xs:string*,$doc as node() ) as xs:string*
{
   let $uri_path := 
	if($doc//t:graphic[@xml:id=$pid]/@url) then fn:replace($doc//t:graphic[@xml:id=$pid]/@url,"(^.*geService/)(.*)(.jpg)","$2")
	else if(contains($path,"tfs")) then  concat("/public/tekstportal/tfs/",$pid) (: because of caching problem :)
	else if(contains($path,"gv") ) then  concat("/public/tekstportal/gv/", $pid)

	else if(contains($path,"letters") ) then  concat("/public/dk_breve/", $pid)

  else concat("public/",$pid)
  return  string-join((concat($uri_scheme,"://kb-images.kb.dk"),$uri_path,"info.json"),'/')
};

declare function local:get-section-navigation(
  $frag as xs:string,
  $doc  as node() ) as map()*
{
   for $div in $doc//node()[@decls and (not($frag) or @xml:id=$frag)]
     let $page := if($frag) then 1
	 else count($div/preceding::t:pb)
     let $bib_id := substring-after($div/@decls/string(),'#')
     return 
	 for $bibl in $doc//t:bibl[@xml:id=$bib_id]
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

	    for $p in $div/preceding::t:pb[1][@facs] | $div//t:pb[@facs]
	    let $pid := $p/@facs/string()
	    return
	       let $uri_path := if($p/@rend = 'missing') then $missing else local:get-graphic-uri($pid,$doc)
               return  string-join((concat($uri_scheme,"://kb-images.kb.dk"),$uri_path,"info.json"),'/')
	else
	  for $p in $doc//t:pb[@facs]
	  let $pid := $p/@facs/string()
	  return  
             let $uri_path := if($p/@rend = 'missing') then $missing else local:get-graphic-uri($pid,$doc)
             return  string-join((concat($uri_scheme,"://kb-images.kb.dk"),$uri_path,"info.json"),'/')

};

declare function local:get-pages(
  $frag as xs:string,
  $doc  as node() ) as xs:string*
{
	if($frag) then
          for $div in $doc//node()[@xml:id=$frag]
	    for $p in $div/preceding::t:pb[1][@facs] | $div/descendant::t:pb[@facs]
	    let $pid := $p/@facs/string()
	    return
	      let $uri_path := if($p/@rend = 'missing') then $missing else local:get-graphic-uri($pid,$doc)
              return  string-join((concat($uri_scheme,"://kb-images.kb.dk"),$uri_path,"info.json"),'/')
  	else
	  for $p in $doc//t:pb[@facs]
	  let $pid := $p/@facs/string()
	  return 
 	    let $uri_path := if($p/@rend = 'missing') then $missing else local:get-graphic-uri($pid,$doc)
            return  string-join((concat($uri_scheme,"://kb-images.kb.dk"),$uri_path,"info.json"),'/')

};


declare function local:get-graphic-uri($pid as xs:string,$doc as node()) as xs:string*
{
	let $pth := 
	if(contains($path,"tfs")) then "public/tekstportal/tfs/"
	else if(contains($path,"letters")) then "public/dk_breve/"
	else if(contains($path,"gv")) then "public/tekstportal/gv/"
	else "public/"

	let $cleaner := fn:replace ($pid,".jpg","")
	let $year    := substring-before($cleaner,"_")

	let $letterpid := concat($pth,fn:replace ($cleaner,"images/",""))
	let $gvpid   := concat($pth,$year,"/",$year,"GV/",fn:replace ($pid,"_fax.*$",""),"/", fn:replace ($cleaner,"_fax.*$","_tif_side/"),$cleaner)
(:
https://kb-images.kb.dk/public/tekstportal/gv/1810/1810GV/1810_148A/1810_148A_tif_side/info.json
https://kb-images.kb.dk/public/tekstportal/gv/1810/1810GV/1810_148A/1810_148A_tif_side/1810_148A_fax200/info.json 
:)
	return
	  if(contains($path,"gv")) then $gvpid
		else if(contains($path,"letters")) then $letterpid
		else if($doc//t:graphic[@xml:id=fn:replace($pid,"#","")]/@url/string()) then
				let $graphic := $doc//t:graphic[@xml:id=fn:replace($pid,"#","")]/@url/string()
				return 
	        if(contains($graphic,"geService/")) then
	          fn:replace($graphic,"(^.*geService/)(.*)(.jpg)","$2")
					else
	          fn:replace($graphic,"(^.*src=)(.*)(.tif.*$)","$2")
      else 
	      concat($pth,fn:replace($pid,"#",""))
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
