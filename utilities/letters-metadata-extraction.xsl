<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:t="http://www.tei-c.org/ns/1.0"
               version="1.0">

  <xsl:output method="text"/>
  <xsl:param name="file" select="''"/>
  
  <xsl:variable name="year_limit" select="'1922'"/>

  <xsl:template match="/">
    <xsl:variable name="date">
      <xsl:apply-templates select="/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt/t:date"/>
    </xsl:variable>
<xsl:value-of select="$date"/>,<xsl:choose><xsl:when test="$date&lt;$year_limit">YES</xsl:when><xsl:otherwise>NO</xsl:otherwise></xsl:choose>,<xsl:value-of select="$file"/><xsl:text>
</xsl:text>    
  </xsl:template>
  
</xsl:transform>
