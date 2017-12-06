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
      <xsl:if test="not(@edRef)">
	<xsl:attribute name="class">pageBreak</xsl:attribute>
      </xsl:if>
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

  <xsl:template match="t:choice[t:abbr and t:expan]">
    <xsl:element name="a">
      <xsl:attribute name="title">
	<xsl:value-of select="t:expan"/>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:abbr"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="make-href">

      <xsl:choose>
	<xsl:when test="contains(@target,'#') and not(substring-before(@target,'#'))">
	  <xsl:value-of select="@target"/>	    
	</xsl:when>
	<xsl:otherwise>
	  <xsl:variable name="href">
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
	  </xsl:variable>
	  <xsl:value-of select="concat('/text/',translate($href,'/','-'))"/>
	</xsl:otherwise>
      </xsl:choose>


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

  <xsl:template match="t:app">
    <xsl:call-template name="apparatus_criticus"/>
  </xsl:template>

  <xsl:template name="apparatus_criticus">
    <xsl:variable name="idstring">
      <xsl:value-of select="translate(@xml:id,'-','_')"/>
    </xsl:variable>
    <xsl:variable name="note">
      <xsl:value-of select="concat('apparatus',$idstring)"/>
    </xsl:variable>
    <xsl:apply-templates select="t:lem"/>
    <xsl:element name="sup">
      <script>
	var <xsl:value-of select="concat('disp',$idstring)"/>="none";
	function <xsl:value-of select="$note"/>() {
	var ele = document.getElementById("<xsl:value-of select="@xml:id"/>");
	if(<xsl:value-of select="concat('disp',$idstring)"/>=="none") {
	ele.style.display="inline";
	<xsl:value-of select="concat('disp',$idstring)"/>="inline";
	} else {
	ele.style.display="none";
	<xsl:value-of select="concat('disp',$idstring)"/>="none";
	}
	}
      </script>
      <xsl:element name="a">
	<xsl:attribute name="onclick"><xsl:value-of select="$note"/>();</xsl:attribute>
	<xsl:choose>
	  <xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when>
	  <xsl:otherwise>*</xsl:otherwise>
	</xsl:choose>
      </xsl:element>
    </xsl:element>
    <span style="background-color:yellow;display:none;">
      <xsl:call-template name="add_id"/>
      <xsl:for-each select="t:lem|t:rdg">
	<xsl:if test="t:sic[@rendition = '#so']"><xsl:text> således også: </xsl:text></xsl:if>
	<xsl:if test="@wit">
	  <xsl:variable name="witness"><xsl:value-of select="normalize-space(substring-after(@wit,'#'))"/></xsl:variable>
	  <xsl:element name="a">
	    <xsl:attribute name="title"><xsl:value-of select="/t:TEI//t:listWit/t:witness[@xml:id=$witness]"/></xsl:attribute>
	    <xsl:value-of select="$witness"/>
	    </xsl:element>
	    <xsl:if test="not(t:sic[@rendition = '#so'])">: </xsl:if>
	</xsl:if>
	<xsl:apply-templates/><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
      </xsl:for-each>
    </span>
  </xsl:template>



</xsl:transform>