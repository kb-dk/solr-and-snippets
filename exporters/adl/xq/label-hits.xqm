xquery version "3.0" encoding "UTF-8";

module namespace lbl="http://kb.dk/this/lbl";

declare function lbl:label-hits( $doc  as node()* ) as node()* {
	let $q := request:get-parameter('q','')
	return lbl:filter($doc,$q) 
};


(: copy the input to the output without modification :)

declare function lbl:filter($input as item()*, $q as xs:string ) as item()* {
	for $node in $input
	return 
	typeswitch($node)
        case element()
        return
        element {name($node)} {
                (: output each attribute in this element :)
                for $att in $node/@*
                return attribute {name($att)} {$att},
                (: output all the sub-elements of this element recursively :)
                for $child in $node
                return lbl:filter($child/node(),$q)
        }
        case text()
        return 
	if(matches(normalize-space($node/string()),$q,"i") ) then
	let $text := normalize-space($node/string())
	return
	(replace($text,concat($q,".*$"),"","im"),
		<span class="hit">{replace($text,concat("(^.*)(",$q,")(.*$)"),"$2","im")}</span>,
		lbl:filter(replace($text,concat("^.*",$q),"","im"),$q))
	else 
	$node
        (: otherwise pass it through.  Used for, comments, and PIs :)
	default return $node
};

