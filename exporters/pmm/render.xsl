<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">
  
  <xsl:import href="../render-global.xsl"/>
  <xsl:import href="../apparatus-global.xsl"/>
  <xsl:import href="../graphics-global.xsl"/>
  <xsl:import href="../all_kinds_of_notes-global.xsl"/>

  <xsl:param name="publisher" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt/t:authority">
      <xsl:apply-templates mode="gettext"  select="."/><xsl:if test="position() &lt; last()">; </xsl:if>
    </xsl:for-each>
  </xsl:param>

  <xsl:template match="t:pb">
    <xsl:variable name="first">
      <xsl:value-of select="count(preceding::t:pb[@facs])"/>
    </xsl:variable>

    <xsl:if test="@facs and $first &gt; 0">
      <xsl:element name="span">
	<xsl:attribute name="title">Side <xsl:value-of select="@n"/></xsl:attribute>
	<xsl:call-template name="add_id_empty_elem"/>
	<xsl:attribute name="class">pageBreak</xsl:attribute>
	<xsl:if test="@n">
	  <xsl:element name="a">
	    <small><xsl:value-of select="@n"/></small>
	  </xsl:element>
	</xsl:if>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:ref[@type='commentary']">
    <xsl:element name="a">
      <xsl:attribute name="href">
	<xsl:call-template name="inferred_path">
	  <xsl:with-param name="document" select="@target"/>
	</xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="inferred_path">
    <xsl:param name="document" select="$doc"/>
    <xsl:variable name="frag">
      <xsl:choose>
	<xsl:when test="contains($document,'#')">
	  <xsl:value-of select="fn:replace($document,'^(.*#)','')"/>
	</xsl:when>
	<xsl:otherwise>root</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="first"><xsl:value-of select="fn:replace($doc,'/.*$','')"/></xsl:variable>
    <xsl:variable name="last"><xsl:value-of select="fn:replace($document,'^(.*?).xml#(.*)$','$1')"/></xsl:variable>
   
    <xsl:value-of select="concat($c,'-',$first,'-',$last,'-root','#',$frag)"/>

  </xsl:template>

  <xsl:template match="t:note[@type='commentary']">
    <xsl:element name="p">
      <xsl:call-template name="add_id_empty_elem"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="make-href">
    <xsl:call-template name="inferred_path">
      <xsl:with-param name="document" select="@target"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="t:note">
    <xsl:call-template name="inline_note"/>
  </xsl:template>

</xsl:transform>
