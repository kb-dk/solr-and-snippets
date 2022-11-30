<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:t="http://www.tei-c.org/ns/1.0"
               version="1.0">

  <xsl:output method="text"/>
  <xsl:param name="file" select="''"/>
  
  <xsl:variable name="year_limit" select="'1922'"/>

  <xsl:template match="/">
    <xsl:variable name="date_in" select="/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt/t:date"/>
    <xsl:variable name="date">
      <xsl:choose>
        <xsl:when test="contains($date_in,'/18')">
          <xsl:value-of select="substring-after($date,'/')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$date_in"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
<xsl:value-of select="$date"/>,<xsl:choose><xsl:when test="$date&lt;$year_limit">YES</xsl:when><xsl:otherwise>NO</xsl:otherwise></xsl:choose>,<xsl:value-of select="$file"/>,<xsl:value-of select="/t:TEI/@status"/><xsl:text>
</xsl:text>    
  </xsl:template>
  
</xsl:transform>
