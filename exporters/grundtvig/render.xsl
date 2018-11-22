<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">
  
  <xsl:import href="../render-global.xsl"/>
  <xsl:import href="../apparatus-global.xsl"/>
  <xsl:import href="../all_kinds_of_notes-global.xsl"/>

  <xsl:template name="make-href">

    <xsl:variable name="target">
      <xsl:value-of select="translate(@target,$uppercase,$lowercase)"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="contains($target,'#') and not(substring-before($target,'#'))">
	<xsl:value-of select="$target"/>	    
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="href">
	  <xsl:variable name="fragment">
	    <xsl:if test="contains($target,'#')">
	      <xsl:value-of select="concat('#',substring-after($target,'#'))"/>
	    </xsl:if>
	  </xsl:variable>
	  <xsl:variable name="file">
	    <xsl:choose>
	      <xsl:when test="contains($target,'#')">
		<xsl:value-of select="substring-before($target,'#')"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="$target"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>
	  <xsl:choose>
	    <xsl:when test="contains($file,'../')">
	      <xsl:value-of select="concat($c,'-',substring-before(substring-after($file,'../'),'.xml'),'-root',$fragment)"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:choose>
		<xsl:when test="contains($path,'-txt')">
		  <xsl:value-of 
		      select="concat(substring-before($path,'-txt'),
			      '-',
			      substring-before($target,'.xml'),
			      '-root',
			      substring-after($target,'.xml'))"/>
		</xsl:when>
		<xsl:when test="contains($path,'-kom')">
		  <xsl:value-of 
		      select="concat(substring-before($path,'-kom'),'-',substring-before($target,'.xml'),'-root',substring-after($target,'.xml'))"/>
		</xsl:when>
		<xsl:when test="contains($path,'-txr')">
		  <xsl:value-of 
		      select="concat(substring-before($path,'-txr'),'-',substring-before($target,'.xml'),'-root',substring-after($target,'.xml'))"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="$target"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	<xsl:value-of select="concat($adl_baseuri,'/text/',translate($href,'/','-'))"/>
      </xsl:otherwise>
    </xsl:choose>


  </xsl:template>



</xsl:transform>
