<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:t="http://www.tei-c.org/ns/1.0"
		version="2.0">

  <xsl:template match="t:fw"/>

  <!--
      1  type="engraver">
      2  type="longLine"/>
     46  type="imageMyth">
    483  type="shortLine"/>
  -->

  <xsl:template match="t:figure[@type='shortLine']"/>
  <xsl:template match="t:figure[@type='engraver']"/>
  <xsl:template match="t:figure[@type='longLine']"/>

  <!-- imageMyth needs investigation -->

</xsl:stylesheet>
