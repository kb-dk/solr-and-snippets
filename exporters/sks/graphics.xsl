<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">

  <xsl:import href="../graphics-global.xsl"/>
  
  <xsl:template name="sks_page_specimen">
    <xsl:element name="div">
      <xsl:choose>
        <xsl:when test="$float_graphics">
          <xsl:attribute name="style"> width: 50%; float: <xsl:call-template name="float_direction"/>; clear: both; margin: 2em; </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="style"> width: 90%; clear: both; margin: 2em; </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="add_id"/>

      <xsl:call-template name="render_graphic">
	<xsl:with-param name="graphic_uri">
	  <xsl:value-of 
	      select="substring-before(translate(substring-after(@facs,'../'),$uppercase,$lowercase),'.jpg')"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:figure[@rend]/t:graphic">
    <xsl:if test="@url">
      <xsl:call-template name="render_graphic">
        <xsl:with-param name="width">0</xsl:with-param>
	<xsl:with-param name="graphic_uri">
	  <xsl:value-of 
	      select="substring-before(translate(substring-after(@url,'../'),$uppercase,$lowercase),'.jpg')"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:figure[@rend]">
    <xsl:element name="br">
      <xsl:call-template name="add_id"/>
    </xsl:element>
      <!-- xsl:attribute name="style"> width: 90%; </xsl:attribute -->
      <xsl:apply-templates select="t:graphic"/>
      <xsl:apply-templates select="t:head"/> <xsl:comment> Blablalbabla </xsl:comment>
      <xsl:element name="br"/>
  </xsl:template>
  
  <xsl:template match="t:figure">
    <xsl:element name="div">
      <xsl:choose>
        <xsl:when test="$float_graphics">
          <xsl:attribute name="style"> width: 50%; float: <xsl:call-template name="float_direction"/>; clear: both; margin: 2em; </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="style"> width: 90%; clear: both; margin: 2em; </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:graphic"/>
      <xsl:apply-templates select="t:head"/> <xsl:comment> Bløblølbøblø </xsl:comment>
    </xsl:element>
  </xsl:template>

  <xsl:template name="float_direction">
    <xsl:choose>
      <xsl:when test="count(preceding::t:graphic|preceding::t:pb[@facs]) mod 2">left</xsl:when>
      <xsl:otherwise>right</xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:transform>
