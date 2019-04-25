<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       exclude-result-prefixes="t fn">
  
  <xsl:import href="../solrize-global.xsl"/>

  <xsl:param name="is_monograph">yes</xsl:param>

  <xsl:param name="subcollection" select="'gv'"/>

  <xsl:param name="i_am_a">
    <xsl:call-template name="me_looks_like"/>
  </xsl:param>

  <!-- sourceDesc in GV seems to contain Garbage -->
  <xsl:param name="volume_title">
    <!-- xsl:for-each select="(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title|/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title)[1]" -->
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[1]">
      <xsl:apply-templates mode="gettext"  select="."/>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="worktitle">
    <xsl:value-of select="$volume_title"/>
  </xsl:param>


  <xsl:param name="editor" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:respStmt">
      <xsl:for-each select="t:resp">
	<xsl:apply-templates mode="gettext"  select="."/><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:param>


  <xsl:param name="volume_sort_title">
    <xsl:value-of select="$worktitle"/>
  </xsl:param>

  <xsl:template name="get_category">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'text' and contains($path,'-txt-')">work</xsl:when>
      <xsl:when test="local-name(.) = 'text' and contains($path,'-v0-')">editorial</xsl:when>
      <xsl:when test="local-name(.) = 'text' and contains($path,'-txr-')">editorial</xsl:when>
      <xsl:when test="local-name(.) = 'text' and contains($path,'-com-')">editorial</xsl:when>
      <xsl:when test="local-name(.) = 'text' and contains($path,'-intro-')">editorial</xsl:when>
    </xsl:choose>
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


  <xsl:template name="me_looks_like">

  </xsl:template>

  <xsl:template name="extract_titles_authors_etc">
    <xsl:element name="field"><xsl:attribute name="name">author_name_ssi</xsl:attribute>Grundtvig, N. F. S.</xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">author_name_ssim</xsl:attribute>Grundtvig, N. F. S.</xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">author_nasim</xsl:attribute>N. F. S. Grundtvig</xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">author_name_tesim</xsl:attribute>N. F. S. Grundtvig</xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">publisher_tesim</xsl:attribute><xsl:value-of select="$publisher"/></xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">publisher_nasim</xsl:attribute><xsl:value-of select="$publisher"/></xsl:element>
  </xsl:template>

</xsl:transform>