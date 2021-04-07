<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:t="http://www.tei-c.org/ns/1.0"
		version="2.0">

  <xsl:template match="t:fw"/>

  <!-- 

t:figure elements

      1  type="engraver">
      2  type="longLine"/>
     46  type="imageMyth">
    483  type="shortLine"/>

t:graphic elements

    216  style="blank"
   1096  style="longLine"
   1302  style="shortLine"
   1195  style="shortLine/longLine"

  -->

  <xsl:template match="t:figure[@type='shortLine']|t:graphic[@style='shortLine']">
    <xsl:element name="hr">
      <xsl:attribute name="style">text-align:center; border-top: 1px solid black; width: 8%</xsl:attribute>
    </xsl:element> <xsl:comment> t:graphic[@style='shortLine' </xsl:comment>
  </xsl:template>
  
  <xsl:template match="t:figure[@type='engraver']"/>

  <xsl:template match="t:graphic[@style='blank']">
    <br/> <xsl:comment> t:graphic[@style='blank']" </xsl:comment>
  </xsl:template>
  
  <xsl:template match="t:figure[@type='longLine']|t:graphic[@style='longLine']">
    <xsl:element name="hr">
      <xsl:attribute name="style">text-align:center; border-top: 1px solid black; width: 25%</xsl:attribute>
    </xsl:element> <xsl:comment> t:graphic[@style='longLine'] </xsl:comment>
  </xsl:template>

  <!-- shortLine/longLine and imageMyth need investigation -->

</xsl:stylesheet>
