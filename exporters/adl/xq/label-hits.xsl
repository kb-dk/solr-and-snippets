<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform 
    xmlns:str="java:java.lang.String"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

  <xsl:param name="q" select="''"/>

  <xsl:output method="xml"
              indent="yes"
              encoding="UTF-8"/>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template>

  <xsl:template  match="text()">

    <xsl:choose>
      <xsl:when test="$q">
	<xsl:choose>
	  <xsl:when test="contains(.,$q)">
	    <xsl:call-template name="hi-liter">
	      <xsl:with-param name="text" select="."/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:copy-of select="."/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="hi-liter">
    <xsl:param name="text" select="''"/>
    <xsl:if test="contains($text,$q)">
      <xsl:value-of select="substring-before($text,$q)"/>
      <span style="background-color:rgb(255,255,128);" class="hi-lited-hit" ><xsl:value-of select="$q"/></span>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="substring-after($text,$q)">
	<xsl:call-template name="hi-liter">
	  <xsl:with-param name="text" select="substring-after($text,$q)"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:transform>