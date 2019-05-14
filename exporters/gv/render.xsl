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

  <xsl:template match="t:pb">
    <xsl:element name="span">
      <!-- xsl:if test="contains(@ed,'A')">
	<xsl:attribute name="class">pageBreak</xsl:attribute>
      </xsl:if>
      <xsl:call-template name="add_id"/>
      <xsl:if test="@facs">
	<xsl:call-template name="page_specimen"/>
      </xsl:if>
      <xsl:choose>
	<xsl:when test="@n and contains(@ed,'A')"><a><small><xsl:value-of select="@n"/></small></a></xsl:when>
	<xsl:otherwise>
	  <xsl:text>an invisible anchor</xsl:text><xsl:comment>sigh!</xsl:comment>
	</xsl:otherwise>
      </xsl:choose -->
    <xsl:comment>sigh!</xsl:comment>
    </xsl:element>
  </xsl:template>

  <xsl:template name="page_specimen">
  </xsl:template>

  <xsl:template match="t:seg[@type='com']">
    <xsl:variable name="href">
      <xsl:value-of select="concat(fn:replace($path,'txt-((root)|(shoot).*$)','com-root#'),@n)"/>
    </xsl:variable>
    <a class="comment" title="Kommentar" id="{@n}" href="{$href}"><span class="symbol comment">&#9658;</span> <xsl:apply-templates/></a>
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


</xsl:transform>
