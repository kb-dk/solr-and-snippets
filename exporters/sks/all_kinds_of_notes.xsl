<?xml version="1.0"  encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:t="http://www.tei-c.org/ns/1.0"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:me="urn:my-things"
                exclude-result-prefixes="t me" version="2.0">

  <xsl:import href="../all_kinds_of_notes-global.xsl"/>


  <xsl:param name="id" select="''"/>
  <xsl:param name="doc" select="''"/>
  <xsl:param name="file" select="fn:replace($doc,'.*/([^/]+)$','$1')"/>
  <xsl:param name="prev" select="''"/>
  <xsl:param name="prev_encoded" select="''"/>
  <xsl:param name="next" select="''"/>
  <xsl:param name="next_encoded" select="''"/>
  <xsl:param name="c" select="''"/>
  <xsl:param name="hostname" select="''"/>
  <xsl:param name="hostport" select="''"/>
  <xsl:param name="adl_baseuri">
    <xsl:choose>
      <xsl:when test="$hostport">
	<xsl:value-of select="concat('http://',$hostport)"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="facslinks" select="''"/>
  <xsl:param name="path" select="''"/>
  <xsl:param name="capabilities" select="''"/>
  <xsl:param name="cap" select="document($capabilities)"/>

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:template name="make_author_note_list">

    <xsl:variable name="first_note" select="substring-after(descendant-or-self::t:ptr[@type='author'][1]/@target,'#')"/> 
    
    <xsl:if test="/t:TEI//t:note[@xml:id = $first_note][@place = 'bottom']"> 
      <div style="border-top: thin solid lightgray; width: 67%;">
	<strong>Noter:</strong>
	<ol>
	  <xsl:for-each select="descendant-or-self::t:ptr[@type='author']">
	    <xsl:variable name="target">
	      <xsl:value-of select="substring-after(@target,'#')"/>
	    </xsl:variable>
	    <li>
	      <xsl:for-each select="/t:TEI//t:note[@xml:id = $target][@place = 'bottom']">
		<xsl:call-template name="show_note">
		  <xsl:with-param name="display" select="'block'"/>
		  <xsl:with-param name="bgcolor" select="'inherit'"/>
		</xsl:call-template>
	      </xsl:for-each>(<a href="#ref{$target}">tilbage</a>)
	    </li>
	  </xsl:for-each>
	</ol>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="t:ptr[@type = 'author']">
    <xsl:choose>
      <xsl:when test="../../@type = 'mainColumn'">
        <xsl:call-template name="journals-ptr"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="pos">
          <xsl:value-of select="1+count(preceding-sibling::t:ptr[@type = 'author'])"/>
        </xsl:variable>
        <xsl:variable name="target">
          <xsl:value-of select="substring-after(@target,'#')"/>
        </xsl:variable>
        <xsl:for-each select="/t:TEI//t:note[@xml:id = $target]">
          <sup>
            <xsl:call-template name="add-ptr-marker">
              <xsl:with-param name="target" select="$target"/>
              <xsl:with-param name="marker" select="$pos"/>
            </xsl:call-template>
          </sup>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="add-ptr-marker">
    <xsl:param name="target" select="''"/>
    <xsl:param name="marker" select="'*'"/>
    <xsl:attribute name="id">
      <xsl:attribute name="href">ref<xsl:value-of select="$target"/>
            </xsl:attribute>
    </xsl:attribute>
    <xsl:element name="a">
      <xsl:attribute name="href">#<xsl:value-of select="$target"/>
            </xsl:attribute>
      <xsl:copy-of select="$marker"/>
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>
