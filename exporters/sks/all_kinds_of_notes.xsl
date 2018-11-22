<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:me="urn:my-things"
    exclude-result-prefixes="t me"
    version="2.0">

  <xsl:param name="id" select="''"/>
  <xsl:param name="doc" select="''"/>
  <xsl:param name="file" select="fn:replace($doc,'.*/([^/]+)$','$1')"/>
  <xsl:param name="prev" select="''"/>
  <xsl:param name="prev_encoded" select="''"/>
  <xsl:param name="next" select="''"/>
  <xsl:param name="next_encoded" select="''"/>
  <xsl:param name="c" select="''"/>
  <xsl:param name="hostname" select="''"/>
  <xsl:param name="hostport" select="''"/>
  <xsl:param name="adl_baseuri">
    <xsl:choose>
      <xsl:when test="$hostport">
	<xsl:value-of select="concat('http://',$hostport)"/>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="facslinks" select="''"/>
  <xsl:param name="path" select="''"/>
  <xsl:param name="capabilities" select="''"/>
  <xsl:param name="cap" select="document($capabilities)"/>

  <xsl:import href="../all_kinds_of_notes-global.xsl"/>

  <xsl:output method="xml"
	      encoding="UTF-8"
	      indent="yes"/>

  <xsl:template name="make_author_note_list">
    <xsl:for-each select="descendant-or-self::ptr[@type='author']">
      <xsl:if test="position() = 1"><hr/></xsl:if>
      <xsl:call-template name="show_note">
	<xsl:with-param name="display" select="'block'"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="t:ptr[@type = 'author']">
    <xsl:variable name="target">
      <xsl:value-of select="substring-after(@target,'#')"/>
    </xsl:variable>
    <xsl:for-each select="/t:TEI//t:note[@xml:id = $target]">
      <xsl:call-template name="inline_note"/>
    </xsl:for-each>
  </xsl:template>




</xsl:stylesheet>