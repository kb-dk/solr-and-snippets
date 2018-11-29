<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       exclude-result-prefixes="t fn">
  
  <xsl:import href="../render-global.xsl"/>
  <xsl:import href="../apparatus-global.xsl"/>
  <xsl:import href="./graphics.xsl"/>
  <xsl:import href="./all_kinds_of_notes.xsl"/>

  <xsl:import href="./ornament.xsl"/>

  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyzæøåöäü'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅÖÄÜ'" />
  <xsl:variable name="iip_baseuri"  select="'http://kb-images.kb.dk/public/sks/'"/>
  <xsl:variable name="iiif_suffix" select="'/full/full/0/native.jpg'"/>

  <xsl:variable name="sks_acronym" select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[@type='short']"/>

  <xsl:template match="t:pb">
    <xsl:element name="span">
      <xsl:if test="not(@edRef)">
	<xsl:attribute name="class">pageBreak</xsl:attribute>
      </xsl:if>
      <xsl:call-template name="add_id"/>
      <xsl:if test="@facs">
	<xsl:call-template name="sks_page_specimen"/>
      </xsl:if>
      <xsl:choose>
	<xsl:when test="@n and not(@edRef)"><a><small><xsl:value-of select="@n"/></small></a></xsl:when>
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


  <xsl:template match="t:dateline">
    <strong>
      <xsl:call-template name="add_id"/>
      <xsl:if test="../@n">
	<xsl:if test="$sks_acronym"><xsl:value-of select="$sks_acronym"/>:</xsl:if><xsl:value-of select="../@n"/>
      </xsl:if>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>

  <xsl:template match="t:figure[@type='blank']"/>

  <xsl:template match="t:div[t:head[@n='titelblad' or @n='motto' or @n='smudstitelblad' ]]">
    <div>
      <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      <xsl:attribute name="style">
      <xsl:choose>
	<xsl:when test="t:head/@n='motto'">text-align:right;</xsl:when>
	<xsl:otherwise>text-align:center;</xsl:otherwise>
      </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:div[t:head[@n='titelblad' or @n='motto' or @n='smudstitelblad']]/t:p">
    <xsl:apply-templates/><br><xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute></br>
  </xsl:template>

  <xsl:template match="t:dateline/t:date">
    <xsl:call-template name="print_date"> 
      <xsl:with-param name="date" select="@when"/>
    </xsl:call-template>
  </xsl:template>

<xsl:template match="t:label">
    <xsl:param name="anchor" select="../@xml:id"/>
    <xsl:choose>
      <xsl:when test="contains($path,'kom')">
        <xsl:variable name="p">
          <xsl:value-of select="replace($path,'(kom)','txt')"/>
        </xsl:variable>
        <xsl:variable name="href">
          <xsl:value-of select="concat(replace($p,'-((root)|(shoot).*$)','-root#'),$anchor)"/>
        </xsl:variable>
        <span>
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="$href"/> 
            </xsl:attribute>
             &#9668; <xsl:apply-templates/>
          </a>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span><xsl:call-template name="add_id_empty_elem"/><xsl:apply-templates/><xsl:value-of select="$anchor"/></span><xsl:text>
      </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="make-href">

    <xsl:param name="go_to" select="@target"/>

    <xsl:variable name="target">
      <xsl:value-of select="fn:lower-case($go_to)"/>
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
	<xsl:value-of select="concat($adl_baseuri,'/text/',translate($href,'/','-'))"/>
      </xsl:otherwise>
    </xsl:choose>


  </xsl:template>



</xsl:transform>
