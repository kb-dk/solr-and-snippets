<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:fn="http://www.w3.org/2005/xpath-functions"
	       exclude-result-prefixes="t fn">

  <xsl:import href="../render-global.xsl"/>  

   <xsl:template name="inferred_path">
     <xsl:param name="document" select="$doc"/>
     <xsl:variable name="frag">
       <xsl:choose>
	 <xsl:when test="contains($document,'#')">
	   <xsl:value-of select="fn:replace(substring-after($document,'#'),':.*$','')"/>
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
     <xsl:text>/text/</xsl:text><xsl:value-of select="replace(concat($c,'-',fn:lower-case(fn:replace($document,'(\.xml)|(\.page).*$','')),$f,$frag),'/','-')"/>
   </xsl:template>

  <xsl:template name="make-href">
    <xsl:call-template name="inferred_path">
      <xsl:with-param name="document" select="@target"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="make_author_note_list"/>
   
  <xsl:template match="t:div/t:p|t:text/t:p|t:body/t:p">
    <p class="paragraph">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </p>
    <xsl:call-template name="make_author_note_list"/>
  </xsl:template>

  <xsl:template match="t:fw"/>
  
  <xsl:template match="t:milestone[@next]">
    <div id="{@xml:id}">
      <xsl:attribute name="style">
        <xsl:choose>
          <xsl:when test="@type = 'leftside'">clear: both;text-align: left;</xsl:when>
          <xsl:otherwise>clear: both;text-align: right;"></xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <p  style="box-sizing: content-box;width: 100%;border: solid #5B6DCD 1px;padding: 5px;">
        <a href="#{@xml:id}">spalte<xsl:value-of select="@n"/></a>
      </p>
    </div>
  </xsl:template>
  

</xsl:transform>
