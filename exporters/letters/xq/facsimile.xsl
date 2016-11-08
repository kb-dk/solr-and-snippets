<?xml version="1.0" encoding="UTF-8" ?>
<!--

Author Sigfrid Lundberg slu@kb.dk

Last updated $Date: 2008/06/24 12:56:46 $ by $Author: slu $

$Id: toc.xsl,v 1.2 2008/06/24 12:56:46 slu Exp $

-->
<xsl:transform version="1.0"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	       exclude-result-prefixes="t">

  <xsl:param name="id" select="''"/>
  <xsl:param name="doc" select="''"/>
  <xsl:param name="hostname" select="''"/>

  <!-- this is for image URIs that are not absolute 
       (not starting with http -->

  <xsl:param name="prefix" select="''"/>

  <xsl:output encoding="UTF-8"
	      indent="yes"
	      method="xml"
	      omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$id">
	<xsl:for-each select="//node()[$id=@xml:id]">
	  <div>
	    <xsl:attribute name="id">
	      <xsl:value-of select="concat('facsid',$id)"/>
	    </xsl:attribute>
	    <xsl:attribute name="class">facsimile snippetRoot</xsl:attribute>
	    <xsl:for-each select="preceding::t:pb[1]">
	      <xsl:apply-templates select="."/>
	    </xsl:for-each>
	    <xsl:apply-templates/>
	  </div>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="t:TEI" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="t:TEI">
    <xsl:element name="div">
      <xsl:attribute name="class">snippetRoot</xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:teiHeader|t:front|t:back"/>

  <xsl:template match="*[@xml:id][descendant::t:pb]">
    <xsl:element name="div">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:pb">
    <xsl:element name="div">
      <xsl:call-template name="add_id"/>
      <span class="pageBreak">
	<xsl:element name="a">
	  <xsl:attribute name="href">
	    <xsl:value-of select="concat('#',@xml:id)"/>
	  </xsl:attribute>
	  <xsl:text>s. </xsl:text>
	  <xsl:value-of select="@n"/>
	</xsl:element>
      </span>
      <xsl:call-template name="img_ref"/>
    </xsl:element> 
  </xsl:template>

  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="text()"/>

  <xsl:template name="add_id">
    <xsl:if test="@xml:id">
      <xsl:attribute name="id">
      	<xsl:value-of select="concat('facsid',@xml:id)"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="img_ref">
    <xsl:choose>
      <xsl:when 
	  test="contains(@facs,'http') and not(contains(@rend,'missing'))">
        <xsl:element name="img">
	  <xsl:attribute name="height">750</xsl:attribute>
	  <xsl:attribute name="data-src">
            <xsl:value-of select="@facs"/>
	  </xsl:attribute>
	  <xsl:attribute name="src">
	  </xsl:attribute>
        </xsl:element>
      </xsl:when>
      <xsl:when 
	  test="not(contains(@facs,'http')) and not(contains(@rend,'missing'))">
	<xsl:variable name="facs">
	  <xsl:value-of select="translate(@facs,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
	</xsl:variable>
        <xsl:element name="img">
	  <xsl:attribute name="height">750</xsl:attribute>
	  <xsl:attribute name="data-src">
            <xsl:value-of select="concat($prefix,substring-before(substring-after($facs,'images/'),'.jpg'),'/full/full/0/native.jpg')"/>
	  </xsl:attribute>
          <xsl:attribute name="src">
          </xsl:attribute>
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:transform>

