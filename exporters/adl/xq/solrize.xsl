<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:t="http://www.tei-c.org/ns/1.0"
               exclude-result-prefixes="t"
               version="1.0">

  <!-- not a poisonous adder -->

  <xsl:output indent="yes"
              encoding="UTF-8"
              method="xml"/>

  <xsl:param name="relations"  select="document('creator-relations.xml')"/>

  <xsl:param name="app" select="'ADL'"/>
  <xsl:param name="category" select="'work'"/>
  <xsl:param name="doc" select="'a_very_unique_id'"/>
  <xsl:param name="basename" select="substring-before($doc,'.xml')"/>
  <xsl:param name="author" select="''"/>
  <xsl:param name="author_id" select="''"/>
  <xsl:param name="copyright" select="''"/>
  <xsl:param name="editor" select="''"/>
  <xsl:param name="editor_id" select="''"/>
  <xsl:param name="volume_title">
    <xsl:value-of 
	select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title"/>
  </xsl:param>
  <xsl:param name="publisher" select="''"/>
  <xsl:param name="published_place" select="''"/>
  <xsl:param name="published_date" select="''"/>
  <xsl:param name="c" select="'unknown_collection'"/>
  <xsl:param name="coll" select="'unknown_collection'"/>
  <xsl:param name="uri_base" select="concat($c,'/')"/>
  <xsl:param name="url" select="concat($uri_base,$doc)"/>
  <xsl:param name="license">Attribution-NonCommercial-ShareAlike CC BY-NC-SA</xsl:param>


  <xsl:template match="/">
    <xsl:element name="add">
      <xsl:call-template name="generate_volume_doc" />
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:text[@decls]|t:div[@decls]">
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

    <doc>

      <xsl:element name="field">
	<xsl:attribute name="name">type_ssi</xsl:attribute>
	<xsl:text>trunk</xsl:text>
      </xsl:element>

      <xsl:element name="field">
        <xsl:attribute name="name">cat_ssi</xsl:attribute>
        <xsl:value-of select="$category"/>
      </xsl:element>

      <xsl:element name="field">
        <xsl:attribute name="name">work_title_tesim</xsl:attribute>
        <xsl:value-of select="$worktitle"/>
      </xsl:element>

      <xsl:call-template name="add_globals"/>

      <xsl:element name="field">
        <xsl:attribute name="name">text_tesim</xsl:attribute>
        <xsl:apply-templates mode="gettext" 
			     select="./text()|descendant::node()/text()"/>
      </xsl:element>
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
        <xsl:attribute name="name">speaker_name</xsl:attribute>
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
        <xsl:attribute name="name">cat_ssi</xsl:attribute>volume
      </xsl:element>
      <xsl:element name="field">
        <xsl:attribute name="name">work_title_tesim</xsl:attribute>
        <xsl:value-of select="$volume_title"/>
      </xsl:element>
    	<xsl:call-template name="add_globals" />
    </doc>
  </xsl:template>

  <xsl:template name="add_globals">

    <xsl:element name="field">
      <xsl:attribute name="name">id</xsl:attribute>
      <xsl:choose>
        <xsl:when test="@xml:id">
          <xsl:value-of select="concat($basename,'-',@xml:id)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$basename"/>
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
      <xsl:value-of select="$basename"/>
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

    <xsl:element name="field">
      <xsl:attribute name="name">volume_title_tesim</xsl:attribute>
      <xsl:value-of select="$volume_title"/>
    </xsl:element>

    <xsl:if test="t:head|../t:head">
      <xsl:element name="field">
        <xsl:attribute name="name">head_tesim</xsl:attribute>
        <xsl:value-of select="t:head|../t:head[1]"/>
      </xsl:element>
    </xsl:if>


    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc">
      <xsl:for-each select="t:bibl">
	<xsl:for-each select="t:author">
	  <xsl:element name="field">
	    <xsl:attribute name="name">author_name_ssim</xsl:attribute>
	    <xsl:value-of select="."/>
	  </xsl:element>
	  <xsl:element name="field">
	    <xsl:attribute name="name">author_name_tesim</xsl:attribute>
	    <xsl:value-of select="."/>
	  </xsl:element>
	</xsl:for-each>

	<xsl:element name="field">
	  <xsl:attribute name="name">publisher_tesim</xsl:attribute>
	  <xsl:for-each select="t:publisher">
	    <xsl:value-of select="."/><xsl:text>
</xsl:text>
	  </xsl:for-each>
	</xsl:element>

	<xsl:element name="field">
	  <xsl:attribute name="name">published_place_tesim</xsl:attribute>
	  <xsl:for-each select="t:pubPlace">
	    <xsl:value-of select="."/><xsl:text>
</xsl:text>
	  </xsl:for-each>
	</xsl:element>

	<xsl:element name="field">
	  <xsl:attribute name="name">published_date_ssi</xsl:attribute>
	  <xsl:for-each select="t:date">
	    <xsl:value-of select="."/>
	  </xsl:for-each>
	</xsl:element>
      </xsl:for-each>
    </xsl:for-each>



    <xsl:variable name="auid">
      <xsl:value-of select="$relations//t:row[t:cell/t:ref = $url]/t:cell[@role='author']"/>
    </xsl:variable>


    <xsl:element name="field">
      <xsl:attribute name="name">author_id_ssi</xsl:attribute>
      <xsl:value-of select="substring-before($auid,'.xml')"/>
    </xsl:element>

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

    <xsl:apply-templates mode="backtrack" select="ancestor::node()[@decls][1]"/>

    <field name="application_ssim">
      <xsl:value-of select="$app"/>
    </field>

    <field name="subcollection_ssi">
      <xsl:value-of select="$c"/>
    </field>

  </xsl:template>

  <xsl:template match="*">
    <xsl:param name="worktitle" select="''"/>
    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:apply-templates>
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

  <xsl:template mode="backtrack" match="*[@decls]">
    <xsl:element name="field">
      <xsl:attribute name="name">part_of_ssim</xsl:attribute>
      <xsl:value-of select="concat($basename,'-',@xml:id)"/>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="ancestor::node()[@decls]">
	<xsl:apply-templates mode="backtrack"
			     select="ancestor::node()[@decls][1]"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="field">
	  <xsl:attribute name="name">part_of_ssim</xsl:attribute>
	  <xsl:value-of select="$basename"/>
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>
