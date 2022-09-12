<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:me="urn:my-things"
	       exclude-result-prefixes="t fn">

  <xsl:import href="../solrize-global.xsl"/>
  <xsl:param name="subcollection" select="'sks'"/>  

  <!--

//t:div[type='letter' and corresp='#letter-ref']

types of divs with frequencies

xpath -q -e '//div/@type' */txt.xml | sort | uniq -c | sort -n
5  type="dateline"
22  type="work"
36  type="label"
85  type="correspondance"
120  type="dedication"
336  type="letter"
472  type="mainText"
872  type="chapter"
1125  type="marginalColumn"
7392  type="entry"
7425  type="mainColumn"

letter, dedication & entry are candidates for individual "work status" (many of them has dates)

xpath -q -e '//text/@type' */txt.xml | sort | uniq -c | sort -n
80  type="print"
132  type="ms"

xpath -q -e '//text/@subtype' */txt.xml | sort | uniq -c | sort -n
1  subtype="documents"
9  subtype="unpublishedWritings"
15  subtype="lettersAndDedications"
78  subtype="publishedWritings"
109  subtype="journalsAndPapers"

  -->

  <xsl:param name="is_monograph">
    <xsl:choose>
      <xsl:when test="//t:text/@subtype='lettersAndDedications'">no</xsl:when>
      <xsl:when test="//t:text/@subtype='journalsAndPapers'">no</xsl:when>
      <xsl:otherwise>yes</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="volume_title">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:seriesStmt">
      <xsl:value-of  select="normalize-space(t:title)"/>, Bd. <xsl:value-of select="normalize-space(t:biblScope[@unit='volume'])"/>
    </xsl:for-each>    
  </xsl:param>

  <xsl:param name="worktitle">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[not(@level) and not(@type)]">
      <xsl:apply-templates mode="gettext"  select="."/>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="editor" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:editor">
      <xsl:for-each select="t:name">
	<xsl:value-of  select="."/><xsl:if test="position() &lt; last()">; </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="publisher" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt/t:authority">
      <xsl:apply-templates mode="gettext"  select="."/><xsl:if test="position() &lt; last()">; </xsl:if>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="volume_sort_title">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[@level='s']">
      <xsl:value-of select="."/>
    </xsl:for-each>
  </xsl:param>


  <xsl:template name="is_a_monograph">
    <xsl:choose>
      <xsl:when test="//t:text/@subtype='lettersAndDedications'">no</xsl:when>
      <xsl:when test="//t:text/@subtype='journalsAndPapers'">no</xsl:when>
      <xsl:otherwise>yes</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

   <xsl:function name="me:is-a-work">
    <xsl:param name="this"  as="node()"/>
    
    <xsl:choose>
      <xsl:when test="contains($path,'sks-') and $this/@type='work' and $this/t:div[@type='dedication']"><xsl:value-of select="true()"/></xsl:when>
      <xsl:when test="contains($path,'sks-') and $this/@type='entry'"><xsl:value-of select="true()"/></xsl:when>
      <xsl:when test="contains($path,'sks-') and $this/@type='letter' and contains($this/@corresp,'#')"><xsl:value-of select="true()"/></xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:function>

  <xsl:template match="/">
    <xsl:element name="add">
      <xsl:call-template name="generate_volume_doc" >
	<xsl:with-param name="is_monograph" select="$is_monograph"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="facs_and_text">
    <field name="has_facs_ssi">no</field>
    <field name="has_text_ssi">yes</field>
  </xsl:template>

  <xsl:template name="is_editorial">
    <xsl:variable name="category"><xsl:call-template name="get_category"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($category,'work')">no</xsl:when>
      <xsl:otherwise>yes</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="get_category">
    <xsl:choose>
      <xsl:when test="contains($path,'-txt-')">work</xsl:when>
      <xsl:when test="contains($path,'-txr-')">editorial</xsl:when>
      <xsl:when test="contains($path,'-kom-')">editorial</xsl:when>
      <xsl:when test="contains($path,'-ekom-')">editorial</xsl:when>
      <xsl:when test="contains($path,'-int_')">editorial</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="use_for_title">
    <xsl:value-of select="$worktitle"/>
  </xsl:template>
  
  <xsl:template match="t:text[@type='com' or @type='commentary']">
    <xsl:comment> the text element for comments </xsl:comment>
    <xsl:variable name="tit">
      <xsl:choose>
	<xsl:when test="string-length($worktitle)">
	  <xsl:value-of select="$worktitle"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="t:head[1]"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:call-template name="trunk_doc">
      <xsl:with-param name="worktitle" select="$tit"/>
    </xsl:call-template>

    <xsl:apply-templates select="t:body/t:div/t:note">
      <xsl:with-param name="worktitle" select="$tit"/>
    </xsl:apply-templates>

  </xsl:template>


  <xsl:template match="t:row|t:note[t:p]">
    <xsl:param name="worktitle" select="''"/>

    <xsl:comment> the right com doc note </xsl:comment>
    
    <xsl:call-template name="make_comment"/>
    
  </xsl:template>


  <!-- xsl:attribute name="name">text_type_ssi</xsl:attribute -->
  <xsl:template name="text_type">
    <xsl:if test="/t:TEI//t:text/@subtype">
      <xsl:element name="field">
	<xsl:attribute name="name">textclass_genre_ssim</xsl:attribute>
	<xsl:choose>
	  <xsl:when test="/t:TEI//t:text/@subtype='journalsAndPapers'">Journaler og papirer</xsl:when>
	  <xsl:when test="/t:TEI//t:text/@subtype='publishedWritings'">Trykte skrifter</xsl:when>
	  <xsl:when test="/t:TEI//t:text/@subtype='lettersAndDedications'">Breve og dedikationer</xsl:when>
	  <xsl:when test="/t:TEI//t:text/@subtype='unpublishedWritings'">Utrykte skrifter</xsl:when>
	  <xsl:when test="/t:TEI//t:text/@subtype='documents'">Dokumenter</xsl:when>
	</xsl:choose>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="inferred_path">
    <xsl:param name="document" select="$doc"/>
    <xsl:variable name="frag">
      <xsl:choose>
	<xsl:when test="contains($document,'#')">
	  <xsl:value-of select="substring-after($document,'#')"/>
	</xsl:when>
	<xsl:otherwise>root</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="f">
      <xsl:choose>
	<xsl:when test="$frag = 'root'">-</xsl:when>
	<xsl:otherwise>-root#</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>/text/</xsl:text><xsl:value-of
    select="translate(concat($c,'-',substring-before($doc,'/'),'/',substring-before($document,'.xml'),$f,$frag),'/','-')"/>
  </xsl:template>

  <xsl:template name="extract_titles_authors_etc">
    <xsl:param name="worktitle" select="''"/>
    <xsl:choose>
      <xsl:when test="contains($path,'-txt')">
	<xsl:element name="field"><xsl:attribute name="name">author_name_ssi</xsl:attribute>Kierkegaard, Søren</xsl:element>
	<xsl:element name="field"><xsl:attribute name="name">author_name_ssim</xsl:attribute>Kierkegaard, Søren</xsl:element>
	<xsl:element name="field"><xsl:attribute name="name">author_nasim</xsl:attribute>Søren Kierkegaard</xsl:element>
	<xsl:element name="field"><xsl:attribute name="name">author_name_tesim</xsl:attribute>Søren Kierkegaard</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:author">
	  <xsl:for-each select="t:name">
	    <xsl:element name="field"><xsl:attribute name="name">author_name_tesim</xsl:attribute>
	    <xsl:value-of  select="."/>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl">
      <xsl:for-each select="t:date">
	<xsl:element name="field">
          <xsl:attribute name="name">year_itsi</xsl:attribute>
	<xsl:value-of  select="."/>
	</xsl:element>
      </xsl:for-each>
    </xsl:for-each>
    
    <xsl:element name="field"><xsl:attribute name="name">publisher_tesim</xsl:attribute><xsl:value-of select="$publisher"/></xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">publisher_nasim</xsl:attribute><xsl:value-of select="$publisher"/></xsl:element>

  </xsl:template>

  <!-- xsl:template name="what_i_can"/ -->

</xsl:transform>
