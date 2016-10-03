
(:
Using LOC relators
from config/controlled_lists.yml

sender
'http://id.loc.gov/vocabulary/relators/crp': Correspondent

recipient
'http://id.loc.gov/vocabulary/relators/rcp': Addressee

:)


(:xdb:store($pubroot,util:document-name($doc), $doc):)

(: this is for experimenting with json handling :)

let $person := 
  '{"firstName": "John W",
    "lastName": "Smith",
    "isAlive": true,
    "age": 25,
    "height_cm": 167.6,
    "address": {"streetAddress": "21 2nd Street",
                "city": "New York",
                "state": "NY",
                "postalCode": "10021-3100"},
                "phoneNumbers": [{"type": "home", 
                                  "number": "212 555-1234"},
                                 {"type": "office",
                                  "number": "646 555-4567"}],
				  "children": [],
				  "spouse": null}'

let $persdoc :=
    json:parse-json($person)




(:return
$params
:)

(:
<json type="object">
    <pair name="firstName" type="string">John</pair>
    <pair name="lastName" type="string">Smith</pair>
    <pair name="isAlive" type="boolean">true</pair>
    <pair name="age" type="number">25</pair>
    <pair name="height_cm" type="number">167.6</pair>
    <pair name="address" type="object">
        <pair name="streetAddress" type="string">21 2nd Street</pair>
        <pair name="city" type="string">New York</pair>
        <pair name="state" type="string">NY</pair>
        <pair name="postalCode" type="string">10021-3100</pair>
    </pair>
    <pair name="phoneNumbers" type="array">
        <item type="object">
            <pair name="type" type="string">home</pair>
            <pair name="number" type="string">212 555-1234</pair>
        </item>
        <item type="object">
            <pair name="type" type="string">office</pair>
            <pair name="number" type="string">646 555-4567</pair>
        </item>
    </pair>
    <pair name="children" type="array"/>
    <pair name="spouse" type="null"/>
</json>
:)
