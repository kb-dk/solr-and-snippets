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

declare option    exist:serialize "method=xml media-type=text/xml";

declare function local:enter-location-data(
  $frag as xs:string,
  $type as xs:string,
  $doc  as node(),
  $json as node()) as node()*
{
  let $letter := $doc//node()[@xml:id=$frag]
  let $bibl   := $doc//t:bibl[@xml:id = $letter/@decls]


  let $loc_id := concat("idm",util:uuid())
	
  let $cleanup :=
  for $loc in $bibl/t:location[(@type = $type) or not(node())]
    return update delete $loc

  let $tasks := 
    for $location in $json//pair[@name="place"]/item[pair=$type]
      let $place_id  := $location/pair[@name="xml_id"]/text()
      let $n := 
      <t:location type="{$type}" xml:id="{$loc_id}">
	<t:placeName>{$location//pair[@name="name"]/text()}</t:placeName>
      </t:location>
      let $something := update insert $n into $bibl
      let $name := $bibl/t:location[@xml:id=$loc_id]

      let $do_geo :=
        for $geo in $doc//t:geogName[$place_id=@xml:id]
	  let $ut := update insert attribute type {$type} into $geo
	  let $us := update insert attribute sameAs {$loc_id} into $geo
	  return $us

     return $name

   return ()
};

declare function local:enter-date(
  $frag as xs:string,
  $doc  as node(),
  $json as node()) as node()*
{
  let $letter       := $doc//node()[@xml:id=$frag]
  let $bibl_date    := $doc//t:bibl[@xml:id = $letter/@decls]/t:date

  let $date_struct  := $json//pair[@name="date"]
  let $date_val     := $date_struct/pair[@name="edtf"]/text()


  let $mid          := concat("idm",util:uuid())
  let $date         := <t:date xml:id="{$mid}">{$date_val}</t:date>
  let $u            := update replace $bibl_date with $date
  let $same :=
    if($date_struct/pair[@name="xml_id"]/text()) then
      let $date_text_id := $date_struct/pair[@name="xml_id"]/text()
      let $s            := update insert attribute sameAs {$mid} into 
	$letter//t:date[@xml:id = $date_text_id]
      return $s
    else
      ""

  return ()
    
};

declare function local:enter-status(
  $frag as xs:string,
  $doc  as node(),
  $json as node()) as node()*
{
  let $letter       := $doc//node()[@xml:id=$frag]
  let $bibl         := $doc//t:bibl[@xml:id = $letter/@decls]
  let $status_val   := $json//pair[@name="status"]/text()

  let $stat :=
    if($bibl) then
      let $s            := update insert attribute status {$status_val} into $bibl
      return $s
    else
      ""

  return ()
    
};

declare function local:enter-person-data(
  $frag as xs:string,
  $role as xs:string,
  $doc as node(),
  $json as node()) as node()*
{
  let $letter := $doc//node()[@xml:id=$frag]
  let $resp   := $doc//t:bibl[@xml:id = $letter/@decls]
                      /t:respStmt[t:resp = $role ]

  let $respid_id := 
    if($resp/@xml:id) then
      $resp/@xml:id
    else
      let $mid := concat("idm",util:uuid())
      let $u   := update insert attribute xml:id {$mid} into $resp
      return $mid

  let $cleanup :=
  for $n in $resp//t:name
  return update delete $n

  let $tasks := 
  for $person in $json//pair[@name=$role]/item[@type='object']
    let $person_id  := 
      if(string-length($person//pair[@name="xml_id"]) > 0) then
	$person//pair[@name="xml_id"]
      else
	concat("person",util:uuid())

    let $person_uri :=
      if(string-length($person//pair[@name="auth_id"]) > 0) then
	$person//pair[@name="auth_id"]
      else
	""
    let $name := 
    <t:name xml:id="person{$person_id}" ref="{$person_uri}">   
      <t:surname>{$person//pair[@name="family_name"]/text()}</t:surname>,
      <t:forename>{$person//pair[@name="given_name"]/text()}</t:forename>
    </t:name>

    let $full_name := concat(
      $person//pair[@name="family_name"]/text(),
      ", ",
      $person//pair[@name="given_name"]/text())

    let $all :=
      if($person_id) then
	let $s    := $letter//t:persName[$person_id=@xml:id]
	let $pref := concat("#person",$person_id)
	let $up1  := update insert attribute key {$full_name} into $s
	let $up2  := update insert attribute sameAs {$pref}   into $s
	let $up5  := update insert $name into $resp      
	let $r    := $resp/t:name[last()]
	return $r
      else
	let $rup5  := update insert $name into $resp      
	let $rr    := $resp/t:name[last()]
	return $rr

   
 
     return $all

  return ()

};



let $prev := 
  if($frag) then
    for $doc in collection($coll)//node()[ft:query(@xml:id,$frag)]
    where util:document-name($doc)=$document 
    return $doc/preceding::t:div[1]/@xml:id
  else
    ""

let $next := 
  if($frag) then
    for $doc in collection($coll)//node()[ft:query(@xml:id,$frag)]
    where util:document-name($doc)=$document
    return $doc/following::t:div[1]/@xml:id
  else
    ""

let $prev_encoded := 
  if($frag) then
    concat(replace(substring-before($file,'.xml'),'/','%2F'),'-',$prev)
  else
    ""
let $next_encoded := 
  if($frag) then
    concat(replace(substring-before($file,'.xml'),'/','%2F'),'-',$next)
  else
    ""

let $data := json:parse-json($content)

let $doc := 
for $tei in collection($coll)
where util:document-name($tei)=$document
return $tei

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
  <param name="status"   value="{$status}"/>
</parameters>


let $d := local:enter-person-data(  $frag,"sender",   $doc,$data)
let $e := local:enter-person-data(  $frag,"recipient", $doc,$data)
let $f := local:enter-location-data($frag,"sender",   $doc,$data)
let $g := local:enter-location-data($frag,"recipient",$doc,$data)
let $g := local:enter-location-data($frag,"other",$doc,$data)
let $dins := local:enter-date($frag,$doc,$data)
let $status := local:enter-status($frag,$doc,$data)

let $res := transform:transform($doc,$op,$params)
return  
  if($o='json') then
    json:serialize-json($res)
  else
    $res

