<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text"/>
  
  <xsl:template match="/table">

    <xsl:for-each select="tr[td = '4 4 3 3']">
./find_word_frequencies.sh<xsl:value-of select="concat(' -f ',th,' -x ',td[2])"/><xsl:text>      
</xsl:text></xsl:for-each>

  </xsl:template>
  
</xsl:transform>
