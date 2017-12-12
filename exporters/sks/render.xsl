<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">
  
  <xsl:import href="../render-global.xsl"/>

  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyzæøåöäü'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅÖÄÜ'" />

  <xsl:variable name="base_uri"  select="'http://kb-images.kb.dk/public/sks/'"/>
  <xsl:variable name="iiif_suffix" select="'/full/full/0/native.jpg'"/>

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

  <xsl:template name="print_date">
    <xsl:param name="date" select="''"/>
    <xsl:variable name="year">
      <xsl:value-of select="substring($date,1,4)"/>
    </xsl:variable>
    <xsl:variable name="month_day">
      <xsl:choose>
      <xsl:when test="not(contains($date,'0000'))"><xsl:value-of select="substring-after($date,$year)"/></xsl:when>
      <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
      date = <xsl:value-of select="$date"/>

      month_day = <xsl:value-of select="$month_day"/>

      year = <xsl:value-of select="$year"/>

      month = <xsl:value-of select="substring($month_day,1,2)"/>

      day   = <xsl:value-of select="substring($month_day,3,4)"/>

    -->
    <xsl:value-of select="$year"/><xsl:if test="not(contains($date,'0000'))"> &#8211; <xsl:value-of select="substring($month_day,1,2)"/> &#8211; <xsl:value-of select="substring($month_day,3,4)"/></xsl:if>
  </xsl:template>

  <xsl:template match="t:dateline/t:date">
    <span>
      <xsl:call-template name="add_id"/>
      <xsl:call-template name="print_date"> 
	<xsl:with-param name="date" select="@when"/>
      </xsl:call-template>
    </span>
  </xsl:template>


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

  <xsl:template name="make-href">

    <xsl:variable name="target">
      <xsl:value-of select="translate(@target,$uppercase,$lowercase)"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="contains($target,'#') and not(substring-before($target,'#'))">
	<xsl:value-of select="$target"/>	    
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="href">
	  <xsl:variable name="fragment">
	    <xsl:if test="contains($target,'#')">
	      <xsl:value-of select="concat('#',substring-after($target,'#'))"/>
	    </xsl:if>
	  </xsl:variable>
	  <xsl:variable name="file">
	    <xsl:choose>
	      <xsl:when test="contains($target,'#')">
		<xsl:value-of select="substring-before($target,'#')"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="$target"/>
	      </xsl:otherwise>
	    </xsl:choose>
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
			      substring-before($target,'.xml'),
			      '-root',
			      substring-after($target,'.xml'))"/>
		</xsl:when>
		<xsl:when test="contains($path,'-kom')">
		  <xsl:value-of 
		      select="concat(substring-before($path,'-kom'),'-',substring-before($target,'.xml'),'-root',substring-after($target,'.xml'))"/>
		</xsl:when>
		<xsl:when test="contains($path,'-txr')">
		  <xsl:value-of 
		      select="concat(substring-before($path,'-txr'),'-',substring-before($target,'.xml'),'-root',substring-after($target,'.xml'))"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="$target"/>
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
	<xsl:attribute name="title">Tekstkritik</xsl:attribute>
	<xsl:attribute name="onclick"><xsl:value-of select="$note"/>();</xsl:attribute>
	<xsl:choose>
	  <xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when>
	  <xsl:otherwise>*</xsl:otherwise>
	</xsl:choose>
      </xsl:element>
    </xsl:element>
    <span style="background-color:yellow;display:none;">
      <xsl:call-template name="add_id"/>
      <xsl:for-each select="t:lem|t:rdg|t:corr">
	<xsl:if test="t:sic[@rendition = '#so']"><xsl:text> således også </xsl:text></xsl:if>
	<xsl:if test="@wit">
	  <xsl:variable name="witness"><xsl:value-of select="normalize-space(substring-after(@wit,'#'))"/></xsl:variable>
	  <xsl:element name="span">
	    <xsl:attribute name="title">
	      <xsl:value-of select="/t:TEI//t:listWit/t:witness[@xml:id=$witness]"/>
	    </xsl:attribute>
	    <xsl:value-of select="$witness"/>
	  </xsl:element>
	  <xsl:if test="not(t:sic[@rendition = '#so'])">: </xsl:if>
	</xsl:if>
	<xsl:element name="span">
	<xsl:apply-templates select="."/><xsl:if test="@evidence">[<xsl:value-of select="@evidence"/>]</xsl:if>
	</xsl:element><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
      </xsl:for-each>
    </span>
  </xsl:template>

  <xsl:template match="t:graphic">
    <xsl:element name="img">
      <xsl:variable name="url">
      <xsl:value-of select="concat($base_uri,substring-before(translate(substring-after(@url,'../'),$uppercase,$lowercase),'.jpg'))"/>
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


</xsl:transform>