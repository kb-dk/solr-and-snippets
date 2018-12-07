<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       xmlns:me="urn:my-things"
	       exclude-result-prefixes="t fn me"
               version="2.0">

  <!-- not a poisonous adder -->

  <xsl:output indent="yes"
              encoding="UTF-8"
              method="xml"/>

  <xsl:param name="app" select="'ADL'"/>
  <xsl:param name="category" select="'work'"/>
  <xsl:param name="doc" select="'a_very_unique_id'"/>
  <xsl:param name="basename" select="substring-before($doc,'.xml')"/>
  <xsl:param name="coll" select="''"/>
  <xsl:param name="path" select="''"/>
  <xsl:param name="author" select="''"/>
  <xsl:param name="auid_used" select="''"/>
  <xsl:param name="copyright" select="''"/>

  <xsl:param name="capabilities" select="''"/>
  <xsl:param name="cap"  select="document($capabilities)"/>
 
  <xsl:param name="editor" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:respStmt">
      <xsl:apply-templates mode="gettext"  select="."/>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="editor_id" select="''"/>

  <xsl:param name="volume_title">
    <xsl:for-each select="(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title|/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title)[1]">
      <xsl:apply-templates mode="gettext"  select="."/>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="volume_sort_title">
    <xsl:for-each select="(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title|/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title)[1]">
      <xsl:call-template name="volume_sort_title"/>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="publisher" select="''"/>
  <xsl:param name="published_place" select="''"/>
  <xsl:param name="published_date" select="''"/>
  <xsl:param name="c" select="'unknown_collection'"/>
  <xsl:param name="url" select="concat($c,'/',$doc)"/>
  <xsl:param name="subcollection" select="'adl'"/>
  <xsl:param name="auid" select="''"/>
  <xsl:param name="perioid" select="''"/>

  <xsl:param name="is_monograph">
    <xsl:choose>
      <xsl:when test="count(//node()[@decls])&lt;2">yes</xsl:when>
      <xsl:otherwise>no</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="worktitle">
    <xsl:if test="contains($is_monograph,'yes')">
      <xsl:value-of select="$volume_title"/>
    </xsl:if>
  </xsl:param>

  <xsl:param name="license">Attribution-NonCommercial-ShareAlike CC BY-NC-SA</xsl:param>

  <xsl:template match="/">
    <xsl:element name="add">
      <xsl:choose>
	<xsl:when test="contains($path,'adl-authors')">
	  <xsl:call-template name="generate_volume_doc" >
	    <xsl:with-param name="cat" select="'author'"/>
	    <xsl:with-param name="type" select="'work'"/>
	  </xsl:call-template>
	  <xsl:apply-templates/>
	</xsl:when>
	<xsl:when test="contains($path,'adl-periods')">
	  <xsl:call-template name="generate_volume_doc" >
	    <xsl:with-param name="cat" select="'period'"/>
	    <xsl:with-param name="type" select="'work'"/>
	  </xsl:call-template>
	  <xsl:apply-templates/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="generate_volume_doc" />
	  <xsl:apply-templates/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:div[not(@decls) and  not(ancestor::node()[@decls])]">
    
      <xsl:call-template name="trunk_doc">
	<xsl:with-param name="worktitle" select="t:head[1]"/>
	<xsl:with-param name="category"><xsl:call-template name="get_category"/></xsl:with-param>
      </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="category"><xsl:call-template name="get_category"/></xsl:with-param>
      <xsl:with-param name="worktitle" select="t:head"/>
    </xsl:apply-templates>

  </xsl:template>


  <xsl:template name="get_category">
    <xsl:param name="category"/>
    <xsl:choose>
      <xsl:when test="contains($path,'adl-texts')"><xsl:value-of select="$category"/></xsl:when>
      <xsl:when test="contains($path,'adl-authors')">author</xsl:when>
      <xsl:when test="contains($path,'adl-periods')">period</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="t:text[not(@decls) and not(ancestor::node()[@decls])]">
    
    <xsl:call-template name="trunk_doc">
      <xsl:with-param name="worktitle" select="t:head"/>
      <xsl:with-param name="category">
	<xsl:call-template name="get_category"/>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="category">
	<xsl:call-template name="get_category"/>
      </xsl:with-param>
      <xsl:with-param name="worktitle" select="t:head"/>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="t:div[@decls]">
    <xsl:variable name="bibl" select="substring-after(@decls,'#')"/>
    <xsl:variable name="worktitle">
      <xsl:choose>
	<xsl:when 
	    test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:listBibl/t:bibl[@xml:id=$bibl]">
	  <xsl:value-of
              select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:listBibl/t:bibl[@xml:id=$bibl]"/>
	</xsl:when>
	<xsl:when test="t:head">
	  <xsl:value-of select="t:head"/>
	</xsl:when>
	<xsl:otherwise>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="trunk_doc">
      <xsl:with-param name="worktitle" select="$worktitle"/>
      <xsl:with-param name="category"  select="'work'"/>
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:apply-templates>

  </xsl:template>


  <xsl:template name="trunk_doc">
    <xsl:param name="worktitle" select="''"/>
    <xsl:param name="category"  select="''"/>
    <doc>

      <xsl:comment> trunk_doc </xsl:comment>

      <xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute><xsl:text>trunk</xsl:text></xsl:element>
      <xsl:element name="field"><xsl:attribute name="name">cat_ssi</xsl:attribute><xsl:value-of select="$category"/></xsl:element>
      <xsl:element name="field"><xsl:attribute name="name">is_monograph_ssi</xsl:attribute><xsl:value-of select="$is_monograph"/></xsl:element>

      <xsl:if test="$worktitle">
	<xsl:element name="field">
	  <xsl:attribute name="name">work_title_ssi</xsl:attribute>
	  <xsl:value-of select="$worktitle"/>
	</xsl:element>

	<xsl:element name="field">
	  <xsl:attribute name="name">sort_title_ssi</xsl:attribute>
	  <xsl:call-template name="str_massage">
	    <xsl:with-param name="str" select="$worktitle"/>
	  </xsl:call-template>
	</xsl:element>

	<xsl:element name="field">
	  <xsl:attribute name="name">volume_sort_title_ssi</xsl:attribute>
	  <xsl:call-template name="str_massage">
	    <xsl:with-param name="str" select="$volume_sort_title"/>
	  </xsl:call-template>
	</xsl:element>

	<xsl:element name="field">
	  <xsl:attribute name="name">work_title_tesim</xsl:attribute>
	  <xsl:value-of select="$worktitle"/>
	</xsl:element>
      </xsl:if>

      <xsl:call-template name="add_globals"/>

      <xsl:element name="field">
	<xsl:attribute name="name">text_tesim</xsl:attribute>
	<xsl:choose>
	  <xsl:when test="$category = 'editorial'">
	    <xsl:apply-templates mode="gettext" 
				 select="./text()|descendant::node()[not(@decls)]/text()"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates mode="gettext" 
				 select="./text()|descendant::node()/text()"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:element>

      <xsl:call-template name="text_type"/>


    </doc>
  </xsl:template>

  <xsl:template name="text_type"/>

  <xsl:template match="t:castList">

    <xsl:param name="worktitle" select="''"/>

    <doc>
      <xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute>leaf</xsl:element>
      <xsl:call-template name="add_globals"/>
      <xsl:element name="field">
        <xsl:attribute name="name">genre_ssi</xsl:attribute>
        <xsl:text>play</xsl:text>
      </xsl:element>
      <xsl:element name="field">
	<xsl:attribute name="name">text_tesim</xsl:attribute>
	<xsl:choose>
	  <xsl:when test="$category = 'editorial'">
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates mode="gettext" 
				 select="./text()|descendant::node()/text()"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:element>
    </doc>
  </xsl:template>

  <xsl:template match="t:sp">
    <xsl:param name="worktitle" select="''"/>

    <doc>

      <xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute>leaf</xsl:element>

      <xsl:call-template name="add_globals"/>

      <xsl:element name="field">
        <xsl:attribute name="name">genre_ssi</xsl:attribute>
        <xsl:text>play</xsl:text>
      </xsl:element>

      <xsl:element name="field">
        <xsl:attribute name="name">speaker_tesim</xsl:attribute>
        <xsl:value-of select="t:speaker"/>
      </xsl:element>

      <xsl:element name="field">
        <xsl:attribute name="name">speaker_ssim</xsl:attribute>
        <xsl:value-of select="t:speaker"/>
      </xsl:element>

      <xsl:element name="field">
        <xsl:attribute name="name">text_tesim</xsl:attribute>
        <xsl:apply-templates mode="gettext" 
			     select="./text()|descendant::node()/text()"/>
      </xsl:element>

    </doc>
  </xsl:template>

  <xsl:template match="t:lb">
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="t:lg[t:lg]">
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="t:lg">
    <xsl:param name="worktitle" select="''"/>

    <doc>

      <xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute>leaf</xsl:element>

      <xsl:call-template name="add_globals"/>

      <xsl:element name="field">
        <xsl:attribute name="name">genre_ssi</xsl:attribute>
        <xsl:text>poetry</xsl:text>
      </xsl:element>

      <xsl:for-each select="t:l">
        <xsl:element name="field">
          <xsl:attribute name="name">text_tesim</xsl:attribute>
          <xsl:apply-templates mode="gettext" 
			       select="./text()|descendant::node()/text()"/>
        </xsl:element>
      </xsl:for-each>
    </doc>
  </xsl:template>

  <xsl:template match="t:div/t:p|t:body/t:p|t:text/t:p">

    <xsl:param name="worktitle" select="''"/>

    <doc>

      <xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute>leaf</xsl:element>

      <xsl:call-template name="add_globals"/>

      <xsl:element name="field">
        <xsl:attribute name="name">genre_ssi</xsl:attribute>
        <xsl:text>prose</xsl:text>
      </xsl:element>

      <xsl:element name="field">
        <xsl:attribute name="name">text_tesim</xsl:attribute>
        <xsl:apply-templates mode="gettext" 
			     select="./text()|descendant::node()/text()"/>
      </xsl:element>
    </doc>
  </xsl:template>

  <xsl:template mode="gettext" match="text()">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="text()">
  </xsl:template>


  <xsl:template name="generate_volume_doc">
    <xsl:param name="type" select="'trunk'"/>
    <xsl:param name="cat" select="'volume'"/>
    <xsl:param name="is_monograph" select="$is_monograph"/>

    <doc>
      <xsl:comment> generate_volume_doc </xsl:comment>
      <xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute><xsl:value-of select="$type"/></xsl:element>
      <xsl:element name="field"><xsl:attribute name="name">cat_ssi</xsl:attribute><xsl:value-of select="$cat"/></xsl:element>
      <xsl:element name="field"><xsl:attribute name="name">is_monograph_ssi</xsl:attribute><xsl:value-of select="$is_monograph"/></xsl:element>

      <xsl:if test="string-length($volume_title)">
	<xsl:choose>
	  <xsl:when test="$is_monograph = 'yes'">
	    <xsl:element name="field">
	      <xsl:attribute name="name">work_title_tesim</xsl:attribute>
	      <xsl:value-of select="normalize-space($worktitle)"/>
	    </xsl:element>
	    <xsl:element name="field">
	      <xsl:attribute name="name">sort_title_ssi</xsl:attribute>
	      <xsl:call-template name="str_massage">
		<xsl:with-param name="str" select="$volume_sort_title"/>
	      </xsl:call-template>
	    </xsl:element>

	    <xsl:if test="contains($path,'adl-authors')">
	      <xsl:element name="field">
		<xsl:attribute name="name">inverted_name_title_ssi</xsl:attribute>
		<xsl:value-of select="$volume_sort_title"/>
	      </xsl:element>
	    </xsl:if>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:element name="field">
	      <xsl:attribute name="name">work_title_tesim</xsl:attribute>
	      <xsl:value-of select="normalize-space($volume_title)"/>
	    </xsl:element>
	    <xsl:element name="field">
	      <xsl:attribute name="name">sort_title_ssi</xsl:attribute>
	      <xsl:call-template name="str_massage">
		<xsl:with-param name="str" select="$volume_sort_title"/>
	      </xsl:call-template>
	    </xsl:element>

	    <xsl:if test="contains($path,'adl-authors')">
	      <xsl:element name="field">
		<xsl:attribute name="name">inverted_name_title_ssi</xsl:attribute>
		<xsl:value-of select="$volume_sort_title"/>
	      </xsl:element>
	    </xsl:if>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>

      <xsl:if test="/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt/t:idno[not(@type='ISBN')]">
	<xsl:variable name="idno">
	  <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt/t:idno[not(@type='ISBN')]"/>
	</xsl:variable>
	<xsl:element name="field">
	  <xsl:attribute name="name">sys_number_ssi</xsl:attribute>
	  <xsl:choose>
	    <xsl:when test="contains($idno,':')">
	      <xsl:value-of select="substring-before($idno,':')"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$idno"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:element>
      </xsl:if>

      <xsl:call-template name="add_globals" />

    </doc>
  </xsl:template>

  <xsl:template name="add_globals">

    <xsl:element name="field">
      <xsl:attribute name="name">id</xsl:attribute>
      <xsl:choose>
        <xsl:when test="@xml:id">
          <xsl:value-of select="concat(substring-before($path,'-root'),'-shoot-',@xml:id)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$path"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:if test="@xml:id">
      <xsl:element name="field">
	<xsl:attribute name="name">xmlid_ssi</xsl:attribute>
	<xsl:value-of select="@xml:id"/>
      </xsl:element>
    </xsl:if>

    <xsl:element name="field">
      <xsl:attribute name="name">volume_id_ssi</xsl:attribute>
      <xsl:value-of select="$path"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">url_ssi</xsl:attribute>
      <xsl:choose>
        <xsl:when test="@xml:id">
	  <xsl:value-of select="concat($url,'#',@xml:id)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$url"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:call-template name="page_info"/>

    <xsl:if test="$volume_title">
      <xsl:element name="field">
	<xsl:attribute name="name">volume_title_tesim</xsl:attribute>
	<xsl:value-of select="normalize-space($volume_title)"/>
      </xsl:element>
    </xsl:if>

    <xsl:if test="$volume_title">
      <xsl:element name="field">
	<xsl:attribute name="name">volume_title_ssi</xsl:attribute>
	<xsl:call-template name="str_massage">
	  <xsl:with-param name="str" select="$volume_title"/>
	</xsl:call-template>
      </xsl:element>
    </xsl:if>

    <xsl:if test="t:head|../t:head">
      <xsl:element name="field">
      <xsl:attribute name="name">head_tesim</xsl:attribute>
      <xsl:value-of select="normalize-space(fn:string-join(' ',(t:head|../t:head[1])))"/></xsl:element>
    </xsl:if>

    <xsl:call-template name="extract_titles_authors_etc"/>

    <xsl:call-template name="what_i_can"/>

    <xsl:if test="$auid">
      <xsl:element name="field">
	<xsl:attribute name="name">author_id_ssi</xsl:attribute>
	<xsl:value-of select="concat('adl-authors-',$auid_used,'-root')"/>
      </xsl:element>
    </xsl:if>

    <xsl:if test="$perioid">
      <xsl:element name="field">
	<xsl:attribute name="name">perioid_ssi</xsl:attribute>
	<xsl:value-of select="concat('adl-periods-',$perioid,'-root')"/>
      </xsl:element>
    </xsl:if>

    <xsl:element name="field">
      <xsl:attribute name="name">copyright_ssi</xsl:attribute>
      <xsl:value-of select="$license"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">editor_ssi</xsl:attribute>
      <xsl:value-of select="$editor"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">editor_id_ssi</xsl:attribute>
      <xsl:value-of select="$editor_id"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">position_isi</xsl:attribute>
      <xsl:value-of  select="count(preceding::node())"/>
    </xsl:element>

    <xsl:apply-templates mode="backtrack" select="ancestor::node()[1]"/>

    <field name="application_ssim">
      <xsl:value-of select="$app"/>
    </field>

    <field name="subcollection_ssi">
      <xsl:value-of select="$subcollection"/>
    </field>

  <xsl:call-template name="facs_and_text"/>

  </xsl:template>

  <xsl:template name="facs_and_text">
    <field name="has_facs_ssi">
      <xsl:choose>
	<xsl:when test="me:right_kind_of_page(.,/t:TEI)">yes</xsl:when>
	<xsl:otherwise>no</xsl:otherwise>
      </xsl:choose>
    </field>

    <field name="has_text_ssi">
      <xsl:choose>
	<xsl:when test="descendant-or-self::t:p/text()|descendant-or-self::t:l/text()">yes</xsl:when>
	<xsl:otherwise>no</xsl:otherwise>
      </xsl:choose>
    </field>

  </xsl:template>

  <xsl:template name="volume_sort_title">
    <xsl:choose>
      <xsl:when test="contains($path,'adl-authors') and t:name/@key">
	<xsl:value-of select="t:name/@key"/>
      </xsl:when>
      <xsl:when test="contains($path,'adl-periods') and t:name/@key">
	<xsl:value-of select="t:name/@key"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates mode="gettext"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*">
    <xsl:param name="worktitle" select="''"/>
    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="page_info">
    <xsl:variable name="pg" select="me:right_kind_of_page(.,/t:TEI)"/>
    <xsl:if  test="$pg">
      <xsl:element name="field">
        <xsl:attribute name="name">page_ssi</xsl:attribute>
        <xsl:value-of
                select="$pg/@n"/>
      </xsl:element>
      <xsl:element name="field">
        <xsl:attribute name="name">page_id_ssi</xsl:attribute>
        <xsl:value-of
                select="$pg/@xml:id"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="str_massage">
    <xsl:param name="str" select="''"/>
    <!-- believe that the strings below has to have the same lenght -->
     <xsl:variable name="meta"><xsl:text>!&apos;&quot;#%;,:.()-_'</xsl:text></xsl:variable>
    <xsl:variable name="space"><xsl:text>                        </xsl:text></xsl:variable>
    <xsl:variable name="str1" select="fn:lower-case($str)"/>
    <xsl:variable name="str2" select="translate(fn:string-join(' ',$str1),$meta,$space)"/>
    <xsl:variable name="str3" select="normalize-space($str1)"/>
    <xsl:value-of select="$str3"/>
  </xsl:template>

  <xsl:template name="author_ssim">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template mode="backtrack" match="node()[@xml:id]">
    <xsl:choose>
      <xsl:when test="@decls">
	<xsl:element name="field">
	  <xsl:attribute name="name">part_of_ssim</xsl:attribute>
	  <xsl:value-of select="concat(substring-before($path,'-root'),'-shoot-',@xml:id)"/>
	</xsl:element>
	<xsl:choose>
	  <xsl:when test="ancestor::node()">
	    <xsl:apply-templates mode="backtrack" select="ancestor::node()[1]"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:element name="field">
	      <xsl:attribute name="name">part_of_ssim</xsl:attribute>
	      <xsl:value-of select="$path"/>
	    </xsl:element>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates mode="backtrack" select="ancestor::node()[@decls][1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="extract_titles_authors_etc">
    <xsl:call-template name="common_extract_titles_authors_etc"/>
  </xsl:template>

  <xsl:template name="common_extract_titles_authors_etc">

    <xsl:choose>
      <xsl:when test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/node()">
	<xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc">
	  <xsl:for-each select="t:bibl">
	    <xsl:element name="field">
	      <xsl:attribute name="name">author_name_ssi</xsl:attribute>
	      <xsl:for-each select="t:author">
		<xsl:for-each 
		    select="t:name"><xsl:value-of 
		    select="normalize-space(.)"/><xsl:if test="not(position() = last())"><xsl:text>; </xsl:text></xsl:if>
		</xsl:for-each>
	      </xsl:for-each>
	    </xsl:element>
	    <xsl:for-each select="t:author">
	      <xsl:element name="field">
		<xsl:attribute name="name">author_name_ssim</xsl:attribute>
		<xsl:call-template name="author_ssim"/>
	      </xsl:element>
	      <xsl:element name="field">
		<xsl:attribute name="name">author_name_tesim</xsl:attribute>
		<xsl:choose>
		  <xsl:when test="t:name/t:forename">
		    <xsl:value-of select="t:name/t:forename"/>
		    <xsl:if test="t:name/t:surname">
		      <xsl:text> </xsl:text><xsl:value-of select="t:name/t:surname" />
		    </xsl:if>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:value-of select="."/>
		  </xsl:otherwise>
		</xsl:choose>
	      </xsl:element>
	      <xsl:element name="field">
		<xsl:attribute name="name">author_nasim</xsl:attribute>
		<xsl:choose>
		  <xsl:when test="t:name/t:forename">
		    <xsl:value-of select="t:name/t:forename"/>
		    <xsl:if test="t:name/t:surname">
		      <xsl:text> </xsl:text><xsl:value-of select="t:name/t:surname" />
		    </xsl:if>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:value-of select="."/>
		  </xsl:otherwise>
		</xsl:choose>
	      </xsl:element>
	    </xsl:for-each>
	    <xsl:element name="field">
	      <xsl:attribute name="name">publisher_tesim</xsl:attribute>
	      <xsl:for-each select="t:publisher">
		<xsl:value-of select="."/><xsl:if test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:if>
	      </xsl:for-each>
	    </xsl:element>
	    <xsl:element name="field">
	      <xsl:attribute name="name">publisher_nasim</xsl:attribute>
	      <xsl:for-each select="t:publisher">
		<xsl:value-of select="."/><xsl:if test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:if>
	      </xsl:for-each>
	    </xsl:element>


	    <xsl:element name="field">
	      <xsl:attribute name="name">place_published_tesim</xsl:attribute>
	      <xsl:for-each select="t:pubPlace">
		<xsl:value-of select="."/><xsl:if test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:if>
	      </xsl:for-each>
	    </xsl:element>
	    <xsl:element name="field">
	      <xsl:attribute name="name">place_published_nasim</xsl:attribute>
	      <xsl:for-each select="t:pubPlace">
		<xsl:value-of select="."/><xsl:if test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:if>
	      </xsl:for-each>
	    </xsl:element>


	    <xsl:element name="field">
	      <xsl:attribute name="name">date_published_ssi</xsl:attribute>
	      <xsl:for-each select="t:date">
		<xsl:value-of select="."/>
	      </xsl:for-each>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt">

	  <xsl:if test="string-length(t:title)">
	  <!-- xsl:element name="field">
	    <xsl:attribute name="name">work_title_ssi</xsl:attribute>
	    <xsl:call-template name="str_massage">
	      <xsl:with-param name="str">
		<xsl:for-each select="t:title">
		  <xsl:apply-templates mode="ssi" select="."/><xsl:if test="not(position() = last())"><xsl:text> </xsl:text></xsl:if>
		</xsl:for-each>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:element -->
	  </xsl:if>

	  <xsl:if test="t:title">
	    <!--
	    <xsl:element name="field">
	      <xsl:attribute name="name">work_title_tesim</xsl:attribute>
	      <xsl:value-of select="t:title"/>
	    </xsl:element>
	    -->
	  </xsl:if>

	  <xsl:element name="field">
	    <xsl:attribute name="name">author_name_tesim</xsl:attribute>
	    <xsl:value-of select="t:author"/>
	  </xsl:element>

	  <xsl:element name="field">
	    <xsl:attribute name="name">author_nasim</xsl:attribute>
	    <xsl:value-of select="t:author"/>
	  </xsl:element>

	  <xsl:element name="field">
	    <xsl:attribute name="name">author_name_ssi</xsl:attribute>
	    <xsl:choose>
	      <xsl:when test="not(position() = last())">
		<xsl:value-of select="concat(t:author,'; ')"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="t:author"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:element>

	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="me_looks_like">
    <xsl:variable name="what">
      <xsl:if test="$capabilities">
	<xsl:for-each select="$cap//t:ref|$cap//t:relatedItem">
	  <xsl:if test="contains($doc,@target)">
	    <xsl:value-of select="@type"/>
	  </xsl:if>
	</xsl:for-each>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$what">
	<xsl:value-of select="$what"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="what_i_can">
    <xsl:if test="$capabilities and ($cap//t:ref|$cap//t:relatedItem)">
      <xsl:element name="field">
	<xsl:attribute name="name">capabilities_ssi</xsl:attribute>
	<xsl:for-each select="$cap//t:ref|$cap//t:relatedItem">
	  <xsl:if test="not(contains(@type,'ignore'))">
	  <xsl:text>&lt;a href='</xsl:text><xsl:call-template name="inferred_path"><xsl:with-param name="document" select="@target"/></xsl:call-template><xsl:text>'></xsl:text><xsl:value-of select="@type"/><xsl:text>&lt;/a>
</xsl:text>
	  </xsl:if>
	</xsl:for-each>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:function name="me:right_kind_of_page">
    <xsl:param name="here"/>
    <xsl:param name="root"/>
    <xsl:choose>
      <xsl:when test="$here/preceding::t:pb[@facs and not(@rend = 'missing')]">
	<xsl:copy-of select="$here/preceding::t:pb[@facs and not(@rend = 'missing')][1]"/>
      </xsl:when>
      <xsl:when test="$here/descendant::t:pb[@facs and not(@rend = 'missing')]">
	<xsl:copy-of select="$here/descendant::t:pb[@facs and not(@rend = 'missing')][1]"/>
      </xsl:when>
      <xsl:otherwise>
      <xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


   <xsl:template name="inferred_path">
     <xsl:param name="document"/>
     <xsl:value-of select="$document"/>
   </xsl:template>

</xsl:transform>
