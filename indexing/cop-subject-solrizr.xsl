<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:m="http://www.loc.gov/mods/v3"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:o="http://a9.com/-/spec/opensearch/1.1/"
	       xmlns:e="http://exslt.org/common"
	       version="1.0">

  <xsl:param name="base" select="''"/>
  <xsl:param name="solr_baseurl" select="''"/>
  <xsl:param name="uri" select="''"/>
  <xsl:param name="spotlight_exhibition" select="''"/>

  <xsl:output method="text"/>
  <xsl:param name="hits">
    <xsl:value-of select="/rss/channel/o:totalResults"/>
  </xsl:param>
  <xsl:param name="perPage">
    <xsl:value-of select="/rss/channel/o:itemsPerPage"/>
  </xsl:param>

  <xsl:param name="doc">
    <xsl:choose>
      <xsl:when test="$hits &gt; $perPage">
	<xsl:copy-of select="document(concat($uri,'?format=rss&amp;itemsPerPage=',$hits))"/> 
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="/"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:template match="/rss">
    <xsl:apply-templates select="e:node-set($doc)//channel"/>
  </xsl:template>

<xsl:template match="channel">
<xsl:for-each select="item">
<xsl:apply-templates select="m:mods"/>
</xsl:for-each>
</xsl:template>

<xsl:template match="m:mods">
GET "<xsl:value-of select="$base"/><xsl:value-of select="m:recordInfo/m:recordIdentifier"/>?solr_baseurl=<xsl:value-of select="$solr_baseurl"/>&amp;spotlight_exhibition=<xsl:value-of select="$spotlight_exhibition"/><xsl:text>"
</xsl:text></xsl:template>

</xsl:transform>