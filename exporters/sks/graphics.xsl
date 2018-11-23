<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">


  <xsl:import href="../graphics-global.xsl"/>

  <xsl:template name="sks_page_specimen">
    <xsl:element name="div">
      <xsl:attribute name="style"> max-width: 50%; float: <xsl:call-template name="float_direction"/>; clear: both; margin: 2em; </xsl:attribute>
      <xsl:call-template name="add_id"/>

      <xsl:call-template name="render_graphic">
	<xsl:with-param name="graphic_uri">
	  <xsl:value-of 
	      select="concat(substring-before(translate(substring-after(@facs,'../'),$uppercase,$lowercase),'.jpg'))"/>
	</xsl:with-param>
      </xsl:call-template>

    </xsl:element>
  </xsl:template>

  <xsl:template match="t:figure">
    <xsl:element name="div">
      <xsl:attribute name="style"> max-width: 50%; float: <xsl:call-template name="float_direction"/>; clear: both; margin: 2em; </xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:graphic"/>
      <xsl:apply-templates select="t:head"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="float_direction">
    <xsl:choose>
      <xsl:when test="count(preceding::t:graphic|preceding::t:pb[@facs]) mod 2">left</xsl:when>
      <xsl:otherwise>right</xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:transform>