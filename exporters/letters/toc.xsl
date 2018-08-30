<?xml version="1.0" encoding="UTF-8" ?>
<!--

Author Sigfrid Lundberg slu@kb.dk

Last updated $Date: 2008/06/24 12:56:46 $ by $Author: slu $

$Id: toc.xsl,v 1.2 2008/06/24 12:56:46 slu Exp $

-->
<xsl:transform version="1.0"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	       exclude-result-prefixes="t">

  <xsl:param name="id" select="''"/>
  <xsl:param name="doc" select="''"/>
  <xsl:param name="hostname" select="''"/>

  <xsl:output encoding="UTF-8"
	      indent="yes"
	      method="xml"
	      omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <div>
      <ul>
	<xsl:choose>
	  <xsl:when test="$id">
	    <xsl:apply-templates select="//node()[@xml:id=$id]"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:choose>
	      <xsl:when test="./t:div|./t:text">
		<xsl:apply-templates select="./t:div|./t:text"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:apply-templates/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:otherwise>
	</xsl:choose>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="t:teiHeader|t:front|t:back"/>

  <xsl:template match="t:group|t:text[not(t:head)]|t:body">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:text[t:head]|t:div">
    <xsl:element name="li">
      <xsl:attribute name="id">
	<xsl:value-of select="concat('toc',@xml:id)"/>
      </xsl:attribute>

      <xsl:call-template name="add_anchor"/>
      <xsl:if test="t:text|t:div">
	<ul>
	  <xsl:apply-templates
	      select="t:text|t:div"/>
	</ul>
      </xsl:if>
    </xsl:element>

  </xsl:template>

  <xsl:template match="t:p">
  </xsl:template>

  <xsl:template match="t:head">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:lb">
    <xsl:text> 
    </xsl:text>
  </xsl:template>

  <xsl:template match="t:hi">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="add_anchor">
    <xsl:element name="a">
      <xsl:attribute name="href">
	<xsl:value-of select="concat('#',@xml:id)"/>
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

