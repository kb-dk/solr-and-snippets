<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="t"
    version="2.0">

  <xsl:variable name="iip_baseuri"  select="'http://kb-images.kb.dk/public/sks/'"/>
  <xsl:variable name="iiif_suffix" select="'/full/full/0/native.jpg'"/>
  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyzæøåöäü'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅÖÄÜ'" />

  <xsl:template name="render_graphic">
    <xsl:param name="graphic_uri"/>
    <xsl:param name="width">100%</xsl:param>

    <xsl:element name="img">
      <xsl:choose>
        <xsl:when test="$width !=  '0'">
          <xsl:attribute name="style"> width: <xsl:value-of select="$width"/>;</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:attribute name="src">
        <xsl:choose>
          <xsl:when test="fn:contains($graphic_uri,'http') and fn:contains($graphic_uri,'jpg')">
            <xsl:value-of select="$graphic_uri"/>
          </xsl:when>
          <xsl:otherwise>
	    <xsl:value-of select="concat($iip_baseuri,$graphic_uri,$iiif_suffix)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
    </xsl:element>

  </xsl:template>

  <xsl:template match="t:graphic">
    <xsl:if test="@url">
      <xsl:call-template name="render_graphic">
	<xsl:with-param name="graphic_uri">
          <xsl:choose>
            <xsl:when test="contains(@url,'http')">
              <xsl:value-of select="@url"/>
            </xsl:when>
            <xsl:otherwise>
	  <xsl:value-of 
	      select="substring-before(translate(substring-after(@url,'../'),$uppercase,$lowercase),'.jpg')"/>
            </xsl:otherwise>
          </xsl:choose>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:figure">
    <xsl:variable name="float_direction">
      <xsl:choose>
	<xsl:when test="count(preceding::t:graphic) mod 2">left</xsl:when>
	<xsl:otherwise>right</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:comment> Here is a figure </xsl:comment>
    <xsl:if test="t:graphic/@url or @type">
      <xsl:element name="div">
	<xsl:attribute name="style"> max-width: 50%; float: <xsl:value-of select="$float_direction"/>; clear: both; margin: 2em; </xsl:attribute>
	<xsl:call-template name="add_id"/>
	<xsl:apply-templates select="t:graphic"/>
	<xsl:apply-templates select="t:head"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:figure/t:head">
    <span  style="clear:both;">
      <xsl:call-template name="add_id"/>
      <small>
	<xsl:apply-templates/>
      </small>
    </span>
  </xsl:template>




</xsl:stylesheet>
