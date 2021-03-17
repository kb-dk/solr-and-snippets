<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       exclude-result-prefixes="t">

  
  <xsl:import href="../render-global.xsl"/>
  <xsl:import href="../apparatus-global.xsl"/>
  <xsl:import href="../graphics-global.xsl"/>
  <xsl:import href="../all_kinds_of_notes-global.xsl"/>
  <xsl:import href="./ornament.xsl"/>

  <xsl:template name="page_specimen">
  </xsl:template>

  <xsl:template match="t:seg[@type='com']"><xsl:variable name="href">
      <xsl:value-of select="concat(fn:replace($path,'txt-((root)|(shoot).*$)','com-root#'),@n)"/>
      </xsl:variable><a class="comment" title="Kommentar" id="{@n}" href="{$href}"><span class="symbol comment"><span class="debug comment-stuff">&#9658;</span></span><xsl:text>&#160;</xsl:text><span class="comment"><xsl:apply-templates/></span></a></xsl:template>

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

  
  <xsl:template match="t:persName|t:placeName|t:rs[@type='myth']|t:rs[@type='title']|t:rs[@type='bible']">
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
      <span class="symbol {$entity}"><span class="debug {$authority}-stuff"><xsl:value-of select="$symbol"/></span></span><xsl:text>&#160;</xsl:text>
<xsl:apply-templates/>

      <xsl:if test="@key"><xsl:comment> key = <xsl:value-of select="@key"/> </xsl:comment></xsl:if>
      
    </xsl:element>

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
