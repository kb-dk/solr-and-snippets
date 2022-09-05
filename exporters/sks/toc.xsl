<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">
  
<!--

Author Sigfrid Lundberg slu@kb.dk

-->

  <xsl:import href="../toc-global.xsl"/>

  <xsl:param name="id" select="''"/>
  <xsl:param name="doc" select="''"/>
  <xsl:param name="path" select="''"/>
  <xsl:param name="targetOp" select="''"/>
  <xsl:param name="hostname" select="''"/>
  
  <xsl:variable name="sks_acronym" select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[@type='short']"/>
  
  <xsl:template match="/t:TEI">
    <div>
      <ul><xsl:apply-templates mode="get_lists" select="./t:text"/></ul>
    </div>
  </xsl:template>

  <xsl:template match="t:teiHeader"/>

  <xsl:template  mode="get_lists" match="*"></xsl:template>
  
  <xsl:template  mode="get_lists" match="t:group|t:body|t:text|t:div|t:lg|t:front|t:back">
    
      <xsl:if test="./t:head|./t:p|./t:l">

        <xsl:variable name="date_number">
          <xsl:for-each select="t:dateline">
            <strong>
              <xsl:if test="../@n">
	        <xsl:if test="$sks_acronym"><xsl:value-of select="$sks_acronym"/>:</xsl:if><xsl:value-of select="../@n"/>
              </xsl:if>
            </strong>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="content">
          <xsl:call-template name="add_anchor"/>
        </xsl:variable>

        <xsl:if test="$content//text()">
          <li>
            <xsl:attribute name="id">
	      <xsl:value-of select="concat('list-',@xml:id)"/>
            </xsl:attribute>
              <xsl:copy-of select="$date_number"/><xsl:text> </xsl:text> <xsl:copy-of select="$content"/>
          </li>
        </xsl:if>

         
      </xsl:if>

      <xsl:if test="./t:group|./t:body|./t:text|./t:div">
        <ul><xsl:apply-templates mode="get_lists" select="./t:group|./t:body|./t:text|./t:div"/></ul>
      </xsl:if>

  </xsl:template>

  <xsl:template name="add_anchor">
  
    <xsl:variable name="title">
      <xsl:choose>
	<xsl:when test="t:head">
          <xsl:for-each select="t:head[@type='workHeader' or @type='letterHeader' or @type='topText'][1]">
            <xsl:choose>
              <xsl:when test="@n"><xsl:apply-templates select="@n"/></xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:variable name="some_text">
	    <xsl:call-template name="some_text"/>
	  </xsl:variable>
	  <xsl:value-of
	      select="substring(normalize-space($some_text/string()),1,30)"/>
	  <xsl:if test="string-length(normalize-space($some_text/string())) &gt; 30"><xsl:text>...</xsl:text></xsl:if>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="href"><xsl:call-template name="make_href"/></xsl:variable>

    <xsl:if test="string-length($title) &gt; 0">
      <xsl:element name="a">
        <xsl:attribute name="href">
	  <xsl:call-template name="make_href"/>
        </xsl:attribute>
        <xsl:value-of select="$title"/>
      </xsl:element>
    </xsl:if>

  </xsl:template>

  <xsl:template name="some_text">
    <xsl:variable name="head_text">
      <xsl:for-each select=".//t:head[node()]">
        <xsl:apply-templates/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test=".//t:head[node()]">
        <xsl:value-of select="$head_text"/> 
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test=".//text()">
            <xsl:value-of select=".//text()"/> 
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="following::text()"/> 
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="t:app">
    <xsl:apply-templates  select="t:lem//text()"/> 
  </xsl:template>

  
</xsl:transform>
