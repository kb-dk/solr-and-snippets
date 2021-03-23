<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:me="urn:my-things"
    exclude-result-prefixes="t me"
    version="2.0">

  <xsl:param name="id" select="''"/>
  <xsl:param name="doc" select="''"/>
  <xsl:param name="file" select="fn:replace($doc,'.*/([^/]+)$','$1')"/>
  <xsl:param name="prev" select="''"/>
  <xsl:param name="prev_encoded" select="''"/>
  <xsl:param name="next" select="''"/>
  <xsl:param name="next_encoded" select="''"/>
  <xsl:param name="c" select="''"/>
  <xsl:param name="hostname" select="''"/>
  <xsl:param name="hostport" select="''"/>
  <xsl:param name="adl_baseuri">
    <xsl:choose>
      <xsl:when test="$hostport">
	<xsl:value-of select="concat('http://',$hostport)"/>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="facslinks" select="''"/>
  <xsl:param name="path" select="''"/>
  <xsl:param name="capabilities" select="''"/>
  <xsl:param name="cap" select="document($capabilities)"/>

  <xsl:output method="xml"
	      encoding="UTF-8" />

  <xsl:template match="/">
    <xsl:element name="div">
      <xsl:attribute name="class"><xsl:value-of select="concat('collection-',$c)"/></xsl:attribute>
      <xsl:attribute name="id">root</xsl:attribute>
      <xsl:choose>
        <xsl:when test="$id">
	  <xsl:for-each select="//node()[$id=@xml:id]">
	    <xsl:apply-templates select="."/>
	  </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
	  <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:TEI">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:teiHeader"/>

  <xsl:template match="t:group">
    <xsl:apply-templates select="t:text"/>
  </xsl:template>

  <xsl:template match="t:text">
    <xsl:comment> text </xsl:comment>
    <div>
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:front">
    <xsl:comment> front </xsl:comment>
    <div>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:titlePage">
    <div class="title-page">
      <xsl:apply-templates/>   
    </div>
  </xsl:template>

  <xsl:template match="t:publisher">
    <span class="title-page-doc-publisher">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="t:titlePage/t:docAuthor">
    <h2 class="title-page-doc-author">
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="t:titlePage/t:docTitle">
    <h1 class="title-page-doc-title">
      <xsl:apply-templates/>
    </h1>
  </xsl:template>

  <xsl:template match="t:titlePage/t:docImprint">
    <h3 class="title-page-doc-imprint">
      <xsl:apply-templates/>
    </h3>
  </xsl:template>

  <xsl:template match="t:body">
    <xsl:comment> body </xsl:comment>
    <div>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:back">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:div[@decls]/t:head">
    <h1 style="text-align:center;" class="head-in-work"><xsl:call-template name="add_id"/><xsl:apply-templates/></h1>
  </xsl:template>

  <xsl:template match="t:div">
    <div>
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:comment> div here <xsl:value-of select="@decls"/> </xsl:comment>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:listBibl">
    <div>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:bibl">
    <p>
      <xsl:call-template name="add_id"/>
      <xsl:comment> bibl </xsl:comment>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="t:persName|t:placeName">
    <xsl:variable name="entity">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">person</xsl:when>
	<xsl:otherwise>place</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="symbol">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">&#128100;</xsl:when>
	<xsl:otherwise>&#128204;</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:choose>
	<xsl:when test="contains(local-name(.),'pers')">Person</xsl:when>
	<xsl:otherwise>Plads</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <span class="{$entity}">
      <xsl:attribute name="title">
	<xsl:value-of select="$title"/><xsl:if test="@key">: <xsl:value-of select="@key"/></xsl:if>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
      <span class="symbol {$entity}">
	<xsl:value-of select="$symbol"/>
      </span>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="t:title">
    <em class="title" title="Titel">
      <xsl:call-template name="add_id"/>
      <span class="symbol title">&#128214;</span><xsl:text> </xsl:text>
      <xsl:apply-templates/>
    </em>
  </xsl:template>

  <xsl:template match="t:eg">
    <p class="eg">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="t:quote">
    <blockquote class="quote" style="margin-left:+5%;">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </blockquote>
  </xsl:template>

  <xsl:template match="t:quote/t:p">
    <xsl:apply-templates/><br/>
  </xsl:template>

  <xsl:template match="t:head/t:lb"><xsl:text> </xsl:text></xsl:template>

  <xsl:template match="t:head">
    <xsl:if test="./node()">
      <h2 style="text-align:center;"  class="head-in-text">
	<xsl:call-template name="add_id"/>
	<xsl:apply-templates/>
      </h2>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:dateline"><span>
    <xsl:call-template name="add_id"/>
    <xsl:apply-templates/></span></xsl:template>

  <xsl:template match="t:dateline/t:date">
    <span>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="t:div/t:p|t:text/t:p|t:body/t:p">
    <p class="paragraph">
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </p>
    <xsl:call-template name="make_author_note_list"/>
  </xsl:template>

  <xsl:template match="t:p">
    <p class="paragraph">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </p>
    <xsl:call-template name="make_author_note_list"/>
  </xsl:template>

  <xsl:template match="t:lb">
    <xsl:element name="br">
      <xsl:call-template name="add_id_empty_elem"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:lg[t:lg]">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:lg">
    <xsl:if test="@n">
      <p title="Strofenumre" style="margin-left:+15%; text-align: right; width:3%;font-size:80%;float:left;">
        <xsl:choose>
          <xsl:when test="@xml:id">
            <xsl:element name="a">
              <xsl:attribute name="style">text-decoration: none;</xsl:attribute>
              <xsl:attribute name="href"><xsl:value-of select="concat('#',@xml:id)"/></xsl:attribute>
              <xsl:value-of select="@n"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise><xsl:value-of select="@n"/></xsl:otherwise>
        </xsl:choose>
      </p>
    </xsl:if>
    <p class="lineGroup" style="margin-left:+20%;">
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </p>
    <xsl:call-template name="make_author_note_list"/>
  </xsl:template>

  <xsl:template match="t:l">
    <xsl:apply-templates/>
    <xsl:element name="br">
      <xsl:call-template name="add_id_empty_elem"/>
      <xsl:attribute name="class">line</xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:anchor">
    <xsl:element name="a">
      <xsl:attribute name="name"><xsl:value-of select="@xml:id"/></xsl:attribute>
      <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      <xsl:text> 
      </xsl:text>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:ref">
    <xsl:choose>
      <xsl:when test="fn:matches(@target,'^#')">
	<xsl:element name="a">
	  <xsl:attribute name="href">
	    <xsl:value-of select="@target/string()"/>
	  </xsl:attribute> 
	  <xsl:apply-templates/>
	</xsl:element>
      </xsl:when>
      <xsl:when test="fn:matches(@target,'^https?')">
	<xsl:element name="a">
	  <xsl:attribute name="href">
	    <xsl:value-of select="@target/string()"/>
	  </xsl:attribute> 
	  <xsl:apply-templates/>
	</xsl:element>
      </xsl:when>
      <xsl:when test="contains(@target,'AdlPageRef.xsql')">
	<xsl:apply-templates/>
      </xsl:when>
       <xsl:otherwise>
	<xsl:element name="a">
	  <xsl:if test="@target">
	    <xsl:attribute name="href">
	      <xsl:call-template name="make-href"/>
	    </xsl:attribute> 
	  </xsl:if>
	  <xsl:call-template name="add_id"/>
	  <xsl:apply-templates/>
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="t:table">
    <table>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match="t:row">
    <tr>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>

  <xsl:template match="t:cell">
    <td>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <xsl:template match="t:castList">
    <div class="castList">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:castItem">
    <p class="castItem">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="t:castItem/t:role">
    <strong class="role">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>

  <xsl:template match="t:castItem/t:actor">
    <span class="actor">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="t:list[@type='ordered']">
    <ol><xsl:call-template name="add_id"/><xsl:apply-templates/></ol>
  </xsl:template>

  <xsl:template match="t:list">
    <ul><xsl:call-template name="add_id"/><xsl:apply-templates/></ul>
  </xsl:template>

  <xsl:template match="t:list[@type='TOC']">
    <p style="padding-left: 1em;" >
      <xsl:call-template name="add_id"/>
      <xsl:for-each select="t:item">
	<xsl:apply-templates/>
	<xsl:element name="br">
	  <xsl:call-template name="add_id"/>
	</xsl:element>
      </xsl:for-each>
    </p>
  </xsl:template>

  <xsl:template match="t:list[t:label]">
    <div style="padding-left: 1.5em;">
      <xsl:call-template name="add_id"/>
      <xsl:for-each select="t:item">
	<p style="text-indent: -1em;" >
	  <strong>
	    <xsl:value-of select="preceding::t:label[1]"/>
	  </strong><xsl:text>
