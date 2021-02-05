<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       xmlns:me="urn:my-things"
	       exclude-result-prefixes="t fn me">
  
  <xsl:import href="../solrize-global.xsl"/>

  <xsl:param name="subcollection" select="'adl'"/>

  <xsl:param name="editor" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:respStmt">
      <xsl:for-each select="t:resp">
	<xsl:apply-templates mode="gettext"  select="."/><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:param>

 <xsl:param name="volume_title">
   <xsl:choose>
     <xsl:when test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title[text()]">
       <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title">
	 <xsl:apply-templates mode="gettext"  select="."/>
       </xsl:for-each>
     </xsl:when>
     <xsl:otherwise>
       <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title">
	 <xsl:apply-templates mode="gettext"  select="."/>
       </xsl:for-each>
     </xsl:otherwise>
   </xsl:choose>
  </xsl:param>

  <xsl:param name="volume_sort_title">
    <xsl:choose>
      <xsl:when test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title[text()]">
	<xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title">
	  <xsl:call-template name="volume_sort_title"/>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title">
	  <xsl:call-template name="volume_sort_title"/>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:template name="is_editorial">
    <xsl:choose>
      <xsl:when test="contains($path,'adl-authors')">yes</xsl:when>
      <xsl:when test="contains($path,'adl-periods')">yes</xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="ancestor-or-self::node()[@decls][1]">no</xsl:when>
          <xsl:otherwise>yes</xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="get_category">
    <xsl:choose>
      <xsl:when test="contains($path,'adl-texts')">work</xsl:when>
      <xsl:when test="contains($path,'adl-authors')">author</xsl:when>
      <xsl:when test="contains($path,'adl-periods')">period</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="what_i_can"/>

</xsl:transform>
