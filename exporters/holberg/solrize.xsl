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

  <xsl:param name="worktitle">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[not(@level) and not(@type)]">
      <xsl:apply-templates mode="gettext"  select="."/>
    </xsl:for-each>
  </xsl:param>

  <xsl:template match="t:text">
    <xsl:variable name="dir_path" select="substring-before($doc,'/')"/>
    <xsl:variable name="file_basename" select="substring-before(substring-after($doc,'/'),'.xml')"/>
    <xsl:comment><xsl:value-of select="$worktitle"/></xsl:comment>
    <xsl:comment><xsl:value-of select="$volume_title"/></xsl:comment>
    <xsl:call-template name="trunk_doc">
      <xsl:with-param name="worktitle" select="$worktitle"/>
      <xsl:with-param name="category">
	<xsl:if test="$dir_path = $file_basename">work</xsl:if>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:apply-templates>

  </xsl:template>



</xsl:transform>