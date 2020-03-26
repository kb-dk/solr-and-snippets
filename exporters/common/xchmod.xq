xquery version "3.0";
import module namespace dbutil="http://exist-db.org/xquery/dbutil";
dbutil:find-by-mimetype(xs:anyURI("/db"), "application/xquery", function
($resource) {
	  let $mod:=if(contains($resource,"capabilities_generator.xq")) then "rwsr-sr-t" else "rwxr-xr-x"
    return sm:chmod($resource, $mod)
}),
dbutil:scan-collections(xs:anyURI("/db"), function($collection) {
    sm:chmod($collection, "rwxr-xr-x")
})


(: Another one is:  sm:chmod($collection, "rwsr-sr-t") :)