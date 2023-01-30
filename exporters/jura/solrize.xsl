<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:me="urn:my-things"
	       exclude-result-prefixes="t fn me">
  
  <xsl:import href="../solrize-global.xsl"/>


  <xsl:param name="subcollection" select="'jura'"/>

  <xsl:param name="editor" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:respStmt">
      <xsl:for-each select="t:resp">
	<xsl:apply-templates mode="gettext"  select="."/><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:param>

   <xsl:param name="worktitle">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title">
      <xsl:apply-templates mode="gettext"  select="."/>
    </xsl:for-each>
  </xsl:param>

 <xsl:param name="volume_title">
   <xsl:choose>
     <xsl:when test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title[text()]">
       <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title">
	 <xsl:apply-templates mode="gettext"  select="."/>
       </xsl:for-each>
     </xsl:when>
     <xsl:otherwise>
       <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title">
	 <xsl:apply-templates mode="gettext"  select="."/>
       </xsl:for-each>
     </xsl:otherwise>
   </xsl:choose>
  </xsl:param>

  <xsl:param name="volume_sort_title">
    <xsl:choose>
      <xsl:when test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title[text()]">
	<xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:title">
	  <xsl:call-template name="volume_sort_title"/>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title">
	  <xsl:call-template name="volume_sort_title"/>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:template match="t:text[@decls]|t:div[@decls]">
    <xsl:variable name="bibl" select="substring-after(@decls,'#')"/>
    <xsl:variable name="worktitle">
      <xsl:choose>
	<xsl:when 
	    test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:listBibl/t:bibl[@xml:id=$bibl]/t:title">
	  <xsl:value-of
              select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:listBibl/t:bibl[@xml:id=$bibl]/t:title"/>
	</xsl:when>
	<xsl:when test="t:head">
	  <xsl:value-of select="t:head"/>
	</xsl:when>
	<xsl:otherwise>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="trunk_doc">
      <xsl:with-param name="worktitle" select="''"/>
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="t:text[not(@decls|descendant-or-self::node()[@decls]/@decls)]">
    <xsl:variable name="dir_path" select="substring-before($doc,'/')"/>
    <xsl:variable name="file_basename" select="substring-before(substring-after($doc,'/'),'.xml')"/>
    <xsl:comment><xsl:value-of select="$worktitle"/></xsl:comment>
    <xsl:comment><xsl:value-of select="$volume_title"/></xsl:comment>
    <xsl:call-template name="trunk_doc">
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:call-template>
    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="backtrack" match="node()[@xml:id]">
    <xsl:element name="field">
      <xsl:attribute name="name">part_of_ssim</xsl:attribute>
      <xsl:choose>
	<xsl:when test="not(contains(@xml:id,'root'))">
	  <xsl:value-of select="concat(substring-before($path,'-root'),'-shoot-',@xml:id)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$path"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:apply-templates mode="backtrack" select="ancestor::node()[@xml:id][1]"/>
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
	<xsl:when test="descendant-or-self::t:head/text()|
                        descendant-or-self::t:p/text()|
                        descendant-or-self::t:l/text()">yes</xsl:when>
	<xsl:otherwise>no</xsl:otherwise>
      </xsl:choose>
    </field>
    
  </xsl:template>


  <xsl:template name="local_globals">
    <xsl:for-each select="descendant-or-self::t:milestone[@next]">
      <xsl:element name="field">
        <xsl:attribute name="name">text_tsim</xsl:attribute>
        <xsl:value-of select="concat('spalte',@n)"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="extract_titles_authors_etc">
    <xsl:param name="worktitle" select="''"/>
    
    <xsl:variable name="biblid" select="substring-after(@decls|ancestor::node()[@decls]/@decls,'#')"/>
    <xsl:comment> xml:id <xsl:value-of select="@xml:id"/> </xsl:comment>
    <xsl:comment> <xsl:value-of select="$path"/> jura biblid  <xsl:value-of select="$biblid"/> </xsl:comment>

    <xsl:for-each select="t:speaker|descendant-or-self::t:speaker">
      <xsl:element name="field">
        <xsl:attribute name="name">person_name_tesim</xsl:attribute>
        <xsl:value-of select="normalize-space(fn:replace(.,'[:,\.]+\s*',' '))"/>
      </xsl:element>

      <xsl:element name="field">
        <xsl:attribute name="name">person_name_ssim</xsl:attribute>
        <xsl:value-of select="normalize-space(fn:replace(.,'[:,\.]+\s*',' '))"/>
      </xsl:element>

      <xsl:element name="field">
        <xsl:attribute name="name">text_tsim</xsl:attribute>
        <xsl:value-of select="normalize-space(fn:replace(.,'[:,\.]+\s*',' '))"/>
      </xsl:element>

      
    </xsl:for-each>

    <xsl:if test="@decls|ancestor::node()[@decls]/@decls">
      <xsl:variable name="bibl" select="//t:bibl[@xml:id=$biblid]"/>
      
      <xsl:if test="$bibl/t:title">
	<xsl:element name="field">
	  <xsl:attribute name="name">work_title_tesim</xsl:attribute>
	  <xsl:value-of select="$bibl/t:title"/>
	</xsl:element>

	<xsl:element name="field">
	  <xsl:attribute name="name">work_title_ssi</xsl:attribute>
	  <xsl:value-of select="$bibl/t:title"/>
	</xsl:element>

      </xsl:if>

      <xsl:if test="$bibl/t:publisher">

	<xsl:element name="field">
	  <xsl:attribute name="name">publisher_tesim</xsl:attribute>
	  <xsl:value-of select="$bibl/t:publisher"/>
	</xsl:element>

	<xsl:element name="field">
	  <xsl:attribute name="name">publisher_nasim</xsl:attribute>
	  <xsl:value-of select="$bibl/t:publisher"/>
	</xsl:element>

      </xsl:if>

      <xsl:if test="$bibl/t:extent">

	<xsl:element name="field">
	  <xsl:attribute name="name">format_tesim</xsl:attribute>
	  <xsl:value-of select="$bibl/t:extent"/>
	</xsl:element>

      </xsl:if>

      <xsl:if test="$bibl/t:author">
	<xsl:element name="field">
	  <xsl:attribute name="name">author_name_tesim</xsl:attribute>
	  <xsl:value-of select="$bibl/t:author"/>
	</xsl:element>

	<xsl:element name="field">
	  <xsl:attribute name="name">author_nasim</xsl:attribute>
	  <xsl:value-of select="$bibl/t:author"/>
	</xsl:element>

	<xsl:element name="field">
	  <xsl:attribute name="name">author_name_ssim</xsl:attribute>
	  <xsl:value-of select="$bibl/t:author"/>
	</xsl:element>

      </xsl:if>

    </xsl:if>

    <xsl:if test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:date">
      <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:bibl/t:date">
	<xsl:element name="field">
	  <xsl:attribute name="name">
            <xsl:attribute name="name">year_itsi</xsl:attribute>
          </xsl:attribute>
	  <xsl:value-of select="."/>
        </xsl:element>
      </xsl:for-each>
    </xsl:if>

   
  </xsl:template>

  <xsl:template name="what_i_can"/>

</xsl:transform>
