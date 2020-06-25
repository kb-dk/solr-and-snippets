<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="2.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       exclude-result-prefixes="t">
  
  <xsl:import href="../toc-global.xsl"/>

  
  <xsl:template name="do_root">
    <div>
      <xsl:comment>
	<xsl:value-of select="$path"/>
      </xsl:comment>
      <ul>
	<xsl:choose>
	  <xsl:when test="//node()[@decls]">
	    <xsl:for-each  select="//node()[@decls]">
	      <xsl:apply-templates select="."/>
	    </xsl:for-each>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="//t:body"/>
	  </xsl:otherwise>
	</xsl:choose>
      </ul>
    </div>
  </xsl:template>

  
</xsl:transform>
