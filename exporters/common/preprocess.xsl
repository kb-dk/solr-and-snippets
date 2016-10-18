<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform 
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

  <xsl:output method="xml"
	      indent="yes"
	      encoding="UTF-8"/>


  <xsl:template match="t:*">
    <xsl:element name="{name()}">
      <xsl:if test="not(@xml:id)">
        <xsl:attribute name="xml:id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template>

</xsl:transform>
