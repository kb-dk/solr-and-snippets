<?xml version="1.0" encoding="UTF-8" ?>
<!--

Author Sigfrid Lundberg slu@kb.dk
-->
<xsl:transform version="1.0"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	       exclude-result-prefixes="t">

  <xsl:import href="toc.xsl"/>

  <xsl:param name="id" select="''"/>
  <xsl:param name="doc" select="''"/>
  <xsl:param name="hostname" select="''"/>

  <xsl:output encoding="UTF-8"
	      indent="yes"
	      method="xml"
	      omit-xml-declaration="yes"/>


 <xsl:template name="add_anchor">
    <xsl:element name="a">
      <xsl:attribute name="href">
	<xsl:value-of
            select="concat('#',preceding::t:pb[1]/@xml:id|descendant::t:pb/@xml:id[1])"/>
      </xsl:attribute>
      <xsl:choose>
	<xsl:when test="t:head">
	  <xsl:apply-templates select="t:head"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:variable name="some_text">
	    <xsl:apply-templates select=".//*/text()"/>
	  </xsl:variable>
	  <xsl:value-of
	      select="substring(normalize-space($some_text),1,20)"/>
	  <xsl:text>...</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  

</xsl:transform>
