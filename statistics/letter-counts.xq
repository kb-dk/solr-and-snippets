xquery version "3.0" encoding "UTF-8";

declare namespace t="http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=xml encoding=UTF-8 media-type=text/html";

let $solr_search := doc("http://bifrost-solr-prod-01.kb.dk:8080/solr/letters-core/select?q=cat_ssi%3Aletterbook&amp;rows=200&amp;wt=xml&amp;indent=true")
let $result :=
<table>
<tr><th>SOLR letter book</th><th>TEI</th><th>pages</th></tr>
{
	for $id in $solr_search//doc/str[@name="id"]/string()
	let $file :=  concat(replace($id,"/letter_books/\d+/",""),'.xml')
	let $doc := 
	for $d in collection("/db/letter_books")
	where util:document-name($d)=$file
	return $d

	return <tr><td>{$id}</td><td>{$file}</td><td class="count">{count(distinct-values($doc//t:pb/@facs))}</td></tr>

} </table>

let $total := $result//td[@class = 'count']/number()

return <div>{$result}<p><strong>Total: </strong>{sum($total)}</p></div>