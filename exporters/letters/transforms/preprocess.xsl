<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform 
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

  <xsl:output method="xml"
	      indent="yes"
	      encoding="UTF-8"/>


  <xsl:template match="t:*">
    <xsl:element name="{name()}">
      <xsl:if test="not(@xml:id)">
        <xsl:attribute name="xml:id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="t:sourceDesc">
    <xsl:element xmlns="http://www.tei-c.org/ns/1.0"
		 name="t:sourceDesc">
      <xsl:apply-templates select="node()|@*" />
      <xsl:element name="listBibl">
	<xsl:for-each select="//t:div[@n and @xml:id and @xml:lang]">
	  <xsl:call-template name="make_letter_records"/>
	</xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="make_letter_records">
    <xsl:element xmlns="http://www.tei-c.org/ns/1.0" name="bibl">
      <xsl:attribute name="xml:id">
	<xsl:value-of select="concat('bib',@xml:id)"/>
      </xsl:attribute>

      <location>
	
      </location>
      <date/>
      <respStmt>
	<resp>sender</resp>
	<name/>
      </respStmt>

      <respStmt>
	<resp>recipient</resp>
	<name/>
      </respStmt>
      
    </xsl:element>
    <xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="t:div[@n and @xml:id and @xml:lang]">
    <xsl:element xmlns="http://www.tei-c.org/ns/1.0"
		 name="div">
      <xsl:attribute name="decls">
	<xsl:value-of select="concat('bib',@xml:id)"/>
      </xsl:attribute>
      <xsl:apply-templates select="node()|@*" />
    </xsl:element>
  </xsl:template>


</xsl:transform>
