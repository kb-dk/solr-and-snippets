
# Correlations and identifications

The text service contain text material which is meant to be
disseminated by the service. Then there are texts that are about that
material. We refer to the former as *work* and the latter as being
*editorial*

Only the works and text inside the works are searchable.

## Correlations

Søren Kierkegaards Skrifter, SKS (Kierkegaard's collected works)
contains about a handful of different kinds of texts. The collections
is structured such that there are just one work per directory, and the
various kinds texts are stored in those directories under the same
name. Hence

1. txt.xml - the actual text by Søren Kierkegaard
2. kom.xml - various notes and comments
3. txr.xml - tekstredegørelse, i.e., introductory material

Of these, only txt.xml are *work*, while kom.xml and txr.xml are
regarded as *editorial*. Other editions have similar structure, but
other relations. For instance, the Holberg project contains the texts
in the original language (sometimes Latin, sometimes early 18th
century Danish) and then translations or modernisations

A *work* file may have related files which we refer to as
*capabilities*. A capability file is in TEI xml and contain a
reference to the file described and to related items.

```
<?xml version="1.0" encoding="UTF-8" ?>
<bibl xmlns="http://www.tei-c.org/ns/1.0">
  <title>Nicolai Klimii iter subterraneum</title>
  <ref type="Tekst" target="niels_klim.xml"/>
  <relatedItem type="Kommentar" target="niels_klim_komm.xml"/>
  <relatedItem type="Oversættelse" target="niels_klim_overs.xml"/>
  <relatedItem type="Tekstredegørelse" target="niels_klim_innl.xml"/>
  <!--  Tekst Kommentar Tekstredegørelse -->
</bibl>

```

The same kind of file for a volume in SKS


Arkiv før Dansk Literatur, ADL, contains its material in
three directories

* texts
* authors
* periods

the first of which contains *work* wheras the other two are
*editorial* (they contain essays about the authors and the times they
were active, respectively).

 

## Identifications