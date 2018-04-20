<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="t"
    version="2.0">

  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyzæøåöäü'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅÖÄÜ'" />
  <xsl:variable name="iip_baseuri"  select="'http://kb-images.kb.dk/public/sks/'"/>
  <xsl:variable name="iiif_suffix" select="'/full/full/0/native.jpg'"/>

  <xsl:template match="t:corr">
    <span title="rættelse">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="t:add">
    <span title="tillæg">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="t:del">
    <del title="sletning">
      <xsl:call-template name="render_stuff"/>
      <xsl:apply-templates/>
    </del>
  </xsl:template>

  <xsl:template match="t:choice[t:reg and t:orig]">
    <span>
      <xsl:attribute name="title">
	oprindelig: <xsl:value-of select="t:orig"/>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:reg"/>
    </span>
  </xsl:template>

  <xsl:template match="t:choice[t:abbr and t:expan]">
    <xsl:element name="a">
      <xsl:attribute name="title">
	<xsl:for-each select="t:expan">
	<xsl:value-of select="."/><xsl:if test="position() &lt; last()">; </xsl:if>
	</xsl:for-each>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:abbr"/>
    </xsl:element>
  </xsl:template>



  <xsl:template match="t:ref">
    <xsl:element name="a">
      <xsl:if test="@type='commentary'"><xsl:attribute name="title">Kommentar</xsl:attribute></xsl:if>
      <xsl:if test="@target">
	<xsl:attribute name="href">
	  <xsl:call-template name="make-href"/>
	</xsl:attribute>
      </xsl:if>
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
	<xsl:when test="$rend = 'capiTyp'"><xsl:attribute name="style">font-variant: small-caps;</xsl:attribute></xsl:when>
	<xsl:when test="$rend = 'spa'"><xsl:attribute name="style">font-style: italic;</xsl:attribute></xsl:when>
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

  <xsl:template match="t:witDetail">
    <xsl:variable name="witness"><xsl:value-of select="normalize-space(substring-after(@wit,'#'))"/></xsl:variable>
    <xsl:element name="span">
      <xsl:if test="@wit">
	<xsl:attribute name="title">
	  <xsl:value-of select="/t:TEI//t:listWit/t:witness[@xml:id=$witness]"/>
	</xsl:attribute>
	<xsl:value-of select="$witness"/>:
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:lem">
    <xsl:element name="span">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:rdgGrp"> 
    <xsl:element name="span">
      <xsl:call-template name="add_id"/>
      <xsl:if test="@rendition = '#semiko'">; </xsl:if><xsl:apply-templates/><xsl:comment> rdg grp </xsl:comment>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:app">
    <xsl:variable name="idstring">
      <xsl:value-of select="translate(@xml:id,'-;.','___')"/>
    </xsl:variable>
    <xsl:variable name="note">
      <xsl:value-of select="concat('apparatus',$idstring)"/>
    </xsl:variable>
    <xsl:apply-templates select="t:lem"/>
    <xsl:element name="sup">
      <xsl:attribute name="style">text-indent: 0;</xsl:attribute>
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
	<xsl:attribute name="title">Tekstkritik</xsl:attribute>
	<xsl:attribute name="onclick"><xsl:value-of select="$note"/>();</xsl:attribute>
	<i class="fa fa-info-circle" aria-hidden="true"><xsl:comment> * </xsl:comment></i>
      </xsl:element>
    </xsl:element>
    <span style="background-color:Aquamarine;display:none;">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:rdg|t:rdgGrp|t:corr"/>
    </span>
  </xsl:template>

  <xsl:template match="t:sic">
  </xsl:template>

  <xsl:template match="t:rdg">
    <xsl:if test="t:sic/@rendition = '#so'"><xsl:text> Således også: </xsl:text></xsl:if>
    <xsl:element name="span">
      <xsl:if test="@wit">
	<xsl:call-template name="witness"/>
      </xsl:if><xsl:choose><xsl:when test="t:sic/@rendition = '#so'"><xsl:text> </xsl:text></xsl:when><xsl:otherwise><xsl:text>: </xsl:text></xsl:otherwise></xsl:choose>
      <xsl:apply-templates/><xsl:if test="@evidence">[<xsl:value-of select="@evidence"/>]</xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template name="witness">
    <xsl:comment> Witness <xsl:value-of select="@wit"/> </xsl:comment>
    <xsl:variable name="witnesses">
      <xsl:copy-of select="/t:TEI//t:listWit"/>
    </xsl:variable>
    <xsl:for-each select="fn:tokenize(@wit,'\s+')">
      <xsl:variable name="witness"><xsl:value-of select="normalize-space(substring-after(.,'#'))"/></xsl:variable>
      <xsl:element name="span">
	<xsl:attribute name="title">
	  <xsl:value-of select="$witnesses//t:witness[@xml:id=$witness]"/>
	</xsl:attribute>
	<xsl:value-of select="$witness"/><xsl:choose>
      <xsl:when test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:when></xsl:choose></xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="t:ptr[@type = 'author']">
    <xsl:variable name="target">
      <xsl:value-of select="substring-after(@target,'#')"/>
    </xsl:variable>
    <xsl:for-each select="/t:TEI//t:note[@xml:id = $target]">
      <xsl:call-template name="inline_note"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="t:note[@type = 'author']"/>

  <xsl:template match="t:graphic">
    <xsl:element name="img">
      <xsl:variable name="url">
      <xsl:value-of select="concat($iip_baseuri,substring-before(translate(substring-after(@url,'../'),$uppercase,$lowercase),'.jpg'))"/>
      </xsl:variable>
      <xsl:attribute name="style"> width: 100%;</xsl:attribute>
      <xsl:attribute name="src">
	<xsl:value-of select="concat($url,$iiif_suffix)"/>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
    </xsl:element>
  </xsl:template>

 <xsl:template match="t:figure">
   <xsl:variable name="float_direction">
     <xsl:choose>
       <xsl:when test="count(preceding::t:graphic) mod 2">left</xsl:when>
       <xsl:otherwise>right</xsl:otherwise>
     </xsl:choose>
   </xsl:variable>
   <xsl:element name="div">
      <xsl:attribute name="style"> max-width: 50%; float: <xsl:value-of select="$float_direction"/>; clear: both; margin: 2em; </xsl:attribute>
     <xsl:call-template name="add_id"/>
     <xsl:apply-templates select="t:graphic"/>
     <xsl:apply-templates select="t:head"/>
   </xsl:element>
 </xsl:template>

  <xsl:template match="t:figure/t:head">
    <p>
      <xsl:call-template name="add_id"/>
      <small>
	<xsl:apply-templates/>
      </small>
    </p>
  </xsl:template>



</xsl:stylesheet>