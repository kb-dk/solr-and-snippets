 # Where are the sonnets?
 
The ADL text corpus contains [literary
texts](https://github.com/kb-dk/public-adl-text-sources). It is easy
to find poetry in those files. Typically a piece of poetry is encoded
as [lines within line
groups](https://tei-c.org/release/doc/tei-p5-doc/en/html/ref-lg.html). More
often than not it is embedded in &lt;div> ... &lt;/div>. It may look
like this in the source

```
  <div xml:id="workid68251" decls="#biblid68251">
        <head xml:id="idm140093058532672">Jeg elsker —</head>
        <lg xml:id="idm140093058532240">
          <l xml:id="idm140093058531984">Jeg elsker Himlens høje Harmoni,</l>
          <l xml:id="idm140093058531520">dens Purpurblomst, som blaaner i det Fjærne,</l>
          <l xml:id="idm140093058531024">den Fred, som risler ned fra Nattens Stjerne,</l>
          <l xml:id="idm140093058530576">det Glimt af Gud, der glider mig forbi;</l>
        </lg>
        <lg xml:id="idm140093058530016">
          <l xml:id="idm140093058529760">og Evighedens tavse Melodi,</l>
          <l xml:id="idm140093058529328">de svundne Slægters kaldende Orkester,</l>
          <l xml:id="idm140093058528848">et Tonehav om en usynlig Mester,</l>
          <l xml:id="idm140093058528416">en Klang af Gud, der bruser mig forbi;</l>
        </lg>
        <lg xml:id="idm140093058527856">
          <l xml:id="idm140093058527600">en magisk Magt fra Hjertets mørke Celle,</l>
          <l xml:id="idm140093058527120">de stærke Længsler, som mod Lyset vælde,</l>
          <l xml:id="idm140093058526640">Naturens evigunge Fantasi;</l>
        </lg>
        <lg xml:id="idm140093058526080">
          <l xml:id="idm140093058525824">det Liv, der spirer midt i selve Døden,</l>
          <l xml:id="idm140093058525344">den Sol, der stiger midt i Aftenrøden,</l>
          <l xml:id="idm140093058524864">— o Glimt af Gud, der glider mig forbi!</l>
        </lg>
        <p xml:id="idm140093058524288">
          <date xml:id="idm140093058524032">12. Septbr. 1893.</date>
        </p>
      </div>
```

Michaëlis, Sophus: ”Jeg elsker —”, i Michaëlis, Sophus:
Solblomster. Titelvignet af Frode Eskesen, Gyldendal, 1893,
s. 151. Onlineudgave fra Arkiv for Dansk Litteratur:
https://tekster.kb.dk/text/adl-texts-michs_03-shoot-workid68251

The default name space is declared as
xmlns="http://www.tei-c.org/ns/1.0", which we in following refer to
with the namespace prefix 't'.

The poem comprises four line groups with four, four, three and three
lines. That is a very common strophe structure for
[sonnets](https://en.wikipedia.org/wiki/Sonnet), at least in
Scandinavia. It is not always like that, but they all contain 14
lines.

Shakespeare wrote often his 14 lines typographically in one strophe,
whereas Francesco Petrarca wrote them in two strophes with eight and
six lines, respectively.

To be more precise, a sonnet has more characteristics than 14 lines,
those lines are in [iambic
pentameter](https://en.wikipedia.org/wiki/Iambic_pentameter).

## Finding sonnets

You can easily find all poems based on a XPATH query like:

```
//t:div[t:lg and @decls]

```

We can use that query in XSLT like this:

```
  <xsl:for-each select="//t:div[t:lg and @decls]">
        <xsl:if test="count(.//t:lg/t:l)=14">

```

So we iterate over all &lt;div>...&lt;/div>s having line groups inside
and have a @decls attribute containing a reference to metadata in the
TEI header. The latter is not universal, but we use it in ADL.

Finding &lt;div>...&lt;/div>s having 14 lines of poetry isn't good
enough. We wanting iambic pentameter, don't we? To actually analyse
the texts for their rythmical properties is beyond me, but we could
make an approximation.

iambic verse consists of feet with two syllables, i.e. if there are
five feet per line we could say that iambic verse has approximately 10
vowels per line.

```
   <xsl:variable name="vowel_numbers" as="xs:integer *">
       <xsl:for-each select=".//t:lg/t:l">
           <xsl:variable name="vowels">
		      <xsl:value-of select="replace(.,'[^iyeæøauoå]','')"/>
		   </xsl:variable>
           <xsl:value-of select="string-length($vowels)"/>
       </xsl:for-each>
   </xsl:variable>
   <xsl:value-of select="format-number(sum($vowel_numbers) div 14, '#.####')"/>
```
We use the replace function and a regular expression to remove
everything in each line except the vowels. Then we measure the string
length which should equal the number of vowels per line and add them
together for all lines in the poem. Finally we divide that sum with 14
and get the average number of vowels per line.

For a sonnet it would be 10, [or occasionally a little
more](https://en.wikipedia.org/wiki/Hendecasyllable). In the poem
quoted above it is 10.4.

