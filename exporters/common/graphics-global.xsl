<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="t"
    version="2.0">

  <xsl:template match="t:graphic">
    <xsl:element name="img">
      <xsl:variable name="url">
      <xsl:value-of select="concat($iip_baseuri,substring-before(translate(substring-after(@url,'../'),$uppercase,$lowercase),'.jpg'))"/>
      </xsl:variable>
      <xsl:attribute name="style"> width: 100%;</xsl:attribute>
      <xsl:attribute name="src">
	<xsl:value-of select="concat($url,$iiif_suffix)"/>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
    </xsl:element>
  </xsl:template>

 <xsl:template match="t:figure">
   <xsl:variable name="float_direction">
     <xsl:choose>
       <xsl:when test="count(preceding::t:graphic) mod 2">left</xsl:when>
       <xsl:otherwise>right</xsl:otherwise>
     </xsl:choose>
   </xsl:variable>
   <xsl:element name="div">
      <xsl:attribute name="style"> max-width: 50%; float: <xsl:value-of select="$float_direction"/>; clear: both; margin: 2em; </xsl:attribute>
     <xsl:call-template name="add_id"/>
     <xsl:apply-templates select="t:graphic"/>
     <xsl:apply-templates select="t:head"/>
   </xsl:element>
 </xsl:template>

  <xsl:template match="t:figure/t:head">
    <p>
      <xsl:call-template name="add_id"/>
      <small>
	<xsl:apply-templates/>
      </small>
    </p>
  </xsl:template>




</xsl:stylesheet>