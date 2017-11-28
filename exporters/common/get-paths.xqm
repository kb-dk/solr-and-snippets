xquery version "3.0" encoding "UTF-8";

module namespace paths="http://kb.dk/this/paths";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";

declare function paths:frag($path as xs:string) as xs:string {
	let $p := $path
	return if($p) then
           if(contains($p,"-root")) then "" else substring-after($p,"shoot-")
        else
           request:get-parameter("id","root")
};

declare function paths:c($path as xs:string)  as xs:string {
	let $p := $path
        return
	if($p) then
        replace($p,"(^[^-]*)-(.*)$","$1","mi")
        else
        request:get-parameter("c","adl")
};

declare function paths:document($path as xs:string)  as xs:string {
	let $empty := ""
        return
	if($path) then
        let $p    := if(contains($path,"-root")) then substring-before($path,"-root")  else substring-before($path,"-shoot")
	let $c    := paths:c($path)
        let $d    := substring-after($p,concat($c,"-"))
        return concat(replace($d,"(^[^-]*)-(.*)$","$1","mi"),"/",replace($d,"(^[^-]*)-(.*)$","$2","mi"),".xml")
        else
        request:get-parameter("doc","")
};

declare function paths:inferred_path($path as xs:string)  as xs:string {
	let $document := paths:document($path)
	let $c    := paths:c($path)
	let $frag := paths:frag($path)
	return if($path) then $path else replace(concat($c,'-',substring-before($document,'.xml'),'-shoot-',$frag),'/','-')
};

