<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mads="http://www.loc.gov/mads/v2"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:bf="http://bibframe.org/vocab/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:relators="http://id.loc.gov/vocabulary/relators/"
    xmlns:mix="http://www.loc.gov/mix/v10"
    xmlns:t="http://www.tei-c.org/ns/1.0" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    exclude-result-prefixes="rdf xsl mods rdfs bf mads t mix relators"
    xmlns="http://www.loc.gov/mods/v3"
    version="1.0">

  <xsl:output method="xml"
	      encoding="UTF-8"
	      indent="yes"/>
  

  <xsl:template match="/rdf:RDF">
    <xsl:apply-templates select="bf:Instance"/>
  </xsl:template>

  <xsl:template match="bf:Instance">
    <mods 
	version="3.5"
	xsi:schemaLocation="http://www.loc.gov/mods/v3
			    http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
      <xsl:comment>We have found an instance!</xsl:comment>

      <xsl:if test="bf:instanceOf/@rdf:resource">
	<xsl:apply-templates 
	    select="document(concat(bf:instanceOf/@rdf:resource,'.rdf'))/rdf:RDF/bf:Work"/>
      </xsl:if>

      <xsl:apply-templates select="bf:publication"/>

      <xsl:if test="bf:extent|bf:dimensions">
	<physicalDescription>
	  <xsl:for-each select="bf:extent|bf:dimensions">
	    <xsl:apply-templates select="."/>
	  </xsl:for-each>
	</physicalDescription>
      </xsl:if>

      <xsl:apply-templates select="bf:isbn|bf:isbn10|bf:isbn13"/>

      <xsl:call-template name="encode_identifiers"/>
      <identifier>
	<xsl:attribute name="type">uri</xsl:attribute>
	<xsl:value-of select="@rdf:about"/>
      </identifier>
    </mods>
  </xsl:template>

  <xsl:template match="bf:Work">

    <xsl:for-each select="relators:*">
      <name>
	<xsl:attribute name="authorityURI">
	  <xsl:value-of select="@rdf:resource"/>
	</xsl:attribute>
	<xsl:if test="@rdf:resource">
	  <xsl:apply-templates 
	      select="document(@rdf:resource)/mads:mads/mads:authority[1]"/>
	</xsl:if>
	<role>
	  <roleTerm>
	    <xsl:value-of select="local-name(.)"/>
	  </roleTerm>
	</role>
      </name>
    </xsl:for-each>

    <xsl:apply-templates select="bf:title"/>

    <xsl:apply-templates select="bf:language"/>

    <xsl:if test="bf:identifier[bf:Identifier/bf:identifierValue]">
      <xsl:element name="relatedItem">
	<xsl:attribute name="type">references</xsl:attribute>
	<xsl:attribute name="displayLabel">Work</xsl:attribute>
	<xsl:call-template name="encode_identifiers"/>        
      </xsl:element>
    </xsl:if>

  </xsl:template>

  <!--
      These are mainly related to Instance
  -->

  <xsl:template match="bf:publication">
    <originInfo>
      <xsl:apply-templates select="bf:Provider"/>
      <xsl:apply-templates select="../bf:modeOfIssuance"/>
    </originInfo>
  </xsl:template>

  <xsl:template match="bf:Provider">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="bf:providerPlace">
    <place>
      <placeTerm>
	<xsl:copy-of select="@xml:lang"/>
	<xsl:apply-templates/>
      </placeTerm>
    </place>
  </xsl:template>

  <xsl:template match="bf:providerDate|bf:copyrightDate">
    <dateCreated encoding="w3cdtf">
      <xsl:apply-templates/>
    </dateCreated>
  </xsl:template>
  
  <xsl:template match="bf:providerName">
    <publisher>
      <xsl:copy-of select="@xml:lang"/>
      <xsl:apply-templates select="bf:Organization"/>
    </publisher>
  </xsl:template>

  <xsl:template match="bf:modeOfIssuance">
    <issuance>
      <xsl:copy-of select="@xml:lang"/>
      <xsl:apply-templates/>
    </issuance>
  </xsl:template>

  <xsl:template match="bf:extent">
    <extent>
      <xsl:copy-of select="@xml:lang"/>
      <xsl:apply-templates/>
    </extent>
  </xsl:template>

  <xsl:template match="bf:dimensions">
    <extent type="dimensions">
      <xsl:apply-templates/>
    </extent>
  </xsl:template>

  <xsl:template match="bf:titleStatement"></xsl:template>

  <xsl:template match="bf:isbn|bf:isbn10|bf:isbn13">
    <identifier type="isbn">
      <xsl:apply-templates select="bf:Identifier/bf:label"/>
    </identifier>
  </xsl:template>

  <!--
      These are related to Work
  -->

  <xsl:template match="bf:title">
    <titleInfo>
      <xsl:if test="bf:Title/bf:titleType">
	<xsl:attribute name="type">
	  <xsl:value-of select="bf:Title/bf:titleType"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="bf:Title"/>
    </titleInfo>
  </xsl:template>

  <xsl:template match="bf:Title">
    <xsl:apply-templates select="bf:titleValue"/>
    <xsl:apply-templates select="bf:subtitle"/>
  </xsl:template>

  <xsl:template match="bf:titleValue">
    <title>
      <xsl:copy-of select="@xml:lang"/>
      <xsl:apply-templates/>
    </title>
  </xsl:template>

  <xsl:template match="bf:subtitle">
    <subTitle>
      <xsl:copy-of select="@xml:lang"/>
      <xsl:apply-templates/>
    </subTitle>
  </xsl:template>

  <xsl:template match="bf:language">
    <xsl:for-each select="bf:Language">
      <language>
	<xsl:attribute name="objectPart">
	  <xsl:value-of select="bf:resourcePart"/>
	</xsl:attribute>
	<languageTerm><xsl:apply-templates select="bf:label"/></languageTerm>
      </language>
    </xsl:for-each>
  </xsl:template>


  <!-- 
       Other stuff
  -->
  
  <xsl:template name="encode_identifiers">
    <xsl:for-each select="bf:identifier[bf:Identifier/bf:identifierValue]">
      <identifier>
	<xsl:if test="bf:Identifier/bf:identifierScheme">
	  <xsl:attribute name="type">
	    <xsl:value-of select="bf:Identifier/bf:identifierScheme"/>
	  </xsl:attribute>
	</xsl:if>
	<xsl:apply-templates select="bf:Identifier/bf:identifierValue"/>
      </identifier>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <!--
      Mads
  -->

  <xsl:template match="mads:authority">
    <xsl:attribute name="type">
      <xsl:value-of select="mads:name/@type"/>
    </xsl:attribute>
    <xsl:for-each select="mads:name">
      <xsl:for-each select="mads:namePart">
	<namePart>
	  <xsl:copy-of select="@*"/>
	  <xsl:apply-templates/>
	</namePart>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

</xsl:transform>
