<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:t="http://www.tei-c.org/ns/1.0"
		version="2.0">

  <xsl:template match="t:p[@type='decoration']">
    <xsl:apply-templates select="t:figure"/>
  </xsl:template>

  <xsl:template match="t:figure[@type='3crossesDown']">
    <p style="text-align:center;">
      <xsl:text>+  +</xsl:text><br/>
      <xsl:text>+</xsl:text><br/>
    </p>
  </xsl:template>

  <xsl:template match="t:figure[@type='3asterisksDown']">
    <p style="text-align:center;">
<xsl:text>*  *</xsl:text><br/>
<xsl:text>*</xsl:text><br/>
    </p>
  </xsl:template>

  <xsl:template match="t:figure[@type='3asterisksUp']">
    <p style="text-align:center;">
<xsl:text>*</xsl:text><br/>
<xsl:text>*  *</xsl:text><br/>
    </p>
  </xsl:template>

  <xsl:template match="t:figure[@type='hash']">
    <p style="text-align:center;">
      <xsl:text>#</xsl:text><br/>
    </p>
  </xsl:template>

  <xsl:template match="t:figure[@type='divisionRuler']">
    <p style="text-align:center;">
      <xsl:text>──────────</xsl:text><br/>
    </p>
  </xsl:template>


  <xsl:template match="t:figure[@type='divisionRulerDouble']">
    <p style="text-align:center;">
      <xsl:text>══════════</xsl:text><br/>
    </p>
  </xsl:template>

  <xsl:template match="t:figure[@type='divisionRulerWaved']">
    <p style="text-align:center;">
      <xsl:text>∿∿∿∿∿∿∿∿∿</xsl:text><br/>
    </p>
  </xsl:template>

  <xsl:template match="t:figure[@type='divisionRulerWavedPoint']">
    <p style="text-align:center;">
      <xsl:text>∿∿∿∿∿∿∿∿∿.</xsl:text>
    </p>
  </xsl:template>

  <xsl:template match="t:figure[@type='dashDouble']">
    <p style="text-align:center;">
      <xsl:text>═</xsl:text><br/>
    </p>
  </xsl:template>

  <xsl:template match="t:figure[@type='2asterisks']">
    <p style="text-align:center;">
      <xsl:text>*  *</xsl:text><br/>
    </p>
  </xsl:template>

</xsl:stylesheet>