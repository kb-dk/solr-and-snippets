<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	       exclude-result-prefixes="t fn math xsl">

  
  <xsl:import href="../render-global.xsl"/>
  <xsl:import href="../apparatus-global.xsl"/>
  <xsl:import href="../graphics-global.xsl"/>
  <xsl:import href="../all_kinds_of_notes-global.xsl"/>
  <xsl:import href="./ornament.xsl"/>
  <xsl:import href="./block-styles.xsl"/>

  <xsl:template name="page_specimen">
  </xsl:template>

  <xsl:template match="t:seg[@type='com']|t:seg[@type='comStart']|t:seg[@type='comEnd']"><xsl:variable name="href"><xsl:value-of select="concat(fn:replace($path,'txt-((root)|(shoot).*$)','com-root#'),@n)"/></xsl:variable><xsl:element name="a"><xsl:attribute name="class">comment</xsl:attribute><xsl:attribute name="title">Kommentar</xsl:attribute><xsl:attribute name="id"><xsl:value-of select="@n"/></xsl:attribute><xsl:attribute name="href"><xsl:value-of select="$href"/></xsl:attribute><span class="symbol comment"><span class="debug comment-stuff">&#9658;</span></span><xsl:comment> bla bla bla </xsl:comment><span class="comment"><xsl:apply-templates/></span></xsl:element></xsl:template>

  <xsl:template name="inline_note">
    <xsl:call-template name="general_note_code">
      <xsl:with-param name="display" select="'inline'"/>
      </xsl:call-template><xsl:call-template name="show_note">
      <xsl:with-param name="display" select="'inline'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="t:row[t:cell[@rend='popUp']]">
    <tr>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:cell[@rend='popUp']"/>
    </tr>
  </xsl:template>

  
  <xsl:template match="t:head">
    <xsl:if test="./node()">
      <h2 class="head-in-text">
	<xsl:call-template name="add_id"/>
          <xsl:attribute name="style">
            <xsl:if test="number(@rend)">            
              font-size: <xsl:value-of select="100*math:pow(1.2,@rend)"/> %;
            </xsl:if>
            text-align: center;
          </xsl:attribute>
	<xsl:apply-templates/>
      </h2>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:hi[@rend='romanType']">
    <span style="font-family:serif;"><xsl:call-template name="add_id"/><xsl:apply-templates/></span>
  </xsl:template>
  
  <xsl:template name="make-href">

    <xsl:variable name="target">
      <xsl:value-of select="translate(@n,$uppercase,$lowercase)"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="contains($path,'-txt')">
	<xsl:value-of 
	    select="concat(substring-before($path,'-txt'),'-com-shoot-',$target)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$target"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="t:app">
    <xsl:choose>
      <xsl:when test="@select">
        <xsl:choose>
          <xsl:when test="contains(@select,'yes')">
            <xsl:call-template name="app-root"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="text" select="t:lem"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="app-root"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="t:persName|
                       t:placeName|
                       t:rs[@type='myth']|
                       t:rs[@type='title']|
                       t:rs[@type='bible']">
    <xsl:variable name="entity">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">person</xsl:when>
        <xsl:when test="contains(local-name(.),'place')">place</xsl:when>
        <xsl:when test="@type='myth'">mytologi</xsl:when>
        <xsl:when test="@type='bible'">Bibel</xsl:when>
	<xsl:otherwise>comment</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="authority">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">pers</xsl:when>
        <xsl:when test="contains(local-name(.),'place')">place</xsl:when>
        <xsl:when test="@type='myth'">myth</xsl:when>
        <xsl:when test="@type='bible'">bible</xsl:when>
	<xsl:otherwise>title</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="symbol">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">&#128100;</xsl:when>
	<xsl:when test="contains(local-name(.),'place')">&#128204;</xsl:when>
        <xsl:otherwise>&#9658;</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title">
        <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">Person</xsl:when>
        <xsl:when test="contains(local-name(.),'place')">Plads</xsl:when>
        <xsl:when test="@type='myth'">Mytologi</xsl:when>
        <xsl:when test="@type='bible'">Bibel</xsl:when>
	<xsl:otherwise>Titel</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="key"><xsl:value-of select="@key"/></xsl:variable>
    <xsl:variable name="uri">
      <xsl:value-of select="concat('gv-registre-',$authority,'-shoot-',$key,'#',$key)"/>
    </xsl:variable>

    <xsl:element name="a">
      <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      <xsl:attribute name="class">
        <xsl:value-of select="$entity"/>
      </xsl:attribute>

      <xsl:attribute name="title">
        <xsl:choose>
          <xsl:when test="contains($title,'Bibel')"><xsl:value-of select="@key"/></xsl:when>
          <xsl:otherwise>
	    <xsl:value-of select="$title"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
        
      <xsl:attribute name="data-toggle">modal</xsl:attribute>
      <xsl:attribute name="data-target">#comment_modal</xsl:attribute>
      <xsl:if test="not(contains(@type,'bible'))">
        <xsl:attribute name="href">
          <xsl:value-of select="$uri"/>
        </xsl:attribute>
      </xsl:if>
      <span class="symbol {$entity}"><span class="debug {$authority}-stuff"><xsl:value-of select="$symbol"/></span></span><xsl:comment> blæ blæ blæ </xsl:comment>

      <span class="{$authority}">
        <xsl:apply-templates/>
      </span>

      <xsl:if test="@key"><xsl:comment> key = <xsl:value-of select="@key"/> </xsl:comment></xsl:if>
      
    </xsl:element>

  </xsl:template>

  <xsl:template match="t:pb[@type='edition']">

    <xsl:variable name="witness">
      <xsl:value-of select="@ed"/>
    </xsl:variable>

    <xsl:if test="@n">
      <xsl:element name="a">
	<xsl:attribute name="title">Side: <xsl:value-of select="@n"/> <xsl:if test="@ed">(<xsl:value-of select="@ed"/>)</xsl:if></xsl:attribute>
	<xsl:attribute name="class">pagination</xsl:attribute>
	<xsl:attribute name="href"><xsl:value-of select="concat('#',@xml:id)"/></xsl:attribute>
	<xsl:call-template name="add_id"/>

	<xsl:variable name="class">symbol pagination other</xsl:variable>

	<xsl:element name="small">
	  <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
	  <xsl:value-of select="@n"/>
	</xsl:element>
      </xsl:element>
      <xsl:text> 
      </xsl:text>
    </xsl:if>

  </xsl:template>

  <xsl:template match="t:row[@role]">
    <div>
      <xsl:call-template name="add_id"/>
      <xsl:for-each select="t:cell">
        <xsl:apply-templates/><xsl:text>
</xsl:text></xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="t:cell[@rend='name']/t:note">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:cell[@rend='year']/text()">
    (<xsl:value-of select="."/>)
  </xsl:template>

  

  
</xsl:transform>
