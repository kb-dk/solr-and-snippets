<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">
  
  <xsl:import href="../render-global.xsl"/>
  <xsl:import href="../apparatus-global.xsl"/>

  <xsl:param name="publisher" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt/t:authority">
      <xsl:apply-templates mode="gettext"  select="."/><xsl:if test="position() &lt; last()">; </xsl:if>
    </xsl:for-each>
  </xsl:param>

  <xsl:template match="t:pb">
    <xsl:variable name="first">
      <xsl:value-of select="count(preceding::t:pb[@ed='A'])"/>
    </xsl:variable>

    <xsl:if test="@ed='A' and $first &gt; 0">
      <xsl:element name="span">
	<xsl:attribute name="title">Side <xsl:value-of select="@n"/></xsl:attribute>
	<xsl:call-template name="add_id_empty_elem"/>
	<xsl:attribute name="class">pageBreak</xsl:attribute>
	<xsl:if test="@n">
	  <xsl:element name="a">
	    <small><xsl:value-of select="@n"/></small>
	  </xsl:element>
	</xsl:if>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:ref[@type='komm']">
    <xsl:if test="contains(@type,'komm') and contains(@path,'komm')">
      <xsl:if test="contains($doc,fn:lower-case(fn:replace(@target,'.page.*$','')))">
	<a href="{fn:replace(@target,'^(.*#[^:]*?:)','#')}"><xsl:apply-templates/></a>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:seg[@type='komm']">
    <xsl:variable name="p">
      <xsl:value-of select="replace($path,'(_overs)|(_mod)','')"/>
    </xsl:variable>
    <xsl:variable name="href">
      <xsl:value-of select="concat(fn:replace($p,'-((root)|(shoot).*$)','_komm-root#'),@target)"/>
    </xsl:variable>
    <a title="Kommentar" href="{$href}">&#9658;</a>
  </xsl:template>

   <xsl:template name="inferred_path">
     <xsl:param name="document" select="$doc"/>
     <xsl:variable name="frag">
       <xsl:choose>
	 <xsl:when test="contains($document,'#')">
	   <xsl:value-of select="fn:replace(substring-after($document,'#'),':.*$','')"/>
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
     <xsl:text>/text/</xsl:text><xsl:value-of select="replace(concat($c,'-',fn:lower-case(fn:replace($document,'(\.xml)|(\.page).*$','')),$f,$frag),'/','-')"/>
   </xsl:template>

  <xsl:template name="make-href">
    <xsl:call-template name="inferred_path">
      <xsl:with-param name="document" select="@target"/>
    </xsl:call-template>
  </xsl:template>



  <xsl:template name="extract_titles_authors_etc">

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
    <xsl:element name="field"><xsl:attribute name="name">publisher_tesim</xsl:attribute><xsl:value-of select="$publisher"/></xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">publisher_nasim</xsl:attribute><xsl:value-of select="$publisher"/></xsl:element>

  </xsl:template>

  <xsl:template mode="backtrack" match="node()[@xml:id]">
    <xsl:element name="field">
      <xsl:attribute name="name">part_of_ssim</xsl:attribute>
      <xsl:value-of select="concat(substring-before($path,'-root'),'-shoot-',@xml:id)"/>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="ancestor::node()">
	<xsl:apply-templates mode="backtrack" select="ancestor::t:div[1]|ancestor::t:text[1]"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="field">
	  <xsl:attribute name="name">part_of_ssim</xsl:attribute>
	  <xsl:value-of select="$path"/>
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>




</xsl:transform>