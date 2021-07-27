<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:me="urn:my-things"
    exclude-result-prefixes="t me"
    version="2.0">

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
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="facslinks" select="''"/>
  <xsl:param name="path" select="''"/>
  <xsl:param name="capabilities" select="''"/>
  <xsl:param name="cap" select="document($capabilities)"/>

  <xsl:param name="sup_style">vertical-align: baseline; position: relative; bottom: .33em;</xsl:param>
  <xsl:param name="sub_style">vertical-align: baseline; position: relative; bottom: -.33em;</xsl:param>
  

  <xsl:output method="xml"
	      encoding="UTF-8"
	      indent="yes"/>


  <xsl:template name="make_author_note_list"/>

  <xsl:template match="t:ptr[@type = 'author']">
    <xsl:variable name="target">
      <xsl:value-of select="substring-after(@target,'#')"/>
    </xsl:variable>
    <xsl:for-each select="/t:TEI//t:note[@xml:id = $target]">
      <xsl:call-template name="inline_note"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="t:note[@type = 'author']"/>

  <xsl:template name="inline_note">
    <xsl:call-template name="general_note_code">
      <xsl:with-param name="display" select="'none'"/>
    </xsl:call-template><xsl:call-template name="show_note">
      <xsl:with-param name="display" select="'none'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="show_note">
    <xsl:param name="display" select="'none'"/>
    <xsl:param name="bgcolor" select="'#D6D6D6'"/>
    <span class="note_content" title="Note" style="background-color:{$bgcolor};display:{$display};">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template name="general_note_code">
    <xsl:param name="display" select="'none'"/>
    <xsl:param name="lbl" select="'*'"/>
    <xsl:variable name="idstring"><xsl:value-of select="translate(@xml:id,'-;.','___')"/></xsl:variable>
    <xsl:variable name="note"><xsl:value-of select="concat('note',$idstring)"/></xsl:variable>

      <script>
	var <xsl:value-of select="concat('disp',$idstring)"/>="none";
	function <xsl:value-of select="$note"/>() {
	var ele = document.getElementById("<xsl:value-of select="@xml:id"/>");
	if(<xsl:value-of select="concat('disp',$idstring)"/>=="none") {
	ele.style.display="inline";
	<xsl:value-of select="concat('disp',$idstring)"/>="inline";
	} else {
	ele.style.display="none";
	<xsl:value-of select="concat('disp',$idstring)"/>="none";
	}
	}
      </script>

      <xsl:call-template name="note_anchor">
        <xsl:with-param name="sup_style" select="$sup_style"/>
        <xsl:with-param name="note" select="$note"/>
        <xsl:with-param name="lbl" select="$lbl"/>
      </xsl:call-template>

  </xsl:template>

  <xsl:template name="note_anchor">
    <xsl:param name="lbl" select="'*'"/>
    <xsl:param name="note" select="''"/>
    <xsl:param name="sup_style" select="''"/>
    <xsl:element name="a">
	<xsl:attribute name="onclick"><xsl:value-of select="$note"/>();</xsl:attribute>
        <xsl:attribute name="style"><xsl:value-of select="$sup_style"/></xsl:attribute>
        <xsl:attribute name="class">note</xsl:attribute>
        <xsl:attribute name="title">
          <xsl:choose>
	    <xsl:when test="@type='author'">Forfatterens note</xsl:when>
            <xsl:otherwise>Note</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
	<xsl:choose>
	  <xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when>
	  <xsl:otherwise><xsl:value-of select="$lbl"/></xsl:otherwise>
	</xsl:choose>
      </xsl:element>
  </xsl:template>

  <xsl:template match="t:note/t:p">
    <span>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

</xsl:stylesheet>
