<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">
  
  <xsl:import href="../render-global.xsl"/>

  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyzæøåöäü'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅÖÄÜ'" />

  <xsl:template match="t:pb">
    <xsl:element name="span">
      <xsl:attribute name="class">pageBreak</xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:choose>
	<xsl:when test="not(@edRef)">
	  <xsl:text> [s.</xsl:text><xsl:value-of select="@n"/><xsl:text>] </xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text><!-- an invisible anchor --></xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="make-href">

    <xsl:variable name="href">
      <xsl:choose>
	<xsl:when test="contains(@target,'#') and not(substring-before(@target,'#'))">
	  <xsl:value-of select="@target"/>	    
	</xsl:when>
	<xsl:otherwise>
	  <xsl:variable name="fragment">
	    <xsl:value-of select="concat('#',substring-after(@target,'#'))"/>
	  </xsl:variable>
	  <xsl:variable name="file">
	    <xsl:value-of select="translate(substring-before(@target,'#'),$uppercase,$lowercase)"/>
	  </xsl:variable>
	  <xsl:choose>
	    <xsl:when test="contains($file,'../')">
	      <xsl:value-of select="concat($c,'-',substring-before(substring-after($file,'../'),'.xml'),'-root',$fragment)"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:choose>
		<xsl:when test="contains($path,'-txt')">
		  <xsl:value-of 
		      select="concat(substring-before($path,'-txt'),
			      '-',
			      substring-before(@target,'.xml'),
			      '-root',
			      substring-after(@target,'.xml'))"/>
		</xsl:when>
		<xsl:when test="contains($path,'-kom')">
		  <xsl:value-of 
		      select="concat(substring-before($path,'-kom'),'-',substring-before(@target,'.xml'),'-root',substring-after(@target,'.xml'))"/>
		</xsl:when>
		<xsl:when test="contains($path,'-txr')">
		  <xsl:value-of 
		      select="concat(substring-before($path,'-txr'),'-',substring-before(@target,'.xml'),'-root',substring-after(@target,'.xml'))"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="@target"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="concat('/text/',translate($href,'/','-'))"/>
  </xsl:template>


  <xsl:template match="t:ref">
    <xsl:element name="a">
      <xsl:attribute name="href">
	<xsl:call-template name="make-href"/>
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