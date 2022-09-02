<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       xmlns:me="urn:my-things"
	       exclude-result-prefixes="t fn me"
               version="2.0">

  <xsl:output indent="yes"
              encoding="UTF-8"
              method="xml"/>

  <xsl:param name="app" select="'ADL'"/>

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

  <xsl:param name="num_authors">
    <xsl:choose>
      <xsl:when test="//t:sourceDesc/t:listBibl/t:bibl/t:author">
        <xsl:value-of
            select="count(distinct-values(//t:sourceDesc/t:listBibl/t:bibl/t:author/string()))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="//t:sourceDesc/t:listBibl/t:bibl/t:author">1</xsl:when>
          <xsl:when test="//t:fileDesc/t:titleStmt/t:author">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="license">Attribution-NonCommercial-ShareAlike CC BY-NC-SA</xsl:param>

  <xsl:template name="is_a_monograph">
    <xsl:choose>
      <xsl:when test="count(/t:TEI//node()[@decls])&lt;2">yes</xsl:when>
      <xsl:otherwise>no</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/">
    <xsl:element name="add">
      <xsl:call-template name="generate_volume_doc" />
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="t:div[ not(@decls) and not(ancestor::node()[@decls])] |
                       t:body[not(@decls) and not(ancestor::node()[@decls])] |
                       t:text[not(@decls) and not(ancestor::node()[@decls])]">

    <xsl:variable name="tit">
        <xsl:call-template name="use_for_title"/>
    </xsl:variable>    
    <xsl:call-template name="trunk_doc">
	<xsl:with-param name="worktitle" select="$tit"/>
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$tit"/>
    </xsl:apply-templates>
      
  </xsl:template>


  <xsl:template name="use_for_title">
    <xsl:choose>
      <xsl:when test="string-length($volume_title)">
	<xsl:value-of select="$volume_title"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="t:head[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get_category">work</xsl:template>

  <xsl:template match="node()[@decls]">
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
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="worktitle" select="$worktitle"/>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template name="is_editorial">
    <xsl:variable name="category"><xsl:call-template name="get_category"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($category,'editorial')">yes</xsl:when>
      <xsl:when test="contains($category,'author')">yes</xsl:when>
      <xsl:when test="contains($category,'period')">yes</xsl:when>
      <xsl:otherwise>no</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="is_literary">
    <xsl:variable name="category"><xsl:call-template name="get_category"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($category,'editorial')">no</xsl:when>
      <xsl:when test="contains($category,'author')">no</xsl:when>
      <xsl:when test="contains($category,'period')">no</xsl:when>
      <xsl:otherwise>yes</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="trunk_doc">
    <xsl:param name="worktitle" select="''"/>

    <xsl:variable name="worktitle_in">
      <xsl:choose>
        <xsl:when test="contains($path,'sks-') and @type='work' and t:div[@type='dedication']">
          <xsl:apply-templates select=".//t:head[@type='workHeader']/@n"/>
        </xsl:when>
        <xsl:when test="contains($path,'sks-') and @type='entry'">
          <xsl:value-of select="$worktitle"/><xsl:text>: </xsl:text><xsl:call-template name="print_date">
            <xsl:with-param name="date"><xsl:value-of select=".//t:dateline/t:date/@when"/></xsl:with-param>
          </xsl:call-template>
          
        </xsl:when>
        <xsl:when test="contains($path,'sks-') and @type='letter' and contains(@corresp,'#')">
          <xsl:value-of select="t:head[@type='letterHeader']/@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$worktitle"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="is_monograph">
      <xsl:call-template name="is_a_monograph"/>
    </xsl:variable>
    
    <xsl:variable name="category">
      <xsl:choose>
        <!-- xsl:when test="@decls">work</xsl:when -->
        <xsl:when test="ancestor-or-self::node()[@decls]">work</xsl:when>
        <xsl:otherwise><xsl:call-template name="get_category"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <doc>

      <xsl:comment> trunk_doc  c=<xsl:value-of select="$c"/> element=<xsl:value-of select="local-name(.)"/> </xsl:comment>
      <xsl:comment> types if any type=<xsl:value-of select="@type"/> subtype=<xsl:value-of select="@subtype"/> </xsl:comment>

      <xsl:element name="field">
        <xsl:attribute name="name">type_ssi</xsl:attribute>
        <xsl:choose>
          <xsl:when test="@decls">work</xsl:when>
          <xsl:when test="contains($path,'sks-') and @type='work' and t:div[@type='dedication']">work</xsl:when>
          <xsl:when test="contains($path,'sks-') and @type='entry'">work</xsl:when>
          <xsl:when test="contains($path,'sks-') and @type='letter' and contains(@corresp,'#')">work</xsl:when>
          <xsl:otherwise>trunk</xsl:otherwise>
        </xsl:choose>
      </xsl:element>      
      
      <xsl:element name="field"><xsl:attribute name="name">cat_ssi</xsl:attribute><xsl:value-of select="$category"/></xsl:element>

      <xsl:element name="field"><xsl:attribute name="name">is_editorial_ssi</xsl:attribute><xsl:call-template name="is_editorial"/></xsl:element>

     <xsl:element name="field"><xsl:attribute name="name">is_monograph_ssi</xsl:attribute><xsl:call-template name="is_a_monograph"/></xsl:element>

     <xsl:if test="string-length($worktitle_in) &gt; 0">
       <xsl:element name="field">
	 <xsl:attribute name="name">work_title_ssi</xsl:attribute>
	 <xsl:value-of select="$worktitle_in"/>
       </xsl:element>

       <xsl:element name="field">
	 <xsl:attribute name="name">sort_title_ssi</xsl:attribute>
	 <xsl:call-template name="str_massage">
	   <xsl:with-param name="str" select="$worktitle_in"/>
	 </xsl:call-template>
       </xsl:element>

       <xsl:element name="field">
	 <xsl:attribute name="name">work_title_tesim</xsl:attribute>
	 <xsl:value-of select="$worktitle_in"/>
       </xsl:element>
     </xsl:if>

     <xsl:if test="string-length($volume_sort_title) &gt; 0">
       <xsl:element name="field">
	 <xsl:attribute name="name">volume_sort_title_ssi</xsl:attribute>
	 <xsl:call-template name="str_massage">
	   <xsl:with-param name="str" select="$volume_sort_title"/>
	 </xsl:call-template>
       </xsl:element>
     </xsl:if>

     <xsl:comment> about to call add_globals from trunc_doc </xsl:comment>
      
     <xsl:call-template name="add_globals">
       <xsl:with-param name="worktitle" select="$worktitle_in"/>
     </xsl:call-template>

     <xsl:call-template name="text_extracts"/>
     <!-- xsl:call-template name="text_type"/ -->


    </doc>
  </xsl:template>

  <xsl:template name="text_type"/>

  <xsl:template match="t:castList">
  
    <xsl:param name="worktitle" select="''"/>

    <xsl:variable name="category"><xsl:call-template name="get_category"/></xsl:variable>

    <doc>
      <xsl:comment> castList </xsl:comment>
      <xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute>leaf</xsl:element>
      <xsl:call-template name="add_globals"/>
      <xsl:element name="field">
        <xsl:attribute name="name">genre_ssi</xsl:attribute>
        <xsl:text>play</xsl:text>
      </xsl:element>
      <xsl:element name="field">
	<xsl:attribute name="name">text_tesim</xsl:attribute>

	    <xsl:apply-templates mode="gettext" 
				 select="./text()|descendant::node()/text()"/>
	
      </xsl:element>
      <xsl:element name="field">
	<xsl:attribute name="name">text_tsim</xsl:attribute>

	<xsl:apply-templates mode="gettext" 
				 select="./text()|descendant::node()/text()"/>
	
      </xsl:element>
    </doc>
  </xsl:template>

  <xsl:template match="t:sp">
    <xsl:param name="worktitle" select="''"/>

    <doc>

      <xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute>leaf</xsl:element>

      <xsl:call-template name="add_globals"/>

      <xsl:element name="field"><xsl:attribute name="name">is_editorial_ssi</xsl:attribute><xsl:call-template name="is_editorial"/></xsl:element>
      
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

      <xsl:element name="field"><xsl:attribute name="name">is_editorial_ssi</xsl:attribute><xsl:call-template name="is_editorial"/></xsl:element>
      
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


  <xsl:template name="make_comment">

    <xsl:param name="worktitle" select="''"/>

    <doc>

      <xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute>leaf</xsl:element>
      <xsl:element name="field"><xsl:attribute name="name">is_editorial_ssi</xsl:attribute><xsl:call-template name="is_editorial"/></xsl:element>

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

  <xsl:template match="t:div/t:p|t:body/t:p|t:text/t:p">

    <xsl:param name="worktitle" select="''"/>
    <xsl:param name="source_template" select="'unknown'"/>

    <xsl:comment> source_template =  <xsl:value-of select="$source_template"/> </xsl:comment>
    
    <doc>

      <xsl:comment> c=<xsl:value-of select="$c"/>  <xsl:text>  element=</xsl:text><xsl:value-of select="local-name(.)"/> </xsl:comment>
      
      <xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute>leaf</xsl:element>
      <xsl:element name="field"><xsl:attribute name="name">is_editorial_ssi</xsl:attribute><xsl:call-template name="is_editorial"/></xsl:element>
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
    <xsl:param name="is_monograph"><xsl:call-template name="is_a_monograph"/></xsl:param>

    <xsl:variable name="is_editorial">
      <xsl:call-template name="is_editorial"/>
    </xsl:variable>

    <xsl:comment> <xsl:call-template name="get_category"/> </xsl:comment>
    
    <doc>
      <xsl:comment> generate_volume_doc </xsl:comment>
      
      <xsl:element name="field"><xsl:attribute name="name">cat_ssi</xsl:attribute><xsl:call-template name="get_category"/></xsl:element>
      <xsl:choose>
        <xsl:when test="contains($is_monograph,'yes')">
          <xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute>work</xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="field"><xsl:attribute name="name">type_ssi</xsl:attribute>volume</xsl:element>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:element name="field"><xsl:attribute name="name">is_editorial_ssi</xsl:attribute><xsl:call-template name="is_editorial"/></xsl:element>
      
      <xsl:element name="field"><xsl:attribute name="name">is_monograph_ssi</xsl:attribute><xsl:call-template name="is_a_monograph"/></xsl:element>

      
      <xsl:if test="contains($path,'adl-authors')">
	<xsl:element name="field">
	  <xsl:attribute name="name">inverted_name_title_ssi</xsl:attribute>
	  <xsl:value-of select="$volume_sort_title"/>
	</xsl:element>
      </xsl:if>
      
      <xsl:variable name="tit">
        <xsl:call-template name="use_for_title"/>
      </xsl:variable>
      
      <xsl:choose>
	<xsl:when test="$is_monograph = 'yes'">
	  <xsl:element name="field">
	    <xsl:attribute name="name">work_title_tesim</xsl:attribute>
	    <xsl:value-of select="normalize-space($tit)"/>
	  </xsl:element>
	  <xsl:element name="field">
	    <xsl:attribute name="name">sort_title_ssi</xsl:attribute>
	    <xsl:call-template name="str_massage">
              <xsl:with-param name="str">
                <xsl:value-of select="$tit"/>
              </xsl:with-param>
	    </xsl:call-template>
	  </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:element name="field">
	    <xsl:attribute name="name">work_title_tesim</xsl:attribute>
	    <xsl:value-of select="normalize-space($volume_title)"/>
	  </xsl:element>
	  <xsl:element name="field">
	    <xsl:attribute name="name">sort_title_ssi</xsl:attribute>
	    <xsl:call-template name="str_massage">
	      <xsl:with-param name="str" select="$volume_title"/>
	    </xsl:call-template>
	  </xsl:element>
	</xsl:otherwise>
      </xsl:choose>

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

      <xsl:comment> about to call add_globals from generate_volume_doc </xsl:comment>
      <xsl:call-template name="add_globals" />

      <xsl:if test="contains($is_monograph,'yes')">
        <xsl:call-template name="text_extracts"/>
      </xsl:if>
      
    </doc>
  </xsl:template>

  <xsl:template name="add_globals">
    <xsl:param name="worktitle" select="''"/>
    
    <xsl:comment> add_globals called </xsl:comment>

    <xsl:call-template name="extract_entities"/>
    
    <xsl:element name="field">
      <xsl:attribute name="name">id</xsl:attribute>
      <xsl:choose>
        <xsl:when test="@xml:id">
          <xsl:value-of select="concat(substring-before($path,'-root'),'-shoot-',me:massage-uri-component(@xml:id))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$path"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:if test="contains($path,'gv-')">
      <xsl:variable name="ditsi">
        <xsl:value-of select="number(me:year-extractor($path))"/>
      </xsl:variable>

      <xsl:if test="not(contains($ditsi,'NaN'))">
        <xsl:element name="field">
	  <xsl:attribute name="name">year_itsi</xsl:attribute><xsl:value-of select="$ditsi"/>
        </xsl:element>
      </xsl:if>
    </xsl:if>


    <xsl:if test="contains($path,'sks-')">

      <xsl:choose>
        <xsl:when test="@type='work' and t:div[@type='dedication']">
          
          <xsl:variable name="ditsi">
            <xsl:if test="me:year-extractor(t:dateline/t:date/@when)">
             <xsl:value-of select="number(me:year-extractor(t:dateline/t:date/@when))"/>
            </xsl:if>
          </xsl:variable>
          <xsl:if test="$ditsi &gt; 1000">
            <xsl:element name="field">
	      <xsl:attribute name="name">year_itsi</xsl:attribute><xsl:value-of select="$ditsi"/>
            </xsl:element>
          </xsl:if>
        </xsl:when>
        <xsl:when test="contains(@type,'entry')">
          <xsl:variable name="ditsi">
            <xsl:if test="me:year-extractor(t:dateline/t:date/@when) &gt; 0">
              <xsl:value-of select="number(me:year-extractor(t:dateline/t:date/@when))"/>
            </xsl:if>
          </xsl:variable>
          <xsl:if test="$ditsi &gt; 1000">
            <xsl:element name="field">
	      <xsl:attribute name="name">year_itsi</xsl:attribute><xsl:value-of select="$ditsi"/>
            </xsl:element>
          </xsl:if>
        </xsl:when>
        <xsl:when test="contains(@type,'letter') and contains(@corresp,'#')">
          <xsl:variable name="corresp">
            <xsl:value-of select="substring-after(@corresp,'#')"/>
          </xsl:variable>
          <xsl:variable name="sent_year">
            <xsl:for-each select="//t:correspDesc[@xml:id=$corresp][1]">
              <xsl:if test="number(me:year-extractor(t:correspAction[@type='sent']/t:date/@when)) &gt; 0">
                <xsl:value-of
                    select="number(me:year-extractor(t:correspAction[@type='sent']/t:date/@when))"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
           <xsl:if test="$sent_year and number($sent_year) &gt; 1000">
            <xsl:element name="field">
	      <xsl:attribute name="name">year_itsi</xsl:attribute><xsl:value-of select="$sent_year"/>
            </xsl:element>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    
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

    <xsl:call-template name="text_type"/>
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

    <xsl:choose>
      <xsl:when test="contains($path,'adl-authors')">
        <xsl:call-template name="extract_titles_authors_etc">
          <xsl:with-param name="worktitle" select="$worktitle"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="extract_titles_authors_etc">
          <xsl:with-param name="worktitle" select="$worktitle"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:call-template name="what_i_can"/>

    <xsl:call-template name="get_terms"/>
    
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

    <xsl:element name="field">
      <xsl:attribute name="name">num_authors_isi</xsl:attribute>
      <xsl:value-of  select="$num_authors"/>
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

  <!-- xsl:template name="author_ssim">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template -->

  <xsl:function name="me:is-a-work">
    <xsl:param name="this"  as="node()"/>
    <xsl:if test="$this/@decls"><xsl:value-of select="$this/@decls"/></xsl:if>
  </xsl:function>

  <xsl:template mode="backtrack" match="node()[@xml:id]">
    <xsl:element name="field">
      <xsl:attribute name="name">part_of_ssim</xsl:attribute>
      <xsl:choose>
	<xsl:when test="not(contains(@xml:id,'root'))">
	  <xsl:value-of select="concat(substring-before($path,'-root'),'-shoot-',me:massage-uri-component(@xml:id))"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$path"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:apply-templates mode="backtrack" select="ancestor::node()[@xml:id][1]"/>
  </xsl:template>
  
  <!-- xsl:template mode="backtrack" match="node()[@xml:id]">
    <xsl:choose>
      <xsl:when test="@decls">
	<xsl:element name="field">
	  <xsl:attribute name="name">part_of_ssim</xsl:attribute>
	  <xsl:value-of select="concat(substring-before($path,'-root'),'-shoot-',me:massage-uri-component(@xml:id))"/>
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
        <xsl:choose>
          <xsl:when test="ancestor::node()[@decls]">
	    <xsl:apply-templates mode="backtrack" select="ancestor::node()[@decls][1]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="field">
	      <xsl:attribute name="name">part_of_ssim</xsl:attribute>
	      <xsl:value-of select="$path"/>
	    </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template -->

  <!-- 
       This is the default behaviour, used in SKS 
       GV has its own instance of this function
  -->
  <xsl:function name="me:find-normalized-entity">
    <xsl:param name="this"  as="node()"/>
    <xsl:choose>
      <xsl:when test="$this/@key">
        <xsl:value-of select="$this/@key"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$this/text()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template name="extract_entities">

    <!-- t:rs[@type='myth']|t:rs[@type='title']|t:rs[@type='bible']" -->
    
    <xsl:for-each select="descendant-or-self::t:persName">
      <xsl:variable name="this_value" select="me:find-normalized-entity(.)"/>
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
    
    <xsl:for-each select="descendant-or-self::t:placeName">
      <xsl:variable name="this_value" select="me:find-normalized-entity(.)"/>
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

  <xsl:template name="mkentity">
    <xsl:param name="entity_field"/>
    <xsl:param name="node" select="."/>
    <xsl:call-template name="mkfield">
      <xsl:with-param name="field"><xsl:value-of select="$entity_field"/></xsl:with-param>
      <xsl:with-param name="value">
        <xsl:value-of select="normalize-space($node)"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="text_extracts">

    <xsl:variable name="sp_text">
      <xsl:apply-templates mode="gettext" select="./t:sp|descendant::t:sp//node()"/>
    </xsl:variable>

    <xsl:variable name="p_text">
      <xsl:apply-templates mode="gettext" select="./t:p|descendant::t:div/t:p"/>
    </xsl:variable>

    <xsl:variable name="lg_text">
      <xsl:apply-templates mode="gettext" select="descendant::t:lg/t:l"/> 
    </xsl:variable>

    <xsl:if test="not(contains($path,'gv-'))">
      <xsl:choose>
        <xsl:when test="string-length($sp_text) &gt; string-length($p_text) and string-length($sp_text) &gt; string-length($lg_text)">
	  <xsl:call-template name="mkfield">
	    <xsl:with-param name="field">contains_ssi</xsl:with-param>
	    <xsl:with-param name="value">play</xsl:with-param>
	  </xsl:call-template>
        </xsl:when>
        <xsl:when test="string-length($lg_text) &gt; string-length($p_text) and string-length($lg_text) &gt; string-length($sp_text)">
	  <xsl:call-template name="mkfield">
	    <xsl:with-param name="field">contains_ssi</xsl:with-param>
	    <xsl:with-param name="value">poetry</xsl:with-param>
	  </xsl:call-template>
        </xsl:when>
        <xsl:when test="string-length($p_text) &gt; string-length($sp_text) and string-length($p_text) &gt; string-length($lg_text)">
	  <xsl:call-template name="mkfield">
	    <xsl:with-param name="field">contains_ssi</xsl:with-param>
	    <xsl:with-param name="value">prose</xsl:with-param>
	  </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    
    <xsl:element name="field">
       <xsl:attribute name="name">text_tesim</xsl:attribute>

       <xsl:apply-templates mode="gettext" 
			    select="./text()|descendant::node()/text()"/>
	
    </xsl:element>

     <!-- I removed this. I put it here as a comment since I am not
          really sure it was very clever to cut it away -->
      
     <!-- xsl:element name="field">
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
      </xsl:element -->
    

    <xsl:element name="field">
      <xsl:attribute name="name">performance_extract_tesim</xsl:attribute>
      <xsl:apply-templates mode="gettext" select="descendant::t:sp"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">prose_extract_tesim</xsl:attribute>
      <xsl:apply-templates mode="gettext" select="./t:p|descendant::t:div/t:p"/>
    </xsl:element>

    <xsl:element name="field">
      <xsl:attribute name="name">verse_extract_tesim</xsl:attribute>
      <xsl:apply-templates mode="gettext" select="descendant::t:lg/t:l"/> 
    </xsl:element>

  </xsl:template>

  <xsl:template name="mkfield">
    <xsl:param name="field"/>
    <xsl:param name="value"/>
    <xsl:element name="field">
      <xsl:attribute name="name"><xsl:value-of select="$field"/></xsl:attribute>
      <xsl:value-of select="$value"/>
    </xsl:element>
  </xsl:template>

 
  <xsl:template name="common_extract_titles_authors_etc">
    <xsl:param name="worktitle" select="''"/>

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
		<!-- xsl:call-template name="author_ssim"/ -->
                <xsl:value-of select="normalize-space(.)"/>
	      </xsl:element>
	      <xsl:element name="field">
		<xsl:attribute name="name">author_name_tesim</xsl:attribute>
		<xsl:choose> <!-- Looks like we are handling Saxo et al. -->
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

            <xsl:choose> <!-- this is broken in general but as date_semantics is written, it works -->
              <xsl:when test="t:date[@type]">
                <xsl:for-each select="t:date[@type]">
	          <xsl:element name="field">
	            <xsl:attribute name="name">
                      <xsl:call-template name="date_semantics">
                        <xsl:with-param name="type" select="@type"/>
                      </xsl:call-template>
                    </xsl:attribute>
		    <xsl:value-of select="."/>
                  </xsl:element>
	        </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="t:date">
	          <xsl:element name="field">
	            <xsl:attribute name="name">date_published_ssi</xsl:attribute>
	            <xsl:for-each select="t:date">
		      <xsl:value-of select="."/>
	            </xsl:for-each>
	          </xsl:element>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
	  </xsl:for-each>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt">
	  <xsl:if test="t:title">
            <xsl:if test="$worktitle">
	      <xsl:element name="field">
	        <xsl:attribute name="name">work_title_tesim</xsl:attribute>
	        <xsl:value-of select="t:title"/>
	      </xsl:element>
	      <xsl:element name="field">
	        <xsl:attribute name="name">work_title_ssim</xsl:attribute>
	        <xsl:value-of select="t:title"/>
	      </xsl:element>
            </xsl:if>
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

  <!-- good enough if this is tei @when -->
  <xsl:function name="me:year-extractor">
    <xsl:param name="date_content"/>
    <xsl:value-of select="fn:replace($date_content,'^.*?(1\d{3}).*$','$1','m')"/>
  </xsl:function>
  
  <xsl:template name="date_semantics">
    <xsl:param name="type" select="'published'"/>

    <!--

