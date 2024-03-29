<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:t="http://www.tei-c.org/ns/1.0"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:me="urn:my-things"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0" exclude-result-prefixes="xs t me fn t">


  <xsl:param name="float_graphics" select="false()"/>
  
  <xsl:variable name="dom" select="."/>

  <xsl:template match="t:div[@type='entry']">
    <div>
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:comment> entry in div found here <xsl:value-of select="@decls"/> </xsl:comment>

      <div style="clear: both;">
        <xsl:apply-templates select="t:dateline|t:p[@rend='decoration']"/>
      </div>

      <xsl:if test="t:figure">
        <div style="width:50%; float:left;">
          <xsl:call-template name="add_id"/>
          <xsl:apply-templates select="t:figure"/>
        </div>
        <br style="clear:both;"/>
      </xsl:if>

      <xsl:for-each select="t:div">
        <!-- xsl:apply-templates select="t:div[@type='mainColumn']"/ -->
        <xsl:call-template name="main_column_div"/>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template mode="journals-mode" name="journals-ref" match="t:ref[@type = 'author']">
   <xsl:variable name="target">
      <xsl:value-of select="substring-after(@target,'#')"/>
    </xsl:variable>

    <xsl:variable name="label">
      <xsl:for-each select="/t:TEI//t:note[@xml:id = $target]">
        <xsl:apply-templates select="t:seg[@type='refMarker']"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="/t:TEI//t:note[@xml:id = $target]">
      <sup>
        <xsl:call-template name="add-ptr-marker">
          <xsl:with-param name="target" select="$target"/>
          <xsl:with-param name="marker" select="$label"/>
        </xsl:call-template>
      </sup>
    </xsl:for-each> 
  </xsl:template>
  
  <xsl:template mode="journals-mode" name="journals-ptr" match="t:ptr[@type = 'author']">
    <xsl:variable name="target">
      <xsl:value-of select="substring-after(@target,'#')"/>
    </xsl:variable>

    <xsl:variable name="label">
      <xsl:for-each select="/t:TEI//t:note[@xml:id = $target]">
        <xsl:apply-templates select="t:seg[@type='refMarker']"/>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:for-each select="/t:TEI//t:note[@xml:id = $target]">
      <sup style="display:none">
        <xsl:call-template name="add-ptr-marker">
          <xsl:with-param name="target" select="$target"/>
          <xsl:with-param name="marker" select="$label"/>
        </xsl:call-template>
      </sup>
    </xsl:for-each> 
  </xsl:template>
  
  <xsl:template match="t:note[@type='author' and (@place='margin' or @place='bottom')]">
    <xsl:choose>
      <xsl:when test="$dom//t:text/@subtype='lettersAndDedications' or $dom//t:text/@subtype='journalsAndPapers'">
        <p>
          <xsl:call-template name="add_id">
	    <xsl:with-param name="expose">true</xsl:with-param>
          </xsl:call-template>
          <xsl:apply-templates/>
          <xsl:comment> Where is the leak? </xsl:comment>
        </p>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="t:ref[@type='author']/t:seg[@type='refMarker']">
    <xsl:element name="sup">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="main_column_div" match="t:div[@type='mainColumn']">

    <xsl:for-each select="t:p">
      <xsl:comment> a paragraph inside a main column </xsl:comment>
      <xsl:call-template name="main_column_paragraph"/>
    </xsl:for-each>
    
    <xsl:if test=".//t:note[@place='bottom']">
      <div style="width:40%; margin-left: 8%; float: left;font-size:90%;">
        <xsl:apply-templates select=".//t:note[@place='bottom']"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="get-relevant-notes">
    <xsl:param name="place" select="'margin'"/>

    <xsl:variable name="relevant_notes" as="xs:string *">
      <xsl:for-each select=".//t:ref[@type='author']/@target|.//t:ptr[@type='author']/@target">
        <xsl:value-of select="substring-after(.,'#')"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:for-each select="distinct-values($relevant_notes)">
      <xsl:variable name="this_note" select="."/>
      <xsl:apply-templates select="$dom//t:note[@xml:id=$this_note][@place=$place]"/>
      <xsl:for-each select="$dom//t:note[@xml:id=$this_note]/t:p">
        <xsl:call-template name="get-relevant-notes"/>
      </xsl:for-each>
    </xsl:for-each>
    
  </xsl:template>

  <xsl:template name="main_column_paragraph" match="t:div[@type='mainColumn']/t:p">
    <p style="width:50%;  float: left;">
      <!-- xsl:call-template name="add_id"/ -->
      <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
      <xsl:comment> div here yyyyyyy xxxxxx <xsl:value-of select="@decls"/> </xsl:comment>
      <xsl:apply-templates/>
    </p>

    <xsl:variable name="the_notes">
      <xsl:call-template name="get-relevant-notes">
        <xsl:with-param name="place">margin</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$the_notes">
      <div style="width:40%; margin-left: 8%; float: left;font-size:90%;">
        <xsl:copy-of select="$the_notes"/>
      </div>
    </xsl:if>

    <div style="clear: both;">

    </div>
  </xsl:template>

   
</xsl:transform>
