<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">
  
<!--

Author Sigfrid Lundberg slu@kb.dk

-->

  <xsl:import href="../toc-global.xsl"/>

  <xsl:variable name="sks_acronym" select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[@type='short']"/>
  
  <xsl:template match="/t:TEI">
    <div>
      <xsl:apply-templates mode="get_lists" select="./t:text"/>
    </div>
  </xsl:template>

  <xsl:template match="t:teiHeader"/>

  <xsl:template  mode="get_lists" match="*"></xsl:template>
  
  <xsl:template  mode="get_lists" match="t:group|t:body|t:text|t:div|t:lg|t:front|t:back">
    <xsl:choose>
      <xsl:when test="@decls|./t:head[node()]|./t:p">
        <xsl:variable name="item">
          <xsl:call-template name="add_anchor"/>
        </xsl:variable>

        <xsl:variable name="date_number">
          <xsl:for-each select="t:dateline">
            <strong>
              <xsl:if test="../@n">
	        <xsl:if test="$sks_acronym"><xsl:value-of select="$sks_acronym"/>:</xsl:if><xsl:value-of select="../@n"/>
              </xsl:if>
            </strong>
          </xsl:for-each>
        </xsl:variable>
        
        <xsl:if test="string-length($item) &gt; 0">
          <li>
            <xsl:attribute name="id">
	      <xsl:value-of select="concat('list-',@xml:id)"/>
            </xsl:attribute>
            <xsl:copy-of select="$date_number"/><xsl:text> </xsl:text><xsl:call-template name="add_anchor"/>
          </li>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test=".//t:group|.//t:body|.//t:text|.//t:div">
          <ul><xsl:apply-templates mode="get_lists"/></ul>
        </xsl:if>     
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:transform>
