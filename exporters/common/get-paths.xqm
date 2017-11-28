xquery version "3.0" encoding "UTF-8";

module namespace paths="http://kb.dk/this/paths"

declare namespace request="http://exist-db.org/xquery/request";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare variable  $path     := request:get-parameter("path","");

declare function paths:frag() {
	return if($path) then
           if(contains($path,"-root")) then "" else substring-after($path,"shoot-")
        else
           request:get-parameter("id","root")
};

declare function paths:c() {
        return if($path) then
        replace($path,"(^[^-]*)-(.*)$","$1","mi")
        else
        request:get-parameter("c","adl")
};

declare function paths:document() {
        return if($path) then
        let $p    := if(contains($path,"-root")) then substring-before($path,"-root")  else substring-before($path,"-shoot")
	let $c    := paths:c()
        let $d    := substring-after($p,concat($c,"-"))
        return concat(replace($d,"(^[^-]*)-(.*)$","$1","mi"),"/",replace($d,"(^[^-]*)-(.*)$","$2","mi"),".xml")
        else
        request:get-parameter("doc","")
};

declare function paths:inferred_path() {
	return if($path) then $path else replace(concat($c,'-',substring-before($document,'.xml'),'-shoot-',$frag),'/','-')
};

