<?xml version="1.0" encoding="UTF-8" ?>
<!--

Author Sigfrid Lundberg slu@kb.dk

-->
<xsl:transform version="2.0"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	       exclude-result-prefixes="t">

  <xsl:param name="id" select="''"/>
  <xsl:param name="doc" select="''"/>
  <xsl:param name="path" select="''"/>
  <xsl:param name="targetOp" select="''"/>
  <xsl:param name="hostname" select="''"/>

  <xsl:output encoding="UTF-8"
	      indent="yes"
	      method="xml"
	      omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <div>
      <xsl:comment>
	<xsl:value-of select="$path"/>
      </xsl:comment>
      <ul>
	<xsl:choose>
	  <xsl:when test="//node()[@decls]">
	    <xsl:for-each  select="//node()[not(@decls)]//node()[@decls]">
	      <xsl:apply-templates/>
	    </xsl:for-each>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="//t:body"/>
	  </xsl:otherwise>
	</xsl:choose>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="t:teiHeader"/>

  <xsl:template match="node()[@decls]|t:group|t:body|t:text|t:div|t:front|t:back">
    <xsl:element name="li">
      <xsl:attribute name="id">
	<xsl:value-of select="concat('toc',@xml:id)"/>
      </xsl:attribute>
      <xsl:call-template name="add_anchor"/>
      <xsl:if test=".//node()[@decls]|t:group|t:body|t:text|t:div|t:front|t:back">
	<ul>
	  <xsl:apply-templates select=".//node()[@decls]|t:group|t:body|t:text|t:div|t:front|t:back"/>
	</ul>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:head">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="t:lb">
    <xsl:text> 
    </xsl:text>
  </xsl:template>

  <xsl:template match="t:hi">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="add_anchor">
    <xsl:variable name="bibl">
      <xsl:choose>
	<xsl:when test="contains(@decls,'#')"><xsl:value-of select="substring-after(@decls,'#')"/></xsl:when>
	<xsl:otherwise><xsl:value-of select="@decls"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:choose>
	<xsl:when 
	    test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:listBibl/t:bibl[@xml:id=$bibl]">
	  <xsl:value-of
	      select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:listBibl/t:bibl[@xml:id=$bibl]"/>
	</xsl:when>
	<xsl:when test="t:head[text()]">
	    <xsl:value-of select="t:head"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:variable name="some_text">
	    <xsl:apply-templates select=".//text()" />
	  </xsl:variable>
	  <xsl:value-of
	      select="substring(normalize-space($some_text/string()),1,30)"/>
	  <xsl:if test="string-length(normalize-space($some_text/string())) &gt; 30"><xsl:text>...</xsl:text></xsl:if>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length(normalize-space($title)) &gt; 0">
      <xsl:element name="a">
	<xsl:attribute name="href">
	  <xsl:choose>
	    <xsl:when test="$targetOp">
	      <xsl:value-of select="concat('?path=',$path,'&amp;op=',$targetOp,'#',@xml:id)"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:call-template name="make_href"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
	<xsl:value-of select="$title"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="make_href">
    <xsl:if test="@xml:id">
      <xsl:choose>
        <xsl:when test="@decls">
	  <xsl:value-of select="concat('/text/',replace($path,'(sh)|(r)oot','shoot-'),@xml:id)"/>
        </xsl:when>
        <xsl:otherwise>
	  <xsl:choose>
	    <xsl:when test="./ancestor::node()[@decls]">
	      <xsl:value-of select="concat('/text/',replace($path,'(sh)|(r)oot','shoot-'),./ancestor::node()[@decls][1]/@xml:id,'#',@xml:id)"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="concat('/text/',replace($path,'(sh)|(r)oot','root#'),@xml:id)"/>
	    </xsl:otherwise>
	  </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:transform>

