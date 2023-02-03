<?xml version="1.0" encoding="UTF-8" ?>
<!--

Author Sigfrid Lundberg slu@kb.dk
Last updated $Date: 2008/06/24 12:56:46 $ by $Author: slu $
$Id: toc.xsl,v 1.2 2008/06/24 12:56:46 slu Exp $

-->
<xsl:transform version="2.0"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       exclude-result-prefixes="t fn">

  <xsl:param name="id"   select="''"/>
  <xsl:param name="path" select="''"/>
  <xsl:param name="c"    select="''"/>
  <xsl:param name="doc"  select="''"/>
  <xsl:param name="hostname" select="''"/>

  <!-- this is for image URIs that are not absolute 
       (not starting with http -->

  <xsl:param name="prefix" select="'http://kb-images.kb.dk/public/'"/>
  
  <xsl:param name="processed_prefix">
    <choose>
      <xsl:choose>
        <xsl:when test="contains($c,'gv')">
          <xsl:value-of select="concat($prefix,'tekstportal/gv/')"/>
        </xsl:when>
        <xsl:when test="contains($c,'tfs')">
          <xsl:value-of select="concat($prefix,'tekstportal/tfs/')"/>
        </xsl:when>
        <xsl:when test="contains($c,'lh')">
          <xsl:value-of select="concat($prefix,'tekstportal/lh/')"/>
        </xsl:when>
        <xsl:when test="contains($c,'jura')">
          <xsl:value-of select="concat($prefix,'tekstportal/jura/')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$prefix"/>
        </xsl:otherwise>
      </xsl:choose>
    </choose>
  </xsl:param>
  
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
	      <xsl:value-of select="$id"/>
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
	    <xsl:value-of select="concat('../#',@xml:id)"/>
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
      	<xsl:value-of select="@xml:id"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="img_ref">
    <xsl:choose>
      <xsl:when 
	  test="contains(@facs,'http') and not(contains(@rend,'missing'))">
        <xsl:element name="img">
	  <xsl:attribute name="height">750</xsl:attribute>
	  <xsl:attribute name="src">
            <xsl:value-of select="concat(@facs,'/full/,750/0/native.jpg')"/>
	  </xsl:attribute>
        </xsl:element>
      </xsl:when>
      <xsl:when 
	  test="not(contains(@facs,'http')) and not(contains(@rend,'missing'))">
        <xsl:element name="img">
	  <xsl:attribute name="height">750</xsl:attribute>
          <xsl:choose>
            <xsl:when test="contains($c,'gv')">

              <xsl:variable name="year" select="fn:replace(@facs,'^(18\d\d).*$','$1')"/>
              <xsl:variable name="ipath" select="fn:replace(@facs,'^(.*)_fax.*jpg$','$1')"/>
              <xsl:variable name="facs" select="fn:replace(@facs,'^(.*)\.jpg$','$1/')"/>
              
              <xsl:attribute name="src">
                <xsl:value-of
                    select="concat($processed_prefix,
                            $year,'/',
                            $year,'GV/',
                            $ipath,'/',
                            $ipath,'_tif_side/',
                            $facs,'/full/,750/0/native.jpg')"/>
                <!--         https://kb-images.kb.dk/public/tekstportal/gv/1839/1839GV/1839_615/1839_615_tif_side/1839_615_fax001/info.json -->
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="src">
                <xsl:value-of select="concat($processed_prefix,@facs,'/full/,750/0/native.jpg')"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:transform>