</xsl:text> <xsl:apply-templates/>
	</p>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="t:hi[@rend='initial']">
    <strong style="font-size: 120%"><xsl:call-template name="add_id"/><xsl:apply-templates/></strong>
  </xsl:template>

  
  <xsl:template match="t:hi[@rend='bold']|t:hi[@rend='bold']|t:emph[@rend='bold']">
    <strong><xsl:call-template name="add_id"/><xsl:apply-templates/></strong>
  </xsl:template>

  <xsl:template match="t:hi[@rend='italics']|t:emph[@rend='italics']">
    <em><xsl:call-template name="add_id"/><xsl:apply-templates/></em>
  </xsl:template>

  <xsl:template match="t:hi[@rend='spat']">
    <em><xsl:call-template name="add_id"/><xsl:apply-templates/></em>
  </xsl:template>

  <xsl:template match="t:hi[@rendition]">
    <span><xsl:call-template name="add_id"/><xsl:apply-templates/></span>
  </xsl:template>


  <xsl:template match="t:list/t:item">
    <li><xsl:call-template name="add_id"/><xsl:apply-templates/></li>
  </xsl:template>

  <xsl:template match="t:item">
    <p><xsl:call-template name="add_id"/><xsl:apply-templates/></p>
  </xsl:template>

  <!-- hide figures that don't contain graphics -->
  <xsl:template match="t:figure">
    <xsl:if test="t:graphic/@url or @type">
      <xsl:element name="div">
	<xsl:call-template name="add_id"/>
	<xsl:apply-templates/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:figure/t:head">
    <p>
      <xsl:call-template name="add_id"/>
      <small>
	<xsl:apply-templates/>
      </small>
    </p>
  </xsl:template>

  <xsl:template match="t:facsimile"><!-- the facsimile section shouldn't be rendered --></xsl:template>
  
  <xsl:template match="t:address">
    <xsl:element name="br">
      <xsl:call-template name="add_id_empty_elem"/>
    </xsl:element>
    <xsl:for-each select="t:addrLine">
      <xsl:apply-templates/><xsl:element name="br"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="t:ptr">
    <a>
      <xsl:attribute name="href">
	<xsl:call-template name="make-href"/>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:choose>
	<xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when>
	<xsl:otherwise><xsl:text>*</xsl:text></xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <xsl:template match="t:sp">
    <dl class="speak">
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <dt class="speaker">
	<xsl:apply-templates select="t:speaker"/>
      </dt>
      <dd class="thespoken">
	<xsl:apply-templates select="t:stage|t:p|t:lg|t:pb|t:l"/>
      </dd>
    </dl>
    <xsl:call-template name="make_author_note_list"/>
  </xsl:template>

  <xsl:template match="t:stage/t:p">
    <p class="paragraph">
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">false</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="t:speaker">
    <xsl:element name="span">
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">false</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:element>
    <xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="t:sp/t:stage|t:p/t:stage|t:lg/t:stage|t:l/t:stage">
    <em class="stage"><xsl:text>
      </xsl:text><xsl:element name="span">
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">false</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:element></em><xsl:text>
    </xsl:text>
  </xsl:template>


  <xsl:template match="t:stage">
    <xsl:element name="p">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:milestone"/>
  
  <xsl:template match="t:pb">
    <xsl:variable name="first">
      <xsl:value-of select="count(preceding::t:pb[@facs])"/>
    </xsl:variable>
    <xsl:if test="local-name(preceding::element()[1])='pb' and preceding::element()[1][@facs and not(@type='periText')]">
    </xsl:if>
    <xsl:if test="@facs and $first &gt; 0">
      <xsl:element name="span">
	<xsl:attribute name="title">Side <xsl:value-of select="@n"/></xsl:attribute>
	<xsl:call-template name="add_id_empty_elem"/>
	<xsl:attribute name="class">pageBreak</xsl:attribute>
	<xsl:if test="@n">
	  <xsl:element name="a">
            <xsl:if test="@xml:id">
              <xsl:attribute name="href">
	        <xsl:value-of select="concat('#',@xml:id)"/>
              </xsl:attribute>
            </xsl:if>
	    <small><xsl:value-of select="@n"/></small>
	  </xsl:element>
	</xsl:if>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="add_id">
    <xsl:param name="expose" select="'false'"/>
    <xsl:call-template name="add_id_empty_elem"/>
    <xsl:if test="$id = @xml:id">
      <xsl:attribute name="class">text snippetRoot</xsl:attribute>      
    </xsl:if>
    <xsl:choose>
      <xsl:when test="not(descendant::node())"><xsl:text>
