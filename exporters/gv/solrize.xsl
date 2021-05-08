<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:me="urn:my-things"
	       exclude-result-prefixes="t fn me">
  
  <xsl:import href="../solrize-global.xsl"/>

  <xsl:param name="is_monograph">yes</xsl:param>

  <xsl:param name="subcollection" select="'gv'"/>

  <xsl:param name="i_am_a">
    <xsl:call-template name="me_looks_like"/>
  </xsl:param>

  <!-- sourceDesc in GV seems to contain Garbage -->
  <xsl:param name="volume_title">Grundtvigs værker</xsl:param>

  <xsl:param name="worktitle">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt">
      <xsl:apply-templates mode="gettext" select="t:title[contains(@rend,'part') or contains(@rend,'main')]"/>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="editor" >
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:respStmt">
      <xsl:for-each select="t:resp">
	<xsl:apply-templates mode="gettext"  select="."/><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="publisher">
    <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt">
      <xsl:for-each select="t:publisher">
        <xsl:value-of select="."/><xsl:if test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:param>

  <xsl:param name="volume_sort_title">
    <xsl:value-of select="$volume_title"/>
  </xsl:param>

  <xsl:param name="per_reg" />
  
  <xsl:param name="person_registry" select="document($per_reg)"/>
  <xsl:param name="pla_reg"  />
  <xsl:param name="place_registry" select="document($pla_reg)"/>

  <xsl:template name="is_editorial">
    <xsl:variable name="category"><xsl:call-template name="get_category"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($category,'work')">no</xsl:when>
      <xsl:otherwise>yes</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_category">
    <xsl:choose>
      <xsl:when test="contains($path,'-txt-')">work</xsl:when>
      <xsl:when test="contains($path,'-v0-')">editorial</xsl:when>
      <xsl:when test="contains($path,'-txr-')">editorial</xsl:when>
      <xsl:when test="contains($path,'-com-')">editorial</xsl:when>
      <xsl:when test="contains($path,'-intro-')">editorial</xsl:when>
    </xsl:choose>
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

  <xsl:template name="me_looks_like">
  </xsl:template>

  <xsl:function name="me:normalized-person">
    <xsl:param name="key"/>
    <xsl:variable name="person">
      <xsl:for-each select="$person_registry//t:row[@xml:id = $key]">
        <xsl:choose>
          <xsl:when test="t:cell[@rend='altName']|t:cell[@rend='name']">
            <xsl:for-each select="(t:cell[@rend='altName' and not(t:addName)]|t:cell[@rend='name' and not(t:addName)  ])[1]">
              <xsl:if test="t:note[@type='lastName']">
                <xsl:value-of select="t:note[@type='lastName']"/><xsl:if test="t:note[@type='firstName']"><xsl:text>&#x2c; </xsl:text></xsl:if>
              </xsl:if>
              <xsl:value-of select="t:note[@type='firstName']"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$key"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="normalize-space(string($person))"/>
  </xsl:function>

  <xsl:function name="me:normalized-location">
    <xsl:param name="key"/>
    <xsl:for-each select="$place_registry//t:row[@xml:id = $key]">

      <xsl:choose>
        <xsl:when test="t:cell[@rend='name' ][1]">
          <xsl:value-of select="t:cell[@rend='name' ]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$key"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <xsl:template match="t:note/t:addName">
    <xsl:text> </xsl:text><xsl:apply-templates/>
  </xsl:template>

  
 

  <xsl:template name="extract_entities">

    <!-- t:rs[@type='myth']|t:rs[@type='title']|t:rs[@type='bible']" -->

    <xsl:comment>
      per_reg <xsl:value-of select="$per_reg"/>
      pla_reg <xsl:value-of select="$pla_reg"/><xsl:text>
    </xsl:text></xsl:comment>

    
    <xsl:for-each select="fn:distinct-values(descendant-or-self::t:persName/@key)">

      <xsl:variable name="this_value" select="me:normalized-person(.)"/>
      
      <xsl:call-template name="mkentity">
        <xsl:with-param name="entity_field">person_name_ssim</xsl:with-param>
        <xsl:with-param name="node" select="$this_value"/>
      </xsl:call-template>
       <xsl:call-template name="mkentity">
         <xsl:with-param name="entity_field">person_name_tesim</xsl:with-param>
         <xsl:with-param name="node" select="$this_value"/>
       </xsl:call-template>
       <xsl:call-template name="mkentity">
         <xsl:with-param name="entity_field">text_tsim</xsl:with-param>
         <xsl:with-param name="node" select="$this_value"/>
       </xsl:call-template>
    </xsl:for-each>
    
    <xsl:for-each select="fn:distinct-values(descendant-or-self::t:placeName/@key)">
      
      <xsl:variable name="this_value" select="me:normalized-location(.)"/>
      
      <xsl:call-template name="mkentity">
        <xsl:with-param name="entity_field">other_location_ssim</xsl:with-param>
        <xsl:with-param name="node" select="$this_value"/>
      </xsl:call-template>
      <xsl:call-template name="mkentity">
        <xsl:with-param name="entity_field">other_location_tesim</xsl:with-param>
        <xsl:with-param name="node" select="$this_value"/>
      </xsl:call-template>
      <xsl:call-template name="mkentity">
        <xsl:with-param name="entity_field">text_tsim</xsl:with-param>
        <xsl:with-param name="node" select="$this_value"/>
      </xsl:call-template>
    </xsl:for-each>

     <xsl:for-each select="fn:distinct-values(descendant-or-self::t:rs[@type='bible']/@key)">
       <xsl:call-template name="mkentity">
         <xsl:with-param name="entity_field">bible_ref_ssim</xsl:with-param>
       </xsl:call-template>
       <xsl:call-template name="mkentity">
         <xsl:with-param name="entity_field">bible_ref_tesim</xsl:with-param>
       </xsl:call-template>
       <xsl:call-template name="mkentity">
         <xsl:with-param name="entity_field">text_tsim</xsl:with-param>
       </xsl:call-template>
     </xsl:for-each>
    
  </xsl:template>
  
  <xsl:template match="t:text[@type='com' or @type='commentary']">
    <xsl:comment> the text element for comments </xsl:comment>
    <xsl:variable name="tit">
      <xsl:choose>
	<xsl:when test="string-length($worktitle)">
	  <xsl:value-of select="$worktitle"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="t:head[1]"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:call-template name="trunk_doc">
      <xsl:with-param name="worktitle" select="$tit"/>
    </xsl:call-template>

    <xsl:apply-templates select="t:body/t:note">
      <xsl:with-param name="worktitle" select="$tit"/>
    </xsl:apply-templates>

  </xsl:template>


  <xsl:template match="t:row|t:note[t:p]">
    <xsl:param name="worktitle" select="''"/>

    <xsl:comment> the right com doc note </xsl:comment>
    
    <xsl:call-template name="make_comment"/>
    
  </xsl:template>


  
  <xsl:template name="extract_titles_authors_etc">
    <xsl:param name="worktitle" select="''"/>
    <xsl:element name="field"><xsl:attribute name="name">author_name_ssi</xsl:attribute>Grundtvig, N. F. S.</xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">author_name_ssim</xsl:attribute>Grundtvig, N. F. S.</xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">author_nasim</xsl:attribute>N. F. S. Grundtvig</xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">author_name_tesim</xsl:attribute>N. F. S. Grundtvig</xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">publisher_tesim</xsl:attribute><xsl:value-of select="$publisher"/></xsl:element>
    <xsl:element name="field"><xsl:attribute name="name">publisher_nasim</xsl:attribute><xsl:value-of select="$publisher"/></xsl:element>
    
  </xsl:template>

</xsl:transform>
