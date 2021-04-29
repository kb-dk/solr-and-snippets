<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xmlns:me="urn:my-things"
	       exclude-result-prefixes="me t fn math xsl">


  <xsl:function name="me:paragraph-style">
    <xsl:param name="style" />
    <xsl:choose>
      <xsl:when test="$style = 'noIndent'">text-indent: 0em;</xsl:when>
      <xsl:when test="$style = 'firstIndent'">text-indent: 2em;</xsl:when>
      <xsl:when test="$style = 'secondIndent'">text-indent: 4em;</xsl:when>
      <xsl:when test="$style = 'thirdIndent'">text-indent: 6em;</xsl:when>
      <xsl:when test="$style = 'center'">text-align: center;</xsl:when>
      <xsl:when test="$style = 'right'">text-align: right;</xsl:when>
      <xsl:when test="$style = 'firstIndentRight'">margin-right: 2em; text-align: right;</xsl:when>
      <xsl:when test="$style = 'secondIndentRight'">margin-right: 4em; text-align: right;</xsl:when>
      <xsl:when test="$style = 'thirdIndentRight'">margin-right: 6em; text-align: right;</xsl:when>
      <xsl:when test="$style = 'hangingIndent'">text-indent: -1em; padding-left: 1em;</xsl:when>
      <xsl:when test="$style = 'hangingIndentPro'">line-height: 200%; text-align: justify; text-indent: -1em; padding-left: 2em;</xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="me:line-style"> 
    <xsl:param name="style" />
    <xsl:choose>
     <xsl:when test="$style = 'blank'">margin: 2em 0em 2em 0em;</xsl:when>
     <xsl:when test="$style = 'center'">text-align: center;</xsl:when>
     <xsl:when test="$style = 'firstIndent'">text-indent: 1em; text-align: left;</xsl:when>
     <xsl:when test="$style = 'secondIndent'">text-indent: 2em; text-align: left;</xsl:when>
     <xsl:when test="$style = 'thirdIndent'">text-indent: 4em; text-align: left;</xsl:when>
     <xsl:when test="$style = 'fourthIndent'">text-indent: 6em;</xsl:when>
     <xsl:when test="$style = 'right'">text-align: right;</xsl:when>
     <xsl:when test="$style = 'firstIndentRight'">text-indent: 1em; text-align: right;</xsl:when>
     <xsl:when test="$style = 'secondIndentRight'">text-indent: 2em; text-align: right;</xsl:when>
     <xsl:when test="$style = 'thirdIndentRight'">text-indent: 4em; text-align: right;</xsl:when>
     <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:transform>
