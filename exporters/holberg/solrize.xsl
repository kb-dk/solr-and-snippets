<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">
  
  <xsl:import href="../solrize-global.xsl"/>
  <xsl:param name="subcollection" select="'holberg'"/>
  <xsl:param name="category" select="'work'"/>

  <xsl:param name="i_am_a">
    <xsl:call-template name="me_looks_like"/>
  </xsl:param>


  <xsl:param name="editor" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:respStmt">
      <xsl:for-each select="t:resp">
	<xsl:apply-templates mode="gettext"  select="."/><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="worktitle">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title[not(@level) and not(@type)]">
      <xsl:apply-templates mode="gettext"  select="."/>
    </xsl:for-each>
  </xsl:param>

  <xsl:template match="t:text">
    <xsl:variable name="dir_path" select="substring-before($doc,'/')"/>
    <xsl:variable name="file_basename" select="substring-before(substring-after($doc,'/'),'.xml')"/>

    <xsl:comment><xsl:value-of select="$worktitle"/></xsl:comment>
    <xsl:comment><xsl:value-of select="$volume_title"/></xsl:comment>
    <xsl:call-template name="trunk_doc">
      <xsl:with-param name="worktitle" select="$worktitle"/>
      <xsl:with-param name="category">
	<xsl:if test="$i_am_a = 'Tekst'">work</xsl:if>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:apply-templates>

  </xsl:template>

   <xsl:template name="inferred_path">
     <xsl:param name="document" select="$doc"/>
     <xsl:variable name="frag">
       <xsl:choose>
	 <xsl:when test="contains($document,'#')">
	   <xsl:value-of select="substring-after($document,'#')"/>
	 </xsl:when>
	 <xsl:otherwise>root</xsl:otherwise>
       </xsl:choose>
     </xsl:variable>
     <xsl:variable name="f">
       <xsl:choose>
	 <xsl:when test="$frag = 'root'">-</xsl:when>
	 <xsl:otherwise>-root#</xsl:otherwise>
       </xsl:choose>
     </xsl:variable>
     <xsl:text>/text/</xsl:text><xsl:value-of
     select="translate(concat($c,'-',substring-before($doc,'/'),'/',substring-before($document,'.xml'),$f,$frag),'/','-')"/>
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


  <xsl:template name="extract_titles_authors_etc">

    <xsl:choose>
      <xsl:when test="contains($i_am_a,'Tekst')">
	<xsl:element name="field"><xsl:attribute name="name">author_name_ssi</xsl:attribute>Holberg, Ludvig</xsl:element>
	<xsl:element name="field"><xsl:attribute name="name">author_name_ssim</xsl:attribute>Holberg, Ludvig</xsl:element>
	<xsl:element name="field"><xsl:attribute name="name">author_nasim</xsl:attribute>Ludvig Holberg</xsl:element>
	<xsl:element name="field"><xsl:attribute name="name">author_name_tesim</xsl:attribute>Ludvig Holberg</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:author">
	  <xsl:for-each select="t:name">
	    <xsl:element name="field"><xsl:attribute name="name">author_name_tesim</xsl:attribute>
	    <xsl:value-of  select="."/>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:element name="field"><xsl:attribute name="name">publisher_tesim</xsl:attribute><xsl:value-of select="$publisher"/></xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">publisher_nasim</xsl:attribute><xsl:value-of select="$publisher"/></xsl:element>

  </xsl:template>



</xsl:transform>