xquery version "3.1" encoding "UTF-8";

import module namespace paths="http://kb.dk/this/paths" at "./get-paths.xqm";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace file="http://exist-db.org/xquery/file";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace local="http://kb.dk/this/app";
declare namespace response="http://exist-db.org/xquery/response";

declare namespace t="http://www.tei-c.org/ns/1.0";

declare option output:method "xml";
declare option output:media-type "text/xml";

declare variable  $path     := request:get-parameter("path","");

declare variable  $frag      := paths:frag($path);
declare variable  $c         := paths:c($path);
declare variable  $document  := paths:document($path);
declare variable  $directory := concat("/db/text-retriever/",$c,"/",paths:directory($path));
declare variable  $file      := concat("/db/text-retriever/",$c,"/",$document);

declare variable  $is_my_dir := file:is-directory(($directory));
declare variable  $readable  := file:is-readable(($file));

declare variable  $list      := xmldb:get-child-resources($directory);

declare function local:caps($list as xs:string* ) as node()
{
	let $something := ""
	return
	element t:bibl
	{
	   for $file in $list
		return 
		if(matches($file,"txt.xml")) then
 		   element t:ref {
			attribute target {$file},
			attribute type {"Hovedtekst"}
		   }
		else
	      	   element t:relatedItem {
			attribute target {$file},
			attribute type {local:determine_type($file)}
		   }
	}
};


declare function local:determine_type($file as xs:string) as xs:string
{
	let $type :=
	if(matches($file, "int_1.xml")) then "Indledning"
	else if (matches($file,"int_2.xml")) then "Kommentar"
	else if (matches($file,"kom.xml")) then "Tekstkommentarer"
	else if (matches($file,"com.xml")) then "Tekstkommentarer"
	else if (matches($file,"txr.xml")) then "Tekstredegørelse"
	else if (matches($file,"capabilities.xml")) then "ignore"
	else ""
	return $type
};

let $result := 
map {
	"file":$file,
	"readable":$readable,
	"collection":$c,
        "frag":$frag,
        "directory":$directory,
        "is_my_dir":$is_my_dir,
	"author":doc($file)//t:titleStmt/t:author[1]/string(),
        "dir":$list
}

return  local:caps($list)