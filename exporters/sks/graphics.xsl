<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
	       exclude-result-prefixes="t xs">

  <xsl:import href="../graphics-global.xsl"/>
  
  <xsl:template name="sks_page_specimen">
    <xsl:element name="div">
      <xsl:choose>
        <xsl:when test="$float_graphics">
          <xsl:attribute name="style"> width: 50%; float: <xsl:call-template name="float_direction"/>; clear: both; margin: 2em; </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="style"> width: 90%; clear: both; margin: 2em; </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="add_id"/>

      <xsl:call-template name="render_graphic">
	<xsl:with-param name="graphic_uri">
	  <xsl:value-of 
	      select="substring-before(translate(substring-after(@facs,'../'),$uppercase,$lowercase),'.jpg')"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:figure[@rend]/t:graphic">
    <xsl:if test="@url">
      <xsl:call-template name="render_graphic">
        <xsl:with-param name="width">0</xsl:with-param>
	<xsl:with-param name="graphic_uri">
	  <xsl:value-of 
	      select="substring-before(translate(substring-after(@url,'../'),$uppercase,$lowercase),'.jpg')"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:figure[@rend]">
    <xsl:element name="br">
      <xsl:call-template name="add_id"/>
    </xsl:element>
      <!-- xsl:attribute name="style"> width: 90%; </xsl:attribute -->
      <xsl:apply-templates select="t:graphic"/>
      <xsl:apply-templates select="t:head"/> <xsl:comment> Blablalbabla </xsl:comment>
      <xsl:element name="br"/>
  </xsl:template>
  
  <xsl:template match="t:figure">
    <xsl:element name="div">
      <xsl:choose>
        <xsl:when test="$float_graphics">
          <xsl:attribute name="style"> width: 50%; float: <xsl:call-template name="float_direction"/>; clear: both; margin: 2em; </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="style"> width: 90%; clear: both; margin: 2em; </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:graphic"/>
      <xsl:apply-templates select="t:head"/> <xsl:comment> Bløblølbøblø </xsl:comment>
    </xsl:element>
  </xsl:template>


  <xsl:template match="t:figure[contains(t:graphic/@url,'sks/kort')]">
    <xsl:analyze-string select="t:graphic/@url" regex="(ber|kbh|kbhf|kbho|dk|nordsj)/(\d+),(\d+),(\d+),(\d+)/">
      <xsl:matching-substring>
        <xsl:variable name="map"   as="xs:string"  select="regex-group(1)"/>
        <xsl:variable name="xpos"  as="xs:double" select="number(regex-group(2))"/>
        <xsl:variable name="ypos"  as="xs:double" select="number(regex-group(3))"/>
        <xsl:variable name="width" as="xs:double" select="number(regex-group(4))"/>
        <xsl:variable name="height" as="xs:double" select="number(regex-group(5))"/>

        <xsl:variable name="size_x">
          <xsl:choose>
            <xsl:when test="$map = 'ber'">6900</xsl:when>
            <xsl:when test="$map = 'kbh'">5003</xsl:when>
            <xsl:when test="$map = 'kbhf'">4931</xsl:when>
            <xsl:when test="$map = 'kbho'">5024</xsl:when>
            <xsl:when test="$map = 'dk'">2607</xsl:when>
            <xsl:when test="$map = 'nordsj'">3485</xsl:when>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="size_y">
          <xsl:choose>
            <xsl:when test="$map = 'ber'">5206</xsl:when>
            <xsl:when test="$map = 'kbh'">4181</xsl:when>
            <xsl:when test="$map = 'kbhf'">4432</xsl:when>
            <xsl:when test="$map = 'kbho'">4929</xsl:when>
            <xsl:when test="$map = 'dk'">3367</xsl:when>
            <xsl:when test="$map = 'nordsj'">3979</xsl:when>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="line_width">10</xsl:variable>
          <div>
            <xsl:attribute name="style">width:<xsl:value-of select="$size_x"/>px; height:<xsl:value-of select="$size_y"/>px;
background-image: <xsl:value-of select="concat('url(https://kb-images.kb.dk/public/tekstportal/sks/kort/',$map,'/full/full/0/default.jpg)')"/>;</xsl:attribute>

            <div>
              <xsl:attribute name="style">position: absolute;
border:<xsl:value-of select="$line_width"/>px blue solid;
left: <xsl:value-of select="$xpos"/>px;
top:<xsl:value-of select="$size_y - $ypos - $height - $line_width"/>px;
width:<xsl:value-of select="$width  + $line_width"/>px;
height:<xsl:value-of select="$height + $line_width"/>px;
background-color:transparent;
opacity: 0.4;
filter: alpha(opacity=20);</xsl:attribute>

            <xsl:comment>

              map=<xsl:value-of select="$map"   />
              
              xpos=<xsl:value-of select="$xpos"  />
              
              ypos=<xsl:value-of select="$ypos"  />
              
              width=<xsl:value-of select="$width" />
              
              height=<xsl:value-of select="$height" />
              
            </xsl:comment>
            </div>
          </div>

      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  
  <xsl:template name="float_direction">
    <xsl:choose>
      <xsl:when test="count(preceding::t:graphic|preceding::t:pb[@facs]) mod 2">left</xsl:when>
      <xsl:otherwise>right</xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:transform>
