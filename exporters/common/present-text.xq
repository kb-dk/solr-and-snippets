xquery version "3.0" encoding "UTF-8";

declare namespace t="http://www.tei-c.org/ns/1.0";

declare variable  $document := request:get-parameter("doc","");
declare variable  $frag     := request:get-parameter("id","");
declare variable  $c        := request:get-parameter("c","texts");
declare variable  $coll     := concat("/db/adl/",$c);

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