</xsl:text></xsl:when>
      <!-- xsl:when test="not(descendant::node())"><xsl:comment>Instead of content</xsl:comment></xsl:when -->
      <xsl:otherwise>
	<xsl:if test="$expose = 'true'">
	  <xsl:call-template name="expose_link"/>
	</xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@decls">
      <xsl:call-template name="add_prev_next"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="add_prev_next">
  </xsl:template>

  <xsl:template name="add_id_empty_elem">
    <xsl:if test="@xml:id">
      <xsl:attribute name="id">
	<xsl:value-of select="@xml:id"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="get_prev_id">
    <xsl:value-of
	select="preceding::node()[@decls and @xml:id][1]/@xml:id"/>
  </xsl:template>

  <xsl:template name="get_next_id">
    <xsl:value-of
	select="following::node()[@decls and @xml:id][1]/@xml:id"/>
  </xsl:template>


 <xsl:template match="t:msDesc">
    <div>
      <xsl:call-template name="add_id"/>
      <xsl:attribute name="style">indent-left:+1em;</xsl:attribute>
      <xsl:apply-templates/>
    </div>
    <p style="clear:both;">
      <xsl:text> 
      </xsl:text>      
    </p>
  </xsl:template>

  <xsl:template match="t:msPart">
    <div>
      <xsl:call-template name="add_id"/>
      <xsl:attribute name="style">float:left; width:85%;</xsl:attribute>
      <xsl:apply-templates/>
      <br style="clear:both;"/>
    </div>
  </xsl:template>

  <xsl:template match="t:adminInfo">
