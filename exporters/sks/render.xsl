<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">
  
  <xsl:import href="../render-global.xsl"/>

  <xsl:template match="t:pb">
    <xsl:if test="not(@edRef)">
      <xsl:element name="span">
	<xsl:attribute name="class">pageBreak</xsl:attribute>
	<xsl:call-template name="add_id"/>
	<xsl:text> [s.</xsl:text><xsl:value-of select="@n"/><xsl:text>] </xsl:text>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:ref">
    <xsl:element name="a">
      <xsl:attribute name="href">
	<xsl:choose>
	  <xsl:when test="not(substring-before(@target,'#'))">
	    <xsl:value-of select="@target"/>	    
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:choose>
	      <xsl:when test="contains($path,'-txt')">
		<xsl:value-of 
		    select="concat('/text/',
			    substring-before($path,'-txt'),
			    '-',
			    substring-before(@target,'.xml'),
			    '-root',
			    substring-after(@target,'.xml'))"/>
	      </xsl:when>
	      <xsl:when test="contains($path,'-kom')">
		<xsl:value-of 
		    select="concat('/text/',substring-before($path,'-kom'),'-',substring-before(@target,'.xml'),'-root',substring-after(@target,'.xml'))"/>
	      </xsl:when>
	      <xsl:when test="contains($path,'-txr')">
		<xsl:value-of 
		    select="concat('/text/',substring-before($path,'-txr'),'-',substring-before(@target,'.xml'),'-root',substring-after(@target,'.xml'))"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="@target"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:note">
    <xsl:choose>
      <xsl:when test="@type='commentary'">
	<xsl:element name="p">
	  <xsl:call-template name="add_id"/>
	  <xsl:apply-templates select="t:label"/><xsl:text>: </xsl:text><xsl:apply-templates mode="note_body" select="t:p"/>
	</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="inline_note"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="note_body" match="t:p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="add_id_empty_elem">
    <xsl:if test="@xml:id">
      <xsl:attribute name="id">
	<xsl:value-of select="@xml:id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:call-template name="render_stuff"/>
  </xsl:template>

  <xsl:template name="render_stuff">
    <xsl:if test="contains(@rendition,'#')">
      <xsl:variable name="rend" select="substring-after(@rendition,'#')"/> 
      <xsl:choose>
	<xsl:when test="/t:TEI//t:rendition[@scheme='css'][@xml:id = $rend]">
	  <xsl:attribute name="style">
	    <xsl:value-of select="/t:TEI//t:rendition[@scheme='css'][@xml:id = $rend]"/>
	  </xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="class">
	    <xsl:value-of select="substring-after(@rendition,'#')"/> 
	  </xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:transform>