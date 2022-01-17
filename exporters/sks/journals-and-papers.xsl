<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">

  <xsl:template match="t:text[@type='ms' and subtype='journalsAndPapers']">
    <xsl:comment> text </xsl:comment>
    <div>
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:div[@type='entry']">
    <div>
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:comment> div here <xsl:value-of select="@decls"/> </xsl:comment>
      <xsl:apply-templates/>
      <div style="clear: all;">

      </div>
    </div>
  </xsl:template>

  <xsl:template match="t:div[@type='mainColumn']">
    <div style="width:50%; float left;">
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:comment> div here <xsl:value-of select="@decls"/> </xsl:comment>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:div[@type='marginalColumn']">
    <div style="width:50%; float left;">
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:comment> div here <xsl:value-of select="@decls"/> </xsl:comment>
      <xsl:apply-templates/>
    </div>
  </xsl:template>


</xsl:transform>
