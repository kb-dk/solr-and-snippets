<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:t="http://www.tei-c.org/ns/1.0"
		version="2.0">

  <xsl:template match="t:p[@type='decoration']">
    <xsl:apply-templates select="t:figure"/>
  </xsl:template>

  <xsl:template match="t:figure[@type='3crossesDown']">
    <div style="text-align:center;">
      <xsl:text>+ &#160; +</xsl:text><br/>
      <xsl:text>+</xsl:text><br/>
    </div>
  </xsl:template>

  <xsl:template match="t:figure[@type='3asterisksDown']">
    <div style="text-align:center;">
      <xsl:text>* &#160; *</xsl:text><br/>
      <xsl:text>*</xsl:text><br/>
    </div>
  </xsl:template>

  <xsl:template match="t:figure[@type='3asterisksUp']">
    <div style="text-align:center;">
      <xsl:text>*</xsl:text><br/>
      <xsl:text>* &#160; *</xsl:text><br/>
    </div>
  </xsl:template>

  <xsl:template match="t:figure[@type='hash' or @type='hashBlank']">
    <div style="text-align:center;">
      <xsl:text>#</xsl:text><br/>
    </div>
  </xsl:template>

  <xsl:template match="t:figure[@type='divisionRuler']">
    <div style="text-align:center;">
      <xsl:text>──────────</xsl:text><br/>
    </div>
  </xsl:template>

  <xsl:template match="t:figure[@type='hashSingleDouble']">
    <div style="text-align:center;">
      <xsl:text>╪</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="t:figure[@type='divisionRulerDouble']">
    <div style="text-align:center;">
      <xsl:text>══════════</xsl:text><br/>
    </div>
  </xsl:template>

  <xsl:template match="t:figure[@type='divisionRulerWaved']">
    <div style="text-align:center;">
      <xsl:text>∿∿∿∿∿∿∿∿∿</xsl:text><br/>
    </div>
  </xsl:template>

  <xsl:template match="t:figure[@type='divisionRulerWavedPoint']">
    <div style="text-align:center;">
      <xsl:text>∿∿∿∿∿∿∿∿∿.</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="t:figure[@type='dashDouble']">
    <div style="text-align:center;">
      <xsl:text>═</xsl:text><br/>
    </div>
  </xsl:template>

  <xsl:template match="t:figure[@type='2asterisks']">
    <div style="text-align:center;">
      <xsl:text>* &#160; *</xsl:text><br/>
    </div>
  </xsl:template>

 <xsl:template match="t:figure[@type='blank']">
    <div style="text-align:center;">
      <br style="clear: both;"/>
    </div>
  </xsl:template>

  <xsl:template match="t:figure[@type='hashEntwined']">
    <div style="text-align:center;">
      <xsl:text>~&#160;$&#160;~</xsl:text>
    </div>
  </xsl:template>
  
</xsl:stylesheet>