dc:date

Created
Valid
Available
Issued
Modified
Date Accepted
Date Copyrighted
Date Submitted

Date elements from mods

dateIssued
dateCreated
dateCaptured
dateValid
dateModified
copyrightDate
dateOther

Date types/codes for marc21

Publication
Distribution
Production
Publication,
Distribution
Manufacture
Copyright Notice
Dates of Publication and/or Sequential Designation

    -->
    
    <xsl:choose>
      <xsl:when test="contains($type,'published')">date_published_ssi</xsl:when>
      <xsl:when test="contains($type,'publica')">date_published_ssi</xsl:when>
      <xsl:when test="contains($type,'release')">date_published_ssi</xsl:when>
      <xsl:when test="contains($type,'announced')">date_announced_ssi</xsl:when>
      <xsl:otherwise>date_published_ssi</xsl:otherwise>
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
  
  <xsl:function name="me:massage-uri-component">
    <xsl:param name="string_value"/>
    <xsl:value-of select="fn:replace($string_value,'\.','_')"/>
  </xsl:function>

  <xsl:template name="inferred_path">
    <xsl:param name="document"/>
    <xsl:value-of select="$document"/>
  </xsl:template>

  <xsl:template name="get_terms">

    <xsl:for-each select="/t:TEI/t:teiHeader/t:profileDesc">
      <xsl:comment> start GV terminology </xsl:comment>
      <xsl:call-template name="get_genres"/>
      <xsl:call-template name="get_keywords"/>
      <xsl:comment> end GV terminology </xsl:comment>
    </xsl:for-each>

  </xsl:template>


  <xsl:template name="get_genres">
    <xsl:for-each select="t:textClass/t:classCode">
      <xsl:for-each select="t:term">
        <xsl:call-template name="mkfield">
          <xsl:with-param name="field">textclass_genre_tesim</xsl:with-param>
          <xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="mkfield">
          <xsl:with-param name="field">textclass_genre_ssim</xsl:with-param>
          <xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="get_keywords"> 
    <xsl:for-each select="t:textClass/t:keywords">
      <xsl:for-each select="t:term">
        <xsl:call-template name="mkfield">
          <xsl:with-param name="field">textclass_keywords_tesim</xsl:with-param>
          <xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="mkfield">
          <xsl:with-param name="field">textclass_keywords_ssim</xsl:with-param>
          <xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

    
  <xsl:template name="print_date">
    <xsl:param name="date" select="''"/>
    <xsl:variable name="year">
      <xsl:value-of select="substring($date,1,4)"/>
    </xsl:variable>
    <xsl:variable name="month_day">
      <xsl:choose>
      <xsl:when test="not(contains($date,'0000'))"><xsl:value-of select="substring-after($date,$year)"/></xsl:when>
      <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
      date = <xsl:value-of select="$date"/>

      month_day = <xsl:value-of select="$month_day"/>

      year = <xsl:value-of select="$year"/>

      month = <xsl:value-of select="substring($month_day,1,2)"/>

      day   = <xsl:value-of select="substring($month_day,3,4)"/>

    -->
    <xsl:value-of select="$year"/><xsl:if test="not(contains($date,'0000'))">-<xsl:value-of select="substring($month_day,1,2)"/>-<xsl:value-of select="substring($month_day,3,4)"/></xsl:if>
  </xsl:template>


  
</xsl:transform>
