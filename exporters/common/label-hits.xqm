xquery version "3.0" encoding "UTF-8";

module namespace lbl="http://kb.dk/this/lbl";

declare function lbl:label-hits( $doc  as node()* ) as node()* {
	let $query := request:get-parameter('q','')
	let $match_type := request:get-parameter('match','all')
	return
	if(contains($match_type,'phrase')) then
	lbl:run-filter($doc,replace($query,"[\*\?\.,\s\n\r]+","..?","mi")) (: ..? = one or possibly two characters :)
	else
	lbl:run-filter($doc,$query)
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
	   let $match_type := request:get-parameter('match','all')
	   return
	   if(contains($match_type,'phrase')) then
	     lbl:do_phrase_labeling($node,$query)
	   else
	     lbl:do_word_labeling($node,$query)
        (: otherwise pass it through.  Used for, comments, and PIs :)
	default return $node
};

declare function lbl:do_word_labeling($node as item(),$query as xs:string) as item()* {
   if(matches(replace($node/string(),"[\s\n\r]+"," ","mi"),$query,"mi") ) then
	let $text := tokenize($node/string(),"[\s\n\r]+")
	return
	for $token in $text
	return 
	if(matches($token,concat("^",$query),"mi")) then
	   let $match     := replace($token,concat("^(",$query,")(.*$)"),"$1","im")
	   let $remainder := replace($token,concat("^(",$query,")(.*$)"),"$2","im")
	    return
	      (<span style="background-color: rgb(255,255,0);" class="hit">{$match}</span>,$remainder," ")
	else ($token," ")
   else $node
};

declare function lbl:do_phrase_labeling($text as node(),$query as xs:string) as item()* {
   for $token in $text
   return
   let $clause := replace($token,"[\s\n\r]+"," ","mi")
   return
   if(matches($clause,$query,"i") ) then
     let $before    := replace($clause,concat($query,".*$"),"","i")
     let $after     := replace(substring-after($clause,$before),concat("^",$query),"","i")
     let $match     := if(contains($before,"\w+") and contains($after, "\w+")) then 
	                  substring-before(substring-after($clause,$before),$after)
	               else
	                  if(contains($before,"\w+")) then substring-after($clause,$before)
                          else if(contains($after,"\w+")) then substring-before($clause,$after)	
	                  else $clause

     let $remainder := if(string-length($after) > 0) then lbl:do_phrase_labeling(text{$after},$query) else ()
     return ($before , 
	     <span style="background-color: rgb(255,255,0);" class="hit">{$match}</span>, $remainder)
   else text{$clause}

};