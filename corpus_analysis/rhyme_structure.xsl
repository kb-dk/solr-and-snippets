<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:t="http://www.tei-c.org/ns/1.0"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               exclude-result-prefixes="xsl t"
               version="2.0">

  <xsl:output method="text"
             
              omit-xml-declaration="yes"
              encoding="UTF-8"/>

  <xsl:param name="print_position" select="''"/>
  <xsl:param name="file_name" select="''"/>
  <xsl:param name="work_id"   select="''"/>

<xsl:template match="/">
# <xsl:value-of select="$file_name"/><xsl:text> </xsl:text><xsl:value-of select="$work_id"/><xsl:text>
</xsl:text><xsl:for-each select="//t:div[@xml:id = $work_id]">
<xsl:variable name="line" as="xs:string *">  
<xsl:for-each select=".//t:l/string()"><xsl:value-of select="."/></xsl:for-each>
</xsl:variable>
<xsl:for-each select="$line">
<xsl:if test="$print_position"><xsl:value-of select="position()"/><xsl:text> --- </xsl:text></xsl:if><xsl:value-of select="."/><xsl:text>
</xsl:text></xsl:for-each>
</xsl:for-each>
</xsl:template>

</xsl:transform>
