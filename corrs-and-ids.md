
# Correlations and identifications

## Preamble about jargon

This text is not about literature but about the model we use for
indexing the texts.

The text service contain text material which is meant to be
disseminated by the service. Then there are texts that are about that
material. We refer to the [former as
*work*](https://github.com/Det-Kongelige-Bibliotek/public-adl-text-sources/blob/master/work.md)
and the latter as being *editorial*

Only the works and text inside the works are searchable.

An *edition* is a set of content from a similar origin.

There may or may not be more than one work per document. If there are
exactly one work per volume, we refer to it as being a *monograph*.

[A *repository* is a defined as in the repository mirror architecture.](https://github.com/Det-Kongelige-Bibliotek/repository-mirror/blob/master/ARCHITECTURE.md#tools-for-the-mirroring-of-repositories)

## Correlations

### Between editorial texts and works and different manifestations

Søren Kierkegaards Skrifter, SKS (Kierkegaard's collected works) is an
*edition* containing many houndred of texts, but only a handful of
different kinds of texts. The edition is structured such that
there are just one work per directory, and the various kinds texts are
stored in those directories under the same name. Hence

1. txt.xml - the actual text by Søren Kierkegaard
2. kom.xml - various notes and comments by philologists in the project
3. txr.xml - tekstredegørelse, i.e., introductory material by philologists in the project

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
  <relatedItem type="ignore" target="capabilities.xml"/>	
</bibl>

```

The same kind of file for a volume in SKS

```
<?xml version="1.0" encoding="UTF-8" ?>
<bibl xmlns='http://www.tei-c.org/ns/1.0'>
  <ref type='Huvudtekst' target='txt.xml'/>
  <relatedItem type="Kommentar" target="int_2.xml"/>
  <relatedItem type="Tekstkommentarer" target="kom.xml"/>
  <relatedItem type="ignore" target="capabilities.xml"/>
  <relatedItem type="Tekstredegørelse" target="txr.xml"/>
  <relatedItem type="Indledning" target="int_1.xml"/>
</bibl>

``` 

A third variation on the same theme: Here is Grundtvigs Værker
(GV). Comments are here in com.xml and we have introductions in
intro.xml. Finally we have variants in vn.xml, n>=0. I have found one
example with v0.xml and v1.xml but it seems there will only be
v0.xml. On the other hand there will be introductions that introduce
more than one text. (As of writing this we have not yet solved the
user interface problem for that.)


```
<?xml version="1.0" encoding="UTF-8" ?>
<bibl>
  <ref type="Hovedtekst" target="txt.xml"/>
  <relatedItem type="Tekstkommentarer" target="com.xml"/>
  <relatedItem type="Tekstredegørelse" target="txr.xml"/>
  <relatedItem type="Indledning" target="intro.xml"/>
  <relatedItem type="Variant" target="v0.xml"/>
</bibl>
```

There are one capability.xml per work file.

### Between work and persions and periods

Arkiv før Dansk Literatur, ADL, contains its material in
three directories

* texts
* authors
* periods

the first of which contains *work* wheras the other two are
*editorial* (they contain essays about the authors and the times they
were active, respectively). There are no detailed comments or
introductions.

When designing the system we also felt that there were needs to
correlate the authors in all editions with the their essays in ADL
Hence we have a file called author-and-period.xml for each of
them. For example, for SKS we have.

```
<?xml version="1.0"?>
<table xmlns="http://www.tei-c.org/ns/1.0">
  <row>
    <cell role="author">authors/kierkegaard-p.xml</cell>
    <cell role="period">periods/romantik1800-70.xml</cell>
  </row>
</table>

```

and Holberg


```
<?xml version="1.0"?>
<table xmlns="http://www.tei-c.org/ns/1.0">
  <row>
    <cell role="author">authors/holberg--p-val.xml</cell>
    <cell role="period">periods/klassicismen1700-60.xml</cell>
  </row>
</table>

```

This is for correlating content to authors and periods across editions.

### Between work and metadata

For information on how to enter [metadata for objects inside a TEI
file](https://github.com/Det-Kongelige-Bibliotek/public-adl-text-sources/blob/master/work-metadata.md)

### Between repositories and editions

The data for ADL comes from two repositoties,

* The [public repository containing texts](https://github.com/Det-Kongelige-Bibliotek/public-adl-text-sources)
* The [private repository containing authors and periods](https://github.com/Det-Kongelige-Bibliotek/adl-text-sources)

The author and period are private because of rights management.

In general, there are one repository

## Identifications

### URIs



### Collections

