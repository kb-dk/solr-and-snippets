<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="str"
    exclude-result-prefixes="t str"
    version="1.0">

  <xsl:param name="id" select="''"/>
  <xsl:param name="doc" select="''"/>
  <xsl:param name="prev" select="''"/>
  <xsl:param name="prev_encoded" select="''"/>
  <xsl:param name="next" select="''"/>
  <xsl:param name="next_encoded" select="''"/>
  <xsl:param name="file" select="''"/>
  <xsl:param name="hostname" select="''"/>
  <xsl:param name="facslinks" select="''"/>

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
      <xsl:call-template name="add_id"/>

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
    <p style="font-style:italic;">
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="t:div">
    <div>
      <xsl:call-template name="add_id"/>
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

  <!-- xsl:template match="t:p/t:note" -->

  <xsl:template match="t:note">
    <xsl:variable name="note">
      <xsl:value-of select="concat('note',@xml:id)"/>
    </xsl:variable>
    <xsl:element name="sup">
      <script>
	var <xsl:value-of select="concat('disp',@xml:id)"/>="none";
	function <xsl:value-of select="$note"/>() {
	var ele = document.getElementById("<xsl:value-of select="@xml:id"/>");
	if(<xsl:value-of select="concat('disp',@xml:id)"/>=="none") {
	ele.style.display="inline";
	<xsl:value-of select="concat('disp',@xml:id)"/>="inline";
	} else {
	ele.style.display="none";
	<xsl:value-of select="concat('disp',@xml:id)"/>="none";
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
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- xsl:template match="t:note">
    <div class="note">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template-->


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
    <h2 class="head">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </h2>
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

  <xsl:template match="t:lg">
    <p class="lineGroup">
      <xsl:call-template name="add_id"/>
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

  <xsl:template match="t:ref">
    <xsl:element name="a">
      <xsl:call-template name="add_id"/>
      <xsl:if test="@target">
	<xsl:attribute name="href">
	  <xsl:apply-templates select="@target"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
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

  <xsl:template match="t:list[@type='ordered']">
    <ol><xsl:call-template name="add_id"/><xsl:apply-templates/></ol>
  </xsl:template>

  <xsl:template match="t:list">
    <ul><xsl:call-template name="add_id"/><xsl:apply-templates/></ul>
  </xsl:template>

  <xsl:template match="t:hi[@rend='bold']|t:emph[@rend='bold']">
    <strong> <xsl:call-template name="add_id"/><xsl:apply-templates/></strong>
  </xsl:template>

  <xsl:template match="t:hi[@rend='italics']|t:emph[@rend='italics']">
    <em><xsl:call-template name="add_id"/><xsl:apply-templates/></em>
  </xsl:template>

  <xsl:template match="t:hi[@rend='spat']">
    <em><xsl:call-template name="add_id"/><xsl:apply-templates/></em>
  </xsl:template>

  <xsl:template match="t:item">
    <li><xsl:call-template name="add_id"/><xsl:apply-templates/></li>
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

  <xsl:template match="t:sp">
    <dl class="speak">
      <xsl:call-template name="add_id"/>
      <dt class="speaker">
	<xsl:apply-templates select="t:speaker"/>
      </dt>
      <dd class="thespoken">
	<xsl:apply-templates select="t:stage|t:p|t:lg|t:pb"/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="t:speaker">
    <xsl:element name="span">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </xsl:element>
    <xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="t:sp/t:stage|t:p/t:stage|t:lg/t:stage|t:l/t:stage">
    <em class="stage"><xsl:text>
      (</xsl:text><xsl:element name="span">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </xsl:element><xsl:text>) </xsl:text></em>
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
      <xsl:call-template name="add_id_empty_elem"/>
      <xsl:attribute name="class">pageBreak</xsl:attribute>
      <xsl:element name="a">
	<xsl:attribute name="data-no-turbolink">true</xsl:attribute>
	<xsl:if test="$facslinks">
	  <xsl:attribute name="href">
	    <xsl:choose>
	      <xsl:when test="$id">
		<xsl:value-of select="concat('/catalog/%2Fletter_books%2F',
				      substring-before($doc,'_'),
				      '%2F',
				      substring-before($doc,'.xml'),
				      '-',
				      $id,
				      '#',
				      'facsid', @xml:id)"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="concat('/letter_books/show_letter_and_facsimile?sid=%2Fletter_books%2F',
				      substring-before($doc,'_'),
				      '%2F',
				      substring-before($doc,'.xml'),
				      '-',
				      $id,
				      '#',
				      'facsid', @xml:id)"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>
	</xsl:if>
	<xsl:text>s. </xsl:text>
	<small><xsl:value-of select="@n"/></small>
      </xsl:element>
    </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="add_id">
    <xsl:call-template name="add_id_empty_elem"/>
    <xsl:if test="$id = @xml:id">
      <xsl:attribute name="class">text snippetRoot</xsl:attribute>      
    </xsl:if>
 
    <xsl:if test="not(descendant::node())">
      <xsl:comment>Instead of content</xsl:comment>
    </xsl:if>
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

</xsl:stylesheet>
