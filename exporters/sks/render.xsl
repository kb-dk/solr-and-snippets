<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:me="urn:my-things"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               exclude-result-prefixes="t me fn t xs">

  <xsl:import href="../render-global.xsl"/>
  <xsl:import href="../apparatus-global.xsl"/>

  <xsl:import href="./graphics.xsl"/>
  <xsl:import href="./ornament.xsl"/>
  
  <xsl:import href="./journals-and-papers.xsl"/>
  <xsl:import href="./all_kinds_of_notes.xsl"/>

  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyzæøåöäü'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅÖÄÜ'" />
  <xsl:variable name="iip_baseuri"  select="'http://kb-images.kb.dk/public/sks/'"/>
  <xsl:variable name="iiif_suffix" select="'/full/full/0/native.jpg'"/>

  <xsl:variable name="sks_acronym" select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[@type='short']"/>

  <!-- 
       These are the @edRefs found on page breaks in SKS

      6 EPIII
    154 EPI-II
      1 EPVI
  10766 SKS
   1101 SV1
    406 SV2
   4992 SV3

  -->
<!-- 

 $ xpath -e '//text/@type|//text/@subtype' */txt.xml 2> /dev/null | grep -v subtype | grep type | sort | uniq -c
    132  type="ms"
     80  type="print"
 $ xpath -e '//text[@type="ms"]/@subtype' */txt.xml 2> /dev/null | sort | uniq -c
      1  subtype="documents"
    109  subtype="journalsAndPapers"
     15  subtype="lettersAndDedications"
      7  subtype="unpublishedWritings"
 $ xpath -e '//text[@type="print"]/@subtype' */txt.xml 2> /dev/null | sort | uniq -c
     78  subtype="publishedWritings"
      2  subtype="unpublishedWritings"

-->
  
  <xsl:template match="t:text[@type='ms']">
    <xsl:comment> ms text </xsl:comment>
    <div>
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:text[@type='print']">
    <xsl:comment> print text </xsl:comment>
    <div>
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:text[@type='ms']/t:body">
    <xsl:comment> ms body </xsl:comment>
    <div>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:div[@type='entry']"/>
    </div>
  </xsl:template>
 
  
  <xsl:template match="t:pb|t:milestone">

      <xsl:variable name="witness">
	<xsl:value-of select="replace(@edRef,'#','')"/>
      </xsl:variable>

      <xsl:variable name="title">
	<xsl:choose>
	  <xsl:when test="@n and contains(@edRef,'SKS')">SKS</xsl:when>
	  <xsl:otherwise>
	    <xsl:if test="@edRef">
	      <xsl:choose>
		<xsl:when test="/t:TEI//t:listWit/t:witness[@xml:id=$witness]"> 
		  <xsl:value-of select="/t:TEI//t:listWit/t:witness[@xml:id=$witness]"/> (<xsl:value-of select="$witness"/>)
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="$witness"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:if>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>

      <xsl:if test="@n">
        <xsl:element name="span">
          <xsl:call-template name="add_id"/>

	  <xsl:element name="a">
	    <xsl:attribute name="title">Side: <xsl:value-of select="@n"/> <xsl:if test="@edRef">(<xsl:value-of select="$title"/>)</xsl:if></xsl:attribute>
	    <xsl:attribute name="class">pagination</xsl:attribute>
	    <xsl:attribute name="href"><xsl:value-of select="concat('#',@xml:id)"/></xsl:attribute>

            <xsl:attribute name="id"><xsl:value-of select="concat('anchor',@xml:id)"/></xsl:attribute>


	    <xsl:variable name="class">
	      <xsl:choose>
	        <xsl:when test="@n and contains(@edRef,'SKS')">symbol pagination edition</xsl:when>
	        <xsl:otherwise>symbol pagination other</xsl:otherwise>
	      </xsl:choose>
	    </xsl:variable>

	    <xsl:element name="small">
	      <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
	      <xsl:value-of select="@n"/>
	    </xsl:element>

	  </xsl:element>
        </xsl:element>
      </xsl:if>
  </xsl:template>

  <xsl:template match="t:rs[@type='bible']">
    <xsl:variable name="entity">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">person</xsl:when>
        <xsl:when test="contains(local-name(.),'place')">place</xsl:when>
        <xsl:when test="@type='myth'">mytologi</xsl:when>
        <xsl:when test="@type='bible'">Bibel</xsl:when>
	<xsl:otherwise>comment</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="authority">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">pers</xsl:when>
        <xsl:when test="contains(local-name(.),'place')">place</xsl:when>
        <xsl:when test="@type='myth'">myth</xsl:when>
        <xsl:when test="@type='bible'">bible</xsl:when>
	<xsl:otherwise>title</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="symbol">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">&#128100;</xsl:when>
	<xsl:when test="contains(local-name(.),'place')">&#128204;</xsl:when>
        <xsl:otherwise>&#9658;</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title">
        <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">Person</xsl:when>
        <xsl:when test="contains(local-name(.),'place')">Plads</xsl:when>
        <xsl:when test="@type='myth'">Mytologi</xsl:when>
        <xsl:when test="@type='bible'">Bibel</xsl:when>
	<xsl:otherwise>Titel</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="key"><xsl:value-of select="@key"/></xsl:variable>
    <xsl:variable name="uri">
      <xsl:value-of select="concat('gv-registre-',$authority,'-shoot-',$key,'#',$key)"/>
    </xsl:variable>

    <xsl:element name="a">
      <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      <xsl:attribute name="class">
        <xsl:value-of select="$entity"/>
      </xsl:attribute>

      <xsl:attribute name="title">
        <xsl:choose>
          <xsl:when test="contains($title,'Bibel')"><xsl:value-of select="@key"/></xsl:when>
          <xsl:otherwise>
	    <xsl:value-of select="$title"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
        
      <xsl:attribute name="data-toggle">modal</xsl:attribute>
      <xsl:attribute name="data-target">#comment_modal</xsl:attribute>
      <xsl:if test="not(contains(@type,'bible'))">
        <xsl:attribute name="href">
          <xsl:value-of select="$uri"/>
        </xsl:attribute>
      </xsl:if>
      <span class="symbol {$entity}"><span class="debug {$authority}-stuff"><xsl:value-of select="$symbol"/></span></span><xsl:comment> blæ blæ blæ </xsl:comment>

      <span class="{$authority}">
        <xsl:apply-templates/>
      </span>

      <xsl:if test="@key"><xsl:comment> key = <xsl:value-of select="@key"/> </xsl:comment></xsl:if>
      
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
          <a data-dismiss="modal">
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
