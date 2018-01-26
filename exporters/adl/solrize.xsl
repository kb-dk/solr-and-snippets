<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">
  
  <xsl:import href="../solrize-global.xsl"/>


  <xsl:param name="editor" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:respStmt">
      <xsl:for-each select="t:resp">
	<xsl:apply-templates mode="gettext"  select="."/><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:param>

 <xsl:param name="volume_title">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title[1]">
      <xsl:apply-templates mode="gettext"  select="."/>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="volume_sort_title">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title[1]">
      <xsl:call-template name="volume_sort_title"/>
    </xsl:for-each>
  </xsl:param>

</xsl:transform>