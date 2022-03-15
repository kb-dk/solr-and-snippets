<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:me="urn:my-things"
               version="2.0"
	       exclude-result-prefixes="t xs">

  <xsl:param name="float_graphics" select="false()"/>
  
  <xsl:variable name="dom" select="."/>
  
  <xsl:template match="t:text[@type='ms' and subtype='journalsAndPapers']">
    <xsl:comment> text </xsl:comment>
    <div>
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:div[@type='entry']">
    <div>
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:comment> entry in div here <xsl:value-of select="@decls"/> </xsl:comment>

      <div style="clear: both;">
        <xsl:apply-templates select="t:dateline|t:p[@rend='decoration']"/>
      </div>
      
      <xsl:apply-templates select="t:div[@type='mainColumn']"/>
     
    </div>
  </xsl:template>

  <xsl:template match="t:note[@type='author' and @place='margin']">
    <p>
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="t:ref[@type='author']/t:seg[@type='refMarker']">
    <xsl:element name="sup">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:div[@type='mainColumn']">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template name="get-relevant-notes">
    <xsl:variable name="relevant_notes"  as="xs:string *">
      <xsl:for-each select="./t:ref[@type='author']/@target|./t:ptr[@type='author']/@target"><xsl:value-of select="substring-after(.,'#')"/></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="this_is_segment"><xsl:value-of select="@xml:id"/></xsl:variable>

    <xsl:for-each select="distinct-values($relevant_notes)" >
      <xsl:variable name="this_note" select="."/>
      <xsl:comment>searching  <xsl:value-of select="$this_note"/></xsl:comment>
      <xsl:apply-templates select="$dom//t:note[@xml:id=$this_note]"/>
      <xsl:for-each select="$dom//t:note[@xml:id=$this_note]/t:p">
        <xsl:comment> found note <xsl:value-of select="$this_note"/> in segment <xsl:value-of select="$this_is_segment"/> </xsl:comment>
        <xsl:call-template name="get-relevant-notes"/>
      </xsl:for-each>
    </xsl:for-each>
    
  </xsl:template>
  
   <xsl:template match="t:div[@type='mainColumn']/t:p">
    <p style="width:50%;  float: left;">
      <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      <xsl:comment> div here yyyyyyy xxxxxx <xsl:value-of select="@decls"/> </xsl:comment>
      <xsl:apply-templates/>
    </p>

    <div style="width:40%; margin-left: 8%; float: left;font-size:90%;">
      <xsl:call-template name="get-relevant-notes"/>
    </div>

    <div style="clear: both;">

    </div>
  </xsl:template>

  <!-- xsl:template match="t:div[@type='marginalColumn']">
    <div style="width:40%; margin-left: 8%; float: left;font-size:90%;">
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:comment> div here <xsl:value-of select="@decls"/> </xsl:comment>
      <xsl:apply-templates/>
    </div>
  </xsl:template -->


   
</xsl:transform>
