<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	       exclude-result-prefixes="t fn math xsl">

  
  <xsl:import href="../render-global.xsl"/>
  <xsl:import href="../apparatus-global.xsl"/>
  <xsl:import href="../graphics-global.xsl"/>
  <xsl:import href="../all_kinds_of_notes-global.xsl"/>
  <xsl:import href="./ornament.xsl"/>
  <xsl:import href="./block-styles.xsl"/>

  <xsl:template name="page_specimen">
  </xsl:template>

  <xsl:template match="t:seg[@type='com']|t:seg[@type='comStart']|t:seg[@type='comEnd']"><xsl:variable name="href"><xsl:value-of select="concat(fn:replace($path,'txt-((root)|(shoot).*$)','com-root#'),@n)"/></xsl:variable><xsl:element name="a"><xsl:attribute name="class">comment</xsl:attribute><xsl:attribute name="title">Punktkommentar</xsl:attribute><xsl:attribute name="id"><xsl:value-of select="@n"/></xsl:attribute><xsl:attribute name="href"><xsl:value-of select="$href"/></xsl:attribute><span class="symbol comment"><span class="debug comment-stuff">&#9658;</span></span><xsl:comment> bla bla bla </xsl:comment><span class="comment"><xsl:apply-templates/></span></xsl:element></xsl:template>

  <xsl:template name="inline_note">
    <xsl:call-template name="general_note_code">
      <xsl:with-param name="display" select="'inline'"/>
      </xsl:call-template><xsl:call-template name="show_note">
      <xsl:with-param name="display" select="'inline'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="t:row[t:cell[@rend='popUp']]">
    <div>
      <xsl:call-template name="add_id"/>
      <p>
        <strong>
          <xsl:apply-templates select="t:cell[@rend='normForm']"/>
        </strong>
        <xsl:for-each select="t:cell[@rend='orthography']">
          <xsl:if test="position()=1"><xsl:text> (</xsl:text></xsl:if><xsl:apply-templates select="."/>
          <xsl:choose><xsl:when test="position()=last()">)</xsl:when>
          <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise></xsl:choose>
        </xsl:for-each>
        </p>
        <p><xsl:apply-templates select="t:cell[@rend='popUp']"/></p>
        <xsl:if test="t:cell[@rend='encyc']">
          <xsl:variable name="read_more_id"><xsl:value-of select="@xml:id"/></xsl:variable>
          <a class="read-more-button" data-read-more="content{$read_more_id}" >Læs mere</a>
          <div class="read-more" id="content{$read_more_id}">
            <xsl:for-each select="t:cell[@rend='encyc']">
              <p><xsl:apply-templates select="."/></p>
            </xsl:for-each>
          </div>
        </xsl:if>
    </div>
  </xsl:template>

  
  <xsl:template match="t:head">
    <xsl:if test="./node()">
      <h2 class="head-in-text">
	<xsl:call-template name="add_id"/>
          <xsl:attribute name="style">
            <xsl:if test="number(@rend)">            
              font-size: <xsl:value-of select="100*math:pow(1.2,@rend)"/> %;
            </xsl:if>
            text-align: center;
            margin-top: 2em; margin-bottom: 2em;
          </xsl:attribute>
	<xsl:apply-templates/>
      </h2>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:hi[@rend='romanType']">
    <span style="font-family:serif;"><xsl:call-template name="add_id"/><xsl:apply-templates/></span>
  </xsl:template>
  
  <xsl:template name="make-href">

    <xsl:variable name="target">
      <xsl:value-of select="translate(@n,$uppercase,$lowercase)"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="contains($path,'-txt')">
	<xsl:value-of 
	    select="concat(substring-before($path,'-txt'),'-com-shoot-',$target)"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- xsl:value-of select="fn:replace(@target,'18([^/]*?)((txt)|(txr)|(com)|(v0)|(intro)).xml','gv-18$1-shoot-$2')"/ -->
        <xsl:value-of select="fn:replace(@target,'18(.*?)_((txt)|(txr)|(com)|(v0)|(intro)).xml','gv-18$1-$2-root')"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="t:app">
    <xsl:choose>
      <xsl:when test="@select">
        <xsl:choose>
          <xsl:when test="contains(@select,'yes')">
            <xsl:call-template name="app-root"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="text" select="t:lem"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="app-root"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="t:persName|
                       t:placeName|
                       t:rs[@type='myth']|
                       t:rs[@type='title']|
                       t:rs[@type='bible']">
    <xsl:variable name="entity">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">person</xsl:when>
        <xsl:when test="contains(local-name(.),'place')">place</xsl:when>
        <xsl:when test="@type='myth'">mytologi</xsl:when>
        <xsl:when test="@type='bible'">Bibel</xsl:when>
        <xsl:when test="@type='title'">title</xsl:when>
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
        <xsl:when test="contains(local-name(.),'title')">&#128214;</xsl:when>
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
          <xsl:when test="contains($title,'Bibel')">
            <xsl:call-template name="bible-reference">
              <xsl:with-param name="rend" select="@rend"/>
              <xsl:with-param name="key"  select="@key"/>
            </xsl:call-template>
          </xsl:when><!-- activate this code by replacing Place with Plads below -->
          <xsl:when test="contains($title,'Plads')">
            <xsl:call-template name="place-reference">
              <xsl:with-param name="rend" select="@rend"/>
              <xsl:with-param name="key"  select="@key"/>
            </xsl:call-template>
          </xsl:when>
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
      <span class="symbol {$entity}"><span class="debug {$authority}-stuff"><xsl:value-of select="$symbol"/></span></span>
      <xsl:comment> blæ blæ blæ </xsl:comment>

      <span class="{$authority}">
        <xsl:apply-templates/> 
      </span>

      <xsl:if test="@key"><xsl:comment> key = <xsl:value-of select="@key"/> </xsl:comment></xsl:if>
      
    </xsl:element>

  </xsl:template>

  <xsl:template match="t:pb[@type='edition']">

    <xsl:variable name="witness">
      <xsl:value-of select="@ed"/>
    </xsl:variable>

    <xsl:if test="@n">
      <xsl:element name="a">
	<xsl:attribute name="title">Side: <xsl:value-of select="@n"/> <xsl:if test="@ed">(<xsl:value-of select="@ed"/>)</xsl:if></xsl:attribute>
	<xsl:attribute name="class">pagination</xsl:attribute>
	<xsl:attribute name="href"><xsl:value-of select="concat('#',@xml:id)"/></xsl:attribute>
	<xsl:call-template name="add_id"/>

	<xsl:variable name="class">symbol pagination other</xsl:variable>

	<xsl:element name="small">
	  <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
	  <xsl:value-of select="@n"/> <xsl:if test="@ed">
            (<xsl:value-of select="@ed"/>)
          </xsl:if>
	</xsl:element>
      </xsl:element>
      <xsl:text> 
      </xsl:text>
    </xsl:if>

  </xsl:template>

  <xsl:template name="place-reference">
    <xsl:param name="rend" select="''"/>
    <xsl:param name="key"  select="''"/>

    <xsl:choose>
      <xsl:when test="contains($key,'his')">Sted (hist.)</xsl:when>
      <xsl:when test="contains($key,'poet')">Sted (poet.)</xsl:when>
      <xsl:when test="contains($key,'fik')">Sted (fikt.)</xsl:when>
      <xsl:otherwise>Sted</xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  
  <xsl:template name="bible-reference">
    <xsl:param name="rend" select="''"/>
    <xsl:param name="key"  select="''"/>

    <!--
    "allusion"          "allusion til {@key}"               
    "reference"         "jf. {@key}"              
    "eg"                "jf. f.eks. {@key}"               
    "normForm"          "{@key}"               
    "quote"             "{@key}"               
    "allusion1787"      "allusion til {@key} (1787)"               
    "normForm1787"      "{@key} (1787)"               
    "reference1787"     "jf. {@key} (1787)"              
    "eg1787"            "jf. f.eks. {@key} (1787)"               
    "quote1787"         "{@key} (1787)"
    -->

    <xsl:choose>
      <xsl:when test="contains($rend,'allusion')">
        allusion til <xsl:value-of select="$key"/> <xsl:if test="substring-after($rend,'allusion')"> (<xsl:value-of select="substring-after($rend,'allusion')"/>)</xsl:if>
      </xsl:when>
      <xsl:when test="contains($rend,'reference')">
        jf. <xsl:value-of select="$key"/> <xsl:if test="substring-after($rend,'reference')"> (<xsl:value-of select="substring-after($rend,'reference')"/>)</xsl:if>
      </xsl:when>
      <xsl:when test="contains($rend,'eg')">
        jf. f.eks. <xsl:value-of select="$key"/> <xsl:if test="substring-after($rend,'eg')"> (<xsl:value-of select="substring-after($rend,'eg')"/>)</xsl:if>
      </xsl:when>
      <xsl:when test="contains($rend,'normForm')">
        <xsl:value-of select="$key"/> <xsl:if test="substring-after($rend,'normForm')"> (<xsl:value-of select="substring-after($rend,'normForm')"/>)</xsl:if>
      </xsl:when>
      <xsl:when test="contains($rend,'quote')">
        <xsl:value-of select="$key"/> <xsl:if test="substring-after($rend,'quote')"> (<xsl:value-of select="substring-after($rend,'quote')"/>)</xsl:if>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$key"/></xsl:otherwise>
    </xsl:choose>

    
  </xsl:template>

  <!-- this matches rows in pers.xml -->
  <xsl:template match="t:row[@role]">
    <p class="pers_entry">
      <xsl:for-each select="t:cell[@rend='name']">
        <!-- xsl:apply-templates select="."/ -->
        <xsl:apply-templates select="t:note[@type='firstName']"/><xsl:if test="t:note[@type='lastName']"><xsl:text> </xsl:text><xsl:apply-templates select="t:note[@type='lastName']"/></xsl:if><xsl:if test="position()=last() and ../t:cell[@rend='year']">, </xsl:if>
      </xsl:for-each>
      <xsl:if test="t:cell[@rend='year']"><xsl:value-of select="t:cell[@rend='year']"/>. </xsl:if>
      <xsl:if test="t:cell[@rend='nation']">
        <xsl:value-of select="t:cell[@rend='nation']"/><xsl:text>
        </xsl:text>
      </xsl:if>
      <xsl:if test="t:cell[@rend='encyc']">
        <p><xsl:value-of select="t:cell[@rend='encyc']"/></p>
      </xsl:if>
      <!-- xsl:if test="t:cell[@rend='facts']">
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:value-of select="concat('gv-registre-pers-root#',t:cell[@rend='facts']/@xml:id)"/>
          </xsl:attribute>
          mere
        </xsl:element>
      </xsl:if -->
    </p>
  </xsl:template>

  <xsl:template match="t:note/t:addName"><xsl:text> (</xsl:text><xsl:apply-templates/>)</xsl:template>
  
  <!-- this matches rows in title.xml -->
  <xsl:template match="t:row[t:cell[contains(@type,'Title')]]">
    <p class="bib_entry">

    <xsl:for-each select="t:cell[@type='mainAuthor']|t:cell[@type='coAuthor']">
      <xsl:if test="position() &gt; 1"><xsl:choose><xsl:when test="position() = last()"> og </xsl:when><xsl:otherwise>, </xsl:otherwise></xsl:choose></xsl:if><xsl:apply-templates select="."/><xsl:if test="position() = last()"><xsl:text>. </xsl:text></xsl:if>
    </xsl:for-each>

    <xsl:apply-templates select="t:cell[@type='partTitle']"/>

 
    <xsl:if test="t:cell[@type='mainTitle']">
      <em><xsl:apply-templates select="t:cell[@type='mainTitle']"/></em></xsl:if><xsl:if test="t:cell[@type='translatedTitle']"> [<xsl:apply-templates select="t:cell[@type='translatedTitle']"/>]</xsl:if>.

      
    <xsl:if test="t:cell[@type='volume']">Vol. <xsl:apply-templates select="t:cell[@type='volume']"/>.
    </xsl:if>

    <xsl:if test="t:cell[@type='editor']">Red:
    <xsl:for-each select="t:cell[@type='editor']">
          <xsl:if test="position() &gt; 1"><xsl:choose><xsl:when test="position() = last()"> og </xsl:when><xsl:otherwise>, </xsl:otherwise></xsl:choose></xsl:if><xsl:apply-templates select="."/><xsl:if test="position() = last()"><xsl:text>. </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:if>
    
    
    <xsl:if test="t:cell[@type='pubPlace']">
      <xsl:apply-templates select="t:cell[@type='pubPlace']"/><xsl:if test="t:cell[@type='pubYear']">, </xsl:if>
      <xsl:apply-templates select="t:cell[@type='pubYear']"/>.</xsl:if>
    </p>
  </xsl:template>

  <xsl:template match="t:cell[@type='mainAuthor']">
     <xsl:apply-templates select="t:note[@type='firstName']"/><xsl:text> </xsl:text><xsl:apply-templates select="t:note[@type='lastName']"/>
  </xsl:template>

  <xsl:template match="t:cell[@type='coAuthor']">
    <xsl:apply-templates select="t:note[@type='firstName']"/><xsl:text> </xsl:text><xsl:apply-templates select="t:note[@type='lastName']"/>
  </xsl:template>

  <xsl:template match="t:cell[@type='editor']">
    <xsl:apply-templates select="t:note[@type='firstName']"/><xsl:text> </xsl:text><xsl:apply-templates select="t:note[@type='lastName']"/>
  </xsl:template>
  
  <xsl:template match="t:note[@type='firstName']"><xsl:apply-templates/></xsl:template>

  <xsl:template match="t:note[@type='lastName']"><xsl:apply-templates/></xsl:template>

  <xsl:template match="t:cell[@rend='year']/text()">
    (<xsl:value-of select="."/>)
  </xsl:template>

  

  
</xsl:transform>
