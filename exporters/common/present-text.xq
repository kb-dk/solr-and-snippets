xquery version "3.0" encoding "UTF-8";

declare namespace t="http://www.tei-c.org/ns/1.0";
import module namespace paths="http://kb.dk/this/paths" at "./get-paths.xqm";
declare variable  $path     := request:get-parameter("path","");

declare variable  $frag          := paths:frag($path);
declare variable  $c             := paths:c($path);
declare variable  $document      := paths:document($path);
declare variable  $inferred_path := paths:inferred_path($path);
declare variable  $coll          := concat("/db/text-retriever/",$c);

declare option exist:serialize "method=text media-type=text/plain encoding=UTF-8";

let $doc :=
for $d in collection($coll)
where util:document-name($d)=$document
return $d

return 
if($frag) then
$doc//node()[@xml:id = $frag]//text()
else 
for $body in $doc//t:body
return $body//text()

