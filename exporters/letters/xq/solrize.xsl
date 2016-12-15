<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:t="http://www.tei-c.org/ns/1.0"
               exclude-result-prefixes="t"
               version="1.0">

  <!-- not a poisonous adder -->

  <xsl:output indent="yes"
	      omit-xml-declaration="no"
              encoding="UTF-8"
              method="xml"/>

  <xsl:param name="category" select="'letter'"/>
  <xsl:param name="root_category" select="'work'"/>
  <xsl:param name="file" select="'a_very_unique_id'"/>
  <xsl:param name="id"   select="''"/>
  <xsl:param name="prev" select="''"/>
  <xsl:param name="next" select="''"/>
  <xsl:param name="work_id" select="''"/>
  <xsl:param name="author" select="''"/>
  <xsl:param name="author_id" select="''"/>
  <xsl:param name="copyright" select="''"/>
  <xsl:param name="editor" select="''"/>
  <xsl:param name="editor_id" select="''"/>
  <xsl:param name="volume_title" select="''"/>
  <xsl:param name="volume_id" select="''"/>
  <xsl:param name="publisher" select="''"/>
  <xsl:param name="published_place" select="''"/>
  <xsl:param name="published_date" select="''"/>
  <xsl:param name="uri_base" select="'http://udvikling.kb.dk/'"/>
  <xsl:param name="url" select="concat($uri_base,$file)"/>
  <xsl:param name="submixion" select="''"/>


  <xsl:param name="status" select="''"/>
  <!-- Status: created|waiting|working|completed -->

  <xsl:param name="app" select="''"/>
  <!-- the name of the application, used by bifrost solr -->


  <xsl:template match="/">
    <xsl:element name="add">

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

  <!-- xsl:template match="t:text[@decls]|t:div[@decls]" -->
  <xsl:template match="t:div">
    <xsl:variable name="bibl" select="substring-after(@decls,'#')"/>
    <xsl:variable name="worktitle">
      <xsl:choose>
	<xsl:when 
	    test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:listBibl/t:bibl[@xml:id=$bibl]">
	  <xsl:value-of
              select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:listBibl/t:bibl[@xml:id=$bibl]"/>
	</xsl:when>
	<xsl:when test="t:head">
	  <!-- xsl:value-of select="t:head"/ -->
	  <xsl:apply-templates mode="gettext" 
			       select="t:head/text()|descendant::node()/text()"/>
	</xsl:when>
	<xsl:otherwise>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <doc>

      <xsl:element name="field">
	<xsl:attribute name="name">type_ssi</xsl:attribute>
	<xsl:text>trunk</xsl:text>
      </xsl:element>

      <xsl:element name="field">
        <xsl:attribute name="name">work_title_tesim</xsl:attribute>
        <xsl:value-of select="$worktitle"/>
      </xsl:element>

      <xsl:call-template name="add_globals">
	<xsl:with-param name="category">
	  <xsl:choose>
	    <xsl:when test="@decls">letter</xsl:when>
	    <xsl:otherwise>text</xsl:otherwise>
	  </xsl:choose>
	</xsl:with-param>
      </xsl:call-template>

      <xsl:element name="field">
        <xsl:attribute name="name">text_tesim</xsl:attribute>
        <xsl:apply-templates mode="gettext" 
			     select="./text()|descendant::node()/text()"/>
      </xsl:element>

      <xsl:variable name="lprev">
	<xsl:choose>
	  <xsl:when test="$prev">
	    <xsl:value-of select="$prev"/>
	  </xsl:when>
	  <xsl:otherwise>
            <xsl:call-template name="get_prev_id"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>

      <xsl:variable name="lnext">
	<xsl:choose>
	  <xsl:when test="$next">
	    <xsl:value-of select="$next"/>
	  </xsl:when>
	  <xsl:otherwise>
            <xsl:call-template name="get_next_id"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>

      <xsl:if test="string-length($lprev) &gt; 0">
	<xsl:element name="field">
	  <xsl:attribute name="name">previous_id_ssi</xsl:attribute>
	  <xsl:value-of 
	      select="concat(substring-before($file,'.xml'),'-',$lprev)"/>
	</xsl:element>
      </xsl:if>

      <xsl:if test="string-length($lnext) &gt; 0">
	<xsl:element name="field">
	  <xsl:attribute name="name">next_id_ssi</xsl:attribute>
	  <xsl:value-of 
	      select="concat(substring-before($file,'.xml'),'-',$lnext)"/>
	</xsl:element>
      </xsl:if>

    </doc>

    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:apply-templates>

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
        <xsl:attribute name="name">speaker_name_ssi</xsl:attribute>
        <xsl:value-of select="t:speaker"/>
      </xsl:element>

      <xsl:element name="field">
        <xsl:attribute name="name">text_tesim</xsl:attribute>
        <xsl:apply-templates mode="gettext" 
			     select="./text()|descendant::node()/text()"/>
      </xsl:element>

    </doc>
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

  <xsl:template match="t:div/t:p">

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
    <doc>
	<xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute>trunk</xsl:element>
      <xsl:element name="field">
        <xsl:attribute name="name">cat_ssi</xsl:attribute>
        <xsl:value-of select="$root_category"/>
      </xsl:element>
      <xsl:element name="field">
        <xsl:attribute name="name">work_title_tesim</xsl:attribute>
        <xsl:value-of select="$volume_title"/>
      </xsl:element>
    	<xsl:call-template name="add_globals" />
    </doc>
  </xsl:template>

  <xsl:template name="add_globals">

    <xsl:param name="category">text</xsl:param>

    <xsl:element name="field">
      <xsl:attribute name="name">id</xsl:attribute>
      <xsl:choose>
        <xsl:when test="@xml:id">
          <xsl:value-of select="concat(substring-before($file,'.xml'),'-',@xml:id)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-before($file,'.xml')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:if test="@n">
    <xsl:element name="field">
      <xsl:attribute name="name">letter_number_isi</xsl:attribute>
      <xsl:value-of select="1 + count(preceding::node()[@decls])"/>
    </xsl:element>
    </xsl:if>

    <xsl:if test="$work_id">
      <xsl:element name="field">
	<xsl:attribute name="name">work_id_ssi</xsl:attribute>
	<xsl:value-of select="$work_id"/>
      </xsl:element>
    </xsl:if>

    <xsl:if test="$status">
      <xsl:element name="field">
	<xsl:attribute name="name">status_ssi</xsl:attribute>
	<xsl:value-of select="$status"/>
      </xsl:element>
    </xsl:if>

    <xsl:element name="field">
      <xsl:attribute name="name">cat_ssi</xsl:attribute>
      <xsl:value-of select="$category"/>
    </xsl:element>

    <xsl:if test="$app">
      <xsl:element name="field">
        <xsl:attribute name="name">application_ssim</xsl:attribute>
        <xsl:value-of select="$app"/>
      </xsl:element>
    </xsl:if>

    <xsl:element name="field">
      <xsl:attribute
	  name="name">active_fedora_model_ssi</xsl:attribute>Letter</xsl:element>

      <xsl:element name="field">
	<xsl:attribute
	  name="name">has_model_ssim</xsl:attribute>Letter</xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">volume_id_ssi</xsl:attribute>
      <xsl:value-of select="$volume_id"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">url_ssi</xsl:attribute>
      <xsl:value-of select="concat($url,'#',@xml:id)"/>
    </xsl:element>

    <xsl:call-template name="page_info"/>

    <xsl:element name="field">
      <xsl:attribute name="name">volume_title_tesim</xsl:attribute>
      <xsl:value-of select="$volume_title"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">volume_title_ssim</xsl:attribute>
      <xsl:value-of select="$volume_title"/>
    </xsl:element>

    <xsl:if test="t:head|../t:head">
      <xsl:element name="field">
        <xsl:attribute name="name">head_tesim</xsl:attribute>
        <xsl:value-of select="t:head|../t:head[1]"/>
      </xsl:element>
    </xsl:if>

    <xsl:element name="field">
      <xsl:attribute name="name">author_name_ssim</xsl:attribute>
      <xsl:value-of select="$author"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">author_name_tesim</xsl:attribute>
      <xsl:value-of select="$author"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">author_id_ssim</xsl:attribute>
      <xsl:value-of select="$author_id"/>
    </xsl:element>

    <xsl:if test="@decls">
      <xsl:call-template name="letter_info"/>
    </xsl:if>

    <xsl:element name="field">
      <xsl:attribute name="name">copyright_ssi</xsl:attribute>
      <xsl:value-of select="$copyright"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">editor_ssi</xsl:attribute>
      <xsl:value-of select="$editor"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">editor_tesim</xsl:attribute>
      <xsl:value-of select="$editor"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">editor_id_ssim</xsl:attribute>
      <xsl:value-of select="$editor_id"/>
    </xsl:element>

    <xsl:if test="$publisher">
      <xsl:element name="field">
        <xsl:attribute name="name">publisher_ssi</xsl:attribute>
        <xsl:value-of select="$publisher"/>
      </xsl:element>
    </xsl:if>

    <xsl:if test="$publisher">
      <xsl:element name="field">
        <xsl:attribute name="name">publisher_tesim</xsl:attribute>
        <xsl:value-of select="$publisher"/>
      </xsl:element>
    </xsl:if>

    <xsl:if test="$published_date">
      <xsl:element name="field">
        <xsl:attribute name="name">published_date_ssi</xsl:attribute>
        <xsl:value-of select="$published_date"/>
      </xsl:element>
    </xsl:if>

    <xsl:if test="$published_place">
      <xsl:element name="field">
        <xsl:attribute name="name">published_place_ssi</xsl:attribute>
        <xsl:value-of select="$published_place"/>
      </xsl:element>
    </xsl:if>

    <xsl:element name="field">
      <xsl:attribute name="name">position_isi</xsl:attribute>
      <xsl:value-of  select="count(preceding::node())"/>
    </xsl:element>

    <xsl:apply-templates mode="backtrack" select="ancestor::node()[@decls][1]"/>

  </xsl:template>

  <xsl:template match="*">
    <xsl:param name="worktitle" select="''"/>
    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:apply-templates>
  </xsl:template>


 <xsl:template name="letter_info">
   
   <!-- we have been inconsistent as regards use of '#' in refs -->
    <xsl:variable name="bibl">
      <xsl:choose>
	<xsl:when test="contains(@decls,'#')" >
	  <xsl:value-of select="substring-after(@decls,'#')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="@decls"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- we should only look for letter info stuff if we're in a LLO (letter
	 like object) -->
  
      <xsl:call-template name="extract_places">  
	<xsl:with-param name="bibl" select="$bibl"/>
      </xsl:call-template>
      <xsl:call-template name="extract_agents">  
	<xsl:with-param name="bibl" select="$bibl"/>
      </xsl:call-template>
      <xsl:call-template name="extract_dates">
	<xsl:with-param name="bibl" select="$bibl"/>
      </xsl:call-template>

  </xsl:template>

 <!-- xsl:for-each select="/t:TEI">
	<xsl:for-each select="descendant::t:bibl[@xml:id=$bibl_id]" -->


  <xsl:template name="extract_places">
    <xsl:param name="bibl" select="''"/>

    <xsl:for-each select="/t:TEI">
      <xsl:for-each select="descendant::node()[@xml:id=$bibl]">
	<xsl:for-each select="t:location">
	  <xsl:variable name="role">
	    <xsl:value-of select="@type"/>
	  </xsl:variable>
	  <xsl:for-each select="t:placeName">
	    <xsl:element name="field">
	      <xsl:attribute name="name">
		<xsl:value-of select="concat($role,'_location_ssim')"/>
	      </xsl:attribute>
	      <xsl:value-of select="."/>
	    </xsl:element>

	    <xsl:element name="field">
	      <xsl:attribute name="name">
		<xsl:value-of select="concat($role,'_location_tesim')"/>
	      </xsl:attribute>
	      <xsl:value-of select="."/>
	    </xsl:element>

	  </xsl:for-each>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>

    <xsl:for-each select="descendant::t:geogName">
      <xsl:variable name="role">
	<xsl:choose>
	  <xsl:when test="@type">
	    <xsl:value-of select="@type"/>
	  </xsl:when>
	  <xsl:otherwise>sender</xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:element name="field">
	<xsl:attribute name="name">
	  <xsl:value-of select="concat($role,'_location_text_ssim')"/>
	</xsl:attribute>
	<xsl:value-of select="."/>
      </xsl:element>
      <xsl:element name="field">
	<xsl:attribute name="name">
	  <xsl:value-of select="concat($role,'_location_text_tesim')"/>
	</xsl:attribute>
	<xsl:value-of select="."/>
      </xsl:element>
    </xsl:for-each>

  </xsl:template>

  <xsl:template name="extract_dates">
    <xsl:param name="bibl" select="''"/>


    <xsl:for-each select="/t:TEI">
      <xsl:for-each select="descendant::node()[@xml:id=$bibl]">
	<xsl:for-each select="t:date">
	  <xsl:element name="field">
	    <xsl:attribute name="name">date_ssim</xsl:attribute>
	    <xsl:value-of select="."/>
	  </xsl:element>
	  <xsl:variable name="ditsi">
	    <xsl:value-of select="number(substring(.,1,4))"/>
	  </xsl:variable>

	  <xsl:if test="not(contains($ditsi,'NaN'))">
	    <xsl:element name="field">
	      <xsl:attribute name="name">year_itsi</xsl:attribute>
	      <xsl:value-of select="$ditsi"/>
	    </xsl:element>
	  </xsl:if>

	</xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>

    <xsl:for-each select="descendant::t:date">
      <xsl:element name="field">
	<xsl:attribute name="name">date_text_ssim</xsl:attribute>
	<xsl:value-of select="."/>
      </xsl:element>
    </xsl:for-each>

  </xsl:template>

  <!--
      This is where we extract senders, recipients, authors and other agents. The code is a bit obfuscated
  -->
  <xsl:template name="extract_agent_sort_keys">
    <xsl:param name="field" select="''"/>

    <xsl:variable name="value">
      <xsl:for-each select="t:respStmt[t:resp=$field and t:name/node()]">
	<xsl:for-each select="t:name"><xsl:value-of select="t:surname"/><xsl:value-of select="t:forename"/></xsl:for-each>
      </xsl:for-each>
    </xsl:variable>

    <xsl:if test="$value">
      <xsl:element name="field">
	<xsl:attribute name="name">
	  <xsl:value-of select="concat('sortby_',$field,'_ssi')"/>
	</xsl:attribute>
	<xsl:value-of select="$value"/>
      </xsl:element>
    </xsl:if>

  </xsl:template>


  <xsl:template name="extract_agents">
    <xsl:param name="bibl" select="''"/>

    <xsl:for-each select="/t:TEI">
      <xsl:for-each select="descendant::node()[@xml:id=$bibl]">

	<xsl:call-template name="extract_agent_sort_keys">
	  <xsl:with-param name="field">recipient</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="extract_agent_sort_keys">
	  <xsl:with-param name="field">sender</xsl:with-param>
	</xsl:call-template>


	<xsl:for-each select="t:respStmt[t:resp/node() and t:name/node()]">
	  <xsl:variable name="field">
	    <xsl:value-of select="t:resp"/>
	  </xsl:variable>
	  <xsl:for-each select="t:name">
	  <xsl:element name="field">
	    <xsl:attribute name="name">
	      <xsl:value-of select="concat($field,'_ssim')"/>
	    </xsl:attribute>
	    <xsl:value-of select="t:surname"/><xsl:text>, </xsl:text><xsl:value-of select="t:forename"/>
	    </xsl:element>

	    <xsl:element name="field">
	      <xsl:attribute name="name">
		<xsl:value-of select="concat($field,'_tesim')"/>
	      </xsl:attribute>
              <xsl:value-of select="t:forename"/><xsl:text> </xsl:text><xsl:value-of select="t:surname"/>
	    </xsl:element>

	    <xsl:element name="field">
	      <xsl:attribute name="name">
		<xsl:value-of select="concat($field,'_id_ssim')"/>
	      </xsl:attribute>
	      <xsl:value-of select="@ref"/>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:for-each select="descendant::t:persName">
      <xsl:variable name="field1">
	<xsl:value-of select="concat(@type,'_text_ssim')"/>
      </xsl:variable>

      <xsl:variable name="field2">
	<xsl:value-of select="concat(@type,'_text_tesim')"/>
      </xsl:variable>

      <xsl:element name="field">
	<xsl:attribute name="name">
	  <xsl:value-of select="$field1"/>
	</xsl:attribute>
	<xsl:value-of select="."/>
      </xsl:element>

      <xsl:element name="field">
	<xsl:attribute name="name">
	  <xsl:value-of select="$field2"/>
	</xsl:attribute>
	<xsl:value-of select="."/>
      </xsl:element>


    </xsl:for-each>
  </xsl:template>

  <xsl:template name="get_prev_id">
    <xsl:value-of
	select="preceding::node()[@decls and @xml:id][1]/@xml:id"/>
  </xsl:template>

  <xsl:template name="get_next_id">
    <xsl:value-of
	select="following::node()[@decls and @xml:id][1]/@xml:id"/>
  </xsl:template>


  <xsl:template name="page_info">
    <xsl:if test="preceding::t:pb[1]/@n|descendant::t:pb">
      <xsl:element name="field">
        <xsl:attribute name="name">page_ssi</xsl:attribute>
        <xsl:value-of
                select="preceding::t:pb[1]/@n|descendant::t:pb/@n[1]"/>
      </xsl:element>
      <xsl:element name="field">
        <xsl:attribute name="name">page_id_ssi</xsl:attribute>
        <xsl:value-of
                select="preceding::t:pb[1]/@xml:id|descendant::t:pb/@xml:id[1]"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="backtrack" match="node()">
    <xsl:element name="field">
      <xsl:attribute name="name">part_of_ssim</xsl:attribute>
      <xsl:value-of select="concat(substring-before($file,'.xml'),'-',@xml:id)"/>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="ancestor::node()[@decls]">
	<xsl:apply-templates mode="backtrack"
			     select="ancestor::node()[@decls][1]"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="field">
	  <xsl:attribute name="name">part_of_ssim</xsl:attribute>
	  <xsl:value-of select="$file"/>
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>
