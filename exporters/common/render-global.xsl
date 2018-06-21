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
	      encoding="UTF-8"
	      indent="yes"/>

  <xsl:template match="/">
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
  </xsl:template>

  <xsl:template match="t:TEI">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:teiHeader"/>

  <xsl:template match="t:group">
    <xsl:apply-templates select="t:text"/>
  </xsl:template>

  <xsl:template match="t:text">
    <div>
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>

      <xsl:comment> text </xsl:comment>

      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:front">
    <div>
      <xsl:call-template name="add_id"/>

      <xsl:comment> front </xsl:comment>


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
    <div>
      <xsl:call-template name="add_id"/>
      <xsl:comment> body </xsl:comment>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:back">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:div[@decls]/t:head">
    <h1 class="head-in-work"><xsl:call-template name="add_id"/><xsl:apply-templates/></h1>
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

  <xsl:template match="t:note">
    <xsl:call-template name="inline_note"/>
  </xsl:template>

  <xsl:template name="inline_note">
    <xsl:variable name="idstring">
      <xsl:value-of select="translate(@xml:id,'-;.','___')"/>
    </xsl:variable>
    <xsl:variable name="note">
      <xsl:value-of select="concat('note',$idstring)"/>
    </xsl:variable>
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
	<xsl:if test="@type='author'">
	  <xsl:attribute name="title">Forfatterens note.</xsl:attribute>
	</xsl:if>
	<xsl:choose>
	  <xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when>
	  <xsl:otherwise>*</xsl:otherwise>
	</xsl:choose>
      </xsl:element>
    </xsl:element>
    <span style="background-color:yellow;display:none;">
      <xsl:call-template name="add_id"/>
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template match="t:eg">
    <p class="eg">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="t:quote">
    <q class="quote">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </q>
  </xsl:template>

  <xsl:template match="t:head">
    <h2 class="head-in-text">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </h2>
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
  </xsl:template>

  <xsl:template match="t:p">
    <p class="paragraph">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </p>
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
    <p class="lineGroup">
      <xsl:call-template name="add_id">
	<xsl:with-param name="expose">true</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </p>
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
      <!-- xsl:when test="contains(@target,'../texts/')">
	<xsl:element name="a">
	  <xsl:call-template name="add_id"/>
	  <xsl:variable name="frag">
	    <xsl:value-of select="substring-after(@target,'xml#')"/>
	  </xsl:variable>
	  <xsl:variable name="file_id">
	    <xsl:value-of select="substring-before(substring-after(@target,'texts/'),'.xml')"/>
	  </xsl:variable>
	  <xsl:comment>
	    This is were there should have been a link to
	    <xsl:value-of select="concat('./',$file_id,'#',$frag)"/>
	  </xsl:comment>
	  <xsl:apply-templates/>
	</xsl:element>
      </xsl:when -->
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
r    <p><xsl:call-template name="add_id"/><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="t:figure">
    <xsl:element name="div">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
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

  <xsl:template match="t:facsimile"><!-- the facsimile section shouldn't be rendered --></xsl:template>

  <xsl:template match="t:graphic">
    <xsl:element name="img">
      <xsl:attribute name="src">
	<xsl:apply-templates select="@url"/>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
    </xsl:element>
  </xsl:template>
  
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
  
  <xsl:template match="t:pb">
    <xsl:variable name="first">
      <xsl:value-of select="count(preceding::t:pb)"/>
    </xsl:variable>

    <xsl:if test="$first &gt; 0">
      <xsl:element name="span">
	<xsl:attribute name="title">Side <xsl:value-of select="@n"/></xsl:attribute>
	<xsl:call-template name="add_id_empty_elem"/>
	<xsl:attribute name="class">pageBreak</xsl:attribute>
	<xsl:if test="@n">
	  <xsl:element name="a">
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
      <xsl:when test="not(descendant::node())">
	<xsl:comment>Instead of content</xsl:comment>
      </xsl:when>
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

  <xsl:template match="t:msDesc|t:msPart|t:additional">
    <div>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="t:adminInfo">
    <span>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates mode="biblio_note" />
    </span>
  </xsl:template>

  <xsl:template mode="biblio_note" match="t:note">
    <span>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>


  <xsl:template match="t:msIdentifier">
    <span>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="t:collection">
    <strong>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>

  <xsl:template match="t:physDesc">
    <div style="font-size: 90%;">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="t:physDesc/t:p">
    <xsl:apply-templates/>
    <xsl:element name="br">
      <xsl:call-template name="add_id_empty_elem"/>      
    </xsl:element>
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
	  <xsl:value-of select="concat($adl_baseuri,'/text/',substring-before($path,$type),'-root#',@xml:id)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="concat($adl_baseuri,'/text/',substring-before($path,$type),'-shoot-',@xml:id)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- xsl:attribute name="onMouseOver">document.getElementById('<xsl:value-of select="$link_id"/>').style.visibility='visible'</xsl:attribute>
    <xsl:attribute name="onMouseOut">document.getElementById('<xsl:value-of select="$link_id"/>').style.visibility='hidden'</xsl:attribute -->
    <xsl:element name="span">
      <xsl:attribute name="class">exposableDocumentFunctions</xsl:attribute>
      <xsl:attribute name="style">visibility:hidden;display:block;</xsl:attribute>
      <xsl:attribute name="id"><xsl:value-of select="$link_id"/></xsl:attribute>

      <xsl:if test="not(contains($href,'adl-authors') or contains($href,'adl-periods') )">
	<xsl:element name="a">
	  <xsl:attribute name="href"><xsl:value-of select="$href"/></xsl:attribute>
	  <xsl:choose>
	    <xsl:when test="contains($path,@xml:id)">Vis det hele</xsl:when>
	    <xsl:otherwise><i class="fa fa-scissors" aria-hidden="true">&#160;</i>Vis kun denne del</xsl:otherwise>
	  </xsl:choose>
	</xsl:element>
      </xsl:if>
      <xsl:call-template name="doc_relations"/>

      <xsl:text>&#160;</xsl:text>

    </xsl:element>

  </xsl:template>

  <xsl:template name="doc_relations">

  </xsl:template>

</xsl:stylesheet>
