xquery version "3.0" encoding "UTF-8";

module namespace lbl="http://kb.dk/this/lbl";

declare function lbl:label-hits( $doc  as node()* ) as node()* {
	let $query := request:get-parameter('q','')
	return lbl:run-filter($doc,$query) 
};

declare function lbl:run-filter($doc as item()*, $query as xs:string ) as node()* {

	let $qlist := tokenize($query,"\s+")
	let $first_term       := $qlist[1]

	return
	if(count($qlist) > 1) then
	let $the_other_terms  := string-join(subsequence($qlist,2)," ")
	return
	lbl:filter(lbl:run-filter($doc,$the_other_terms),$first_term)
	else
	lbl:filter($doc,$first_term)

};

(: copy the input to the output without modification :)

declare function lbl:filter($input as item()*, $query as xs:string ) as item()* {
	for $node in $input
	return 
	typeswitch($node)
        case element(script) return $node
        case element()
        return
        element {name($node)} {
                (: output each attribute in this element :)
                for $att in $node/@*
                return attribute {name($att)} {$att},
                (: output all the sub-elements of this element recursively :)
                for $child in $node
                return lbl:filter($child/node(),$query)
        }
        case text()
        return
	if(matches(replace($node/string(),"[\s\n\r]+"," ","mi"),$query,"mi") ) then
	let $text := replace($node/string(),"[\s\n\r]+"," ","mi")
	return
	(replace($text,concat($query,".*$"),"","im"),
		<span style="background-color: rgb(255,255,0);" class="hit">{replace($text,concat("(^.*)(",$query,")(.*$)"),"$2","mi")}</span>,
		lbl:filter(text{replace($text,concat("^.*?(",$query,")"),"","im")},$query))
	else 
	$node
        (: otherwise pass it through.  Used for, comments, and PIs :)
	default return $node
};