<!-- Content model herej is 
     t:note|t:availability|t:custodialHist|t:recordHist|t:witDetail -->
    <div>
      <xsl:call-template name="add_id"/>
      <xsl:attribute name="style">float:left; width:85%;</xsl:attribute>
      <xsl:apply-templates select="t:note/t:p"/>
    </div>
  </xsl:template>

  <xsl:template match="t:msIdentifier">
    <p>
      <xsl:attribute name="style">float:left; width:8%;</xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="t:collection|t:idno">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:physDesc|t:additional">
    <div style="font-size: 80%;">
      <xsl:call-template name="add_id"/>
      <xsl:attribute name="style">float:left; width:85%;</xsl:attribute>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="t:physDesc/t:p">
    <xsl:apply-templates/>
    <xsl:element name="br"><xsl:call-template name="add_id_empty_elem"/></xsl:element>
  </xsl:template>

  <xsl:function name="me:looks_like">
    <xsl:variable name="what">
      <xsl:for-each select="$cap//t:ref|$cap//t:relatedItem">
	<xsl:if test="contains($doc,@target)">
	  <xsl:value-of select="@type"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$what">
	<xsl:value-of select="$what"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template name="expose_link">
    <xsl:variable name="link_id">
      <xsl:value-of select="concat('expose_link_',@xml:id)"/>
    </xsl:variable>
    <xsl:variable name="type">
      <xsl:choose>
	<xsl:when test="contains($path,'-root')">-root</xsl:when>
	<xsl:otherwise>-shoot</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="href">
      <xsl:choose>
	<xsl:when test="contains($path,@xml:id)">
	  <xsl:choose>
	    <xsl:when test="ancestor::node()[@decls][1]/@xml:id">
	      <xsl:value-of 
		  select="concat($adl_baseuri,'/text/',substring-before($path,$type),'-shoot-',ancestor::node()[@decls][1]/@xml:id)"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="concat($adl_baseuri,'/text/',substring-before($path,$type),'-root#',@xml:id)"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="concat($adl_baseuri,'/text/',substring-before($path,$type),'-shoot-',@xml:id)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
   
    <xsl:element name="span">
      <!-- xsl:attribute name="class">exposableDocumentFunctions</xsl:attribute>
      <xsl:attribute name="style">display:none;</xsl:attribute -->
      <xsl:attribute name="id"><xsl:value-of select="$link_id"/></xsl:attribute>

      <xsl:if test="not(contains($href,'adl-authors') or contains($href,'adl-periods') )">
	<xsl:variable name="class">
	  <xsl:choose>
	    <xsl:when test="contains($path,@xml:id)">the_whole</xsl:when>
	    <xsl:otherwise>quote</xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<xsl:variable name="text">
	  <xsl:choose>
	    <xsl:when test="contains($path,@xml:id)">Vis det hele</xsl:when>
	    <xsl:otherwise>Vis kun denne del</xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<xsl:variable name="symbol">
	  <xsl:choose>
	    <xsl:when test="contains($path,@xml:id)">&#8617; </xsl:when>
	    <xsl:otherwise>&#9986; </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<xsl:element name="a">
	  <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
          <xsl:attribute name="rel">nofollow</xsl:attribute>
	  <xsl:attribute name="href"><xsl:value-of select="$href"/></xsl:attribute>
	  <xsl:element name="span">
	    <xsl:attribute name="class">symbol <xsl:value-of select="$class"/></xsl:attribute>
	    <xsl:attribute name="title"><xsl:value-of select="$text"/></xsl:attribute>
            <xsl:value-of select="$symbol"/>
	  </xsl:element>
	</xsl:element>
      </xsl:if>

      <xsl:call-template name="doc_relations"/>
      <xsl:text>
      </xsl:text>
    </xsl:element>
  </xsl:template>

  <xsl:template name="doc_relations">

  </xsl:template>

</xsl:stylesheet>
