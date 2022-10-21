<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:me="urn:my-things"
	       exclude-result-prefixes="t fn me">
  
  <xsl:import href="../solrize-global.xsl"/>


  <xsl:param name="subcollection" select="'lh'"/>

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

  </xsl:template>

  
  <xsl:template name="extract_titles_authors_etc">
    <xsl:param name="worktitle" select="''"/>
    
    <xsl:if test="@decls|ancestor::node()[@decls]/@decls">
      <xsl:variable name="biblid" select="substring-after(@decls|ancestor::node()[@decls]/@decls,'#')"/>
      <xsl:variable name="bibl" select="//t:bibl[@xml:id=$biblid]"/>
      
      <xsl:choose>
        <xsl:when test="$bibl/t:respStmt[contains(t:resp,'recipient')  and t:name//text()]">

                    
          <xsl:variable name="supplied_title">
            <xsl:text>BREV</xsl:text>
            
            <xsl:for-each select="$bibl/t:respStmt[contains(t:resp,'recipient') and t:name//text()]">
              <xsl:text> TIL: </xsl:text>
              <xsl:for-each select="t:name">
                <xsl:value-of select="."/><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
              </xsl:for-each>
            </xsl:for-each>

            <xsl:for-each select="$bibl/t:respStmt[contains(t:resp,'sender') and t:name//text()]">
              <xsl:text> FRA: </xsl:text> 
              <xsl:for-each select="t:name">
                <xsl:value-of select="."/><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
              </xsl:for-each>
            </xsl:for-each>

	    <xsl:for-each select="$bibl/t:date/@when[string()]">
	      <xsl:text> (</xsl:text><xsl:value-of select="."/><xsl:text>)</xsl:text>
	    </xsl:for-each>
          </xsl:variable>

          <xsl:element name="field">
	    <xsl:attribute name="name">work_title_tesim</xsl:attribute>
	    <xsl:value-of select="$supplied_title"/>  <xsl:if test="$bibl/t:title/text()"> -- <xsl:value-of select="$bibl/t:title"/></xsl:if>
	  </xsl:element>

	  <xsl:element name="field">
	    <xsl:attribute name="name">work_title_ssi</xsl:attribute>
	    <xsl:value-of select="$supplied_title"/> <xsl:if test="$bibl/t:title/text()"> -- <xsl:value-of select="$bibl/t:title"/></xsl:if>
	  </xsl:element>

          <xsl:element name="field"><xsl:attribute name="name">textclass_genre_ssim</xsl:attribute>breve og dedikationer</xsl:element>

	  <xsl:element name="field">
	    <xsl:attribute name="name">writing_ssi</xsl:attribute>
            <xsl:value-of  select="$bibl/t:term[@type='writing']"/>
          </xsl:element>
          
        </xsl:when>
        <xsl:otherwise>

          <xsl:element name="field">
	    <xsl:attribute name="name">work_title_tesim</xsl:attribute>
	    <xsl:value-of select="$bibl/t:title"/>
	  </xsl:element>

	  <xsl:element name="field">
	    <xsl:attribute name="name">work_title_ssi</xsl:attribute>
	    <xsl:value-of select="$bibl/t:title"/>
	  </xsl:element>

          <xsl:element name="field"><xsl:attribute name="name">textclass_genre_ssim</xsl:attribute>dokumenter</xsl:element>

	  <xsl:element name="field">
	    <xsl:attribute name="name">writing_ssi</xsl:attribute>
            <xsl:value-of  select="$bibl/t:term[@type='writing']"/>
          </xsl:element>
          
        </xsl:otherwise>
      </xsl:choose>


      <field name="has_facs_ssi">yes</field>

      <field name="has_text_ssi">
        <xsl:attribute name="name">has_text_ssi</xsl:attribute>
        <xsl:choose>
          <xsl:when test="$bibl/t:term[@type='writing'] = 'maskinskrevet'">yes</xsl:when>
          <xsl:otherwise>no</xsl:otherwise>
        </xsl:choose>
      </field>
      
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

      <xsl:if test="$bibl/t:date">
        <xsl:for-each select="$bibl/t:date[@type]">
	  <xsl:element name="field">
	    <xsl:attribute name="name">
              <xsl:call-template name="date_semantics">
                <xsl:with-param name="type" select="@type"/>
              </xsl:call-template>
            </xsl:attribute>
	    <xsl:value-of select="."/>
          </xsl:element>
	</xsl:for-each>
        
	<xsl:for-each select="$bibl/t:date[@when]">
          <xsl:element name="field">
	    <xsl:attribute name="name">year_itsi</xsl:attribute>
            <xsl:choose>
              <xsl:when test="@when">
                <xsl:value-of select="me:year-extractor(@when/string())"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="me:year-extractor(./string())"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
	</xsl:for-each>

      </xsl:if>
    </xsl:if>

  </xsl:template>

  <xsl:template name="what_i_can"/>

</xsl:transform>
