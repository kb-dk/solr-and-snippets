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

  <xsl:template match="t:seg[@type='com']">
    <xsl:variable name="href">
      <xsl:value-of select="concat(fn:replace($path,'txt-((root)|(shoot).*$)','com-root#'),@n)"/>
    </xsl:variable>
    <a class="comment" title="Kommentar" id="{@n}" href="{$href}"><span class="symbol comment">&#9658;</span></a>  <span class="comment"><xsl:apply-templates/><xsl:text>
  </xsl:text>
</span>
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


  <xsl:template match="t:persName|t:placeName">
    <xsl:variable name="entity">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">person</xsl:when>
	<xsl:otherwise>place</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="authority">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">pers</xsl:when>
	<xsl:otherwise>place</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="symbol">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">&#128100;</xsl:when>
	<xsl:otherwise>&#128204;</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">Person</xsl:when>
	<xsl:otherwise>Plads</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <span class="{$entity}">
      <xsl:variable name="key"><xsl:value-of select="@key"/></xsl:variable>
      <xsl:variable name="uri">
        <xsl:value-of select="concat('gv-registre-',$authority,'-shoot-',$key,'#',$key)"/>
      </xsl:variable>
      <xsl:attribute name="title">
	<xsl:value-of select="$title"/><xsl:if test="@key">: <xsl:value-of select="@key"/></xsl:if>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
      
      <a class="{$entity}" title="Kommentar" href="{$uri}" data-toggle="modal" data-target="#comment_modal">
        <span class="symbol {$entity}"><xsl:value-of select="$symbol"/></span>
      </a>      

      <xsl:apply-templates/>
      
    </span>
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
