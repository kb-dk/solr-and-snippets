<?xml version="1.0" encoding="UTF-8" ?>
<!--

Author Sigfrid Lundberg slu@kb.dk

-->
<xsl:transform version="1.0"
	       xmlns:t="http://www.tei-c.org/ns/1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 

	       exclude-result-prefixes="t">

  <xsl:output omit-xml-declaration="yes"
	      encoding="UTF-8"
	      method="xml"/>



  <xsl:param 
      name="submixion" 
      select="''"/>
   
  <xsl:param 
      name="id"  
      select="''"/>

  <xsl:param 
      name="doc" 
      select="''"/>

  <xsl:param 
      name="hostname" 
      select="''"/>

  <xsl:param 
      name="file" 
      select="''"/>

  <xsl:param 
      name="status" 
      select="''"/>

 <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$id">
	<xsl:for-each select="//node()[$id=@xml:id]">
	  <div>
	    <xsl:attribute name="id">
	      <xsl:value-of select="concat('form',$id)"/>
	    </xsl:attribute>
	    <xsl:call-template name="formulate"/>
	  </div>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<div>No id given</div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="formulate">

    <form method="post" action="script_somewhere">
      <xsl:call-template name="mk_input">
	<xsl:with-param name="name">file</xsl:with-param>
	<xsl:with-param name="value">
	  <xsl:value-of select="$file"/>
	</xsl:with-param>
	<xsl:with-param name="type">hidden</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="mk_input">
	<xsl:with-param name="name">id</xsl:with-param>
	<xsl:with-param name="value">
	  <xsl:value-of select="@xml:id"/>
	</xsl:with-param>
	<xsl:with-param name="type">hidden</xsl:with-param>
      </xsl:call-template>

      <h3>Afsender</h3>
      <p>
	<xsl:for-each select="descendant::t:persName[@type='sender']">	
	  <xsl:call-template name="mk_field">
	    <xsl:with-param name="name">sender</xsl:with-param>
	    <xsl:with-param name="id_name">sender</xsl:with-param>
	  </xsl:call-template>
	</xsl:for-each>

	<xsl:call-template name="mk_input">
	  <xsl:with-param name="name">
	    <xsl:value-of 
		select="concat('sender',
			1 + count(descendant::t:persName[@type='sender']) )"/>
	  </xsl:with-param>
	</xsl:call-template>
      </p>

      <h3>Modtager</h3>
      <p>
	<xsl:for-each select="descendant::t:persName[@type='recipient']">
	  <xsl:call-template name="mk_field">
	    <xsl:with-param name="name">recipient</xsl:with-param>
	    <xsl:with-param name="id_name">recipient</xsl:with-param>
	  </xsl:call-template>
	</xsl:for-each>
	<xsl:text>
	</xsl:text>
	<xsl:call-template name="mk_input">
	  <xsl:with-param name="name">
	    <xsl:value-of 
		select="concat('recipient',
			1 + count(descendant::t:persName[@type='recipient']) )"/>
	  </xsl:with-param>
	</xsl:call-template>
      </p>
      <h3>Afsendelsessted</h3>
      <p>
	<xsl:for-each select="descendant::t:geogName">
	  <xsl:call-template name="mk_field">
	    <xsl:with-param name="name">place</xsl:with-param>
	    <xsl:with-param name="id_name">place</xsl:with-param>
	  </xsl:call-template>
	</xsl:for-each>
	<xsl:call-template name="mk_input">
	  <xsl:with-param name="name">
	    <xsl:value-of 
		select="concat('place',
			1 + count(descendant::t:geogName) )"/>
	  </xsl:with-param>
	</xsl:call-template>
      </p>
     
      <h3>Dato</h3>
      <p>
	<xsl:for-each select="descendant::t:date">
	  <xsl:call-template name="mk_field">
	    <xsl:with-param name="name">date</xsl:with-param>
	    <xsl:with-param name="id_name">date</xsl:with-param>
	  </xsl:call-template>
	</xsl:for-each>
      </p>
    </form>
  </xsl:template>

  <xsl:template name="mk_field">
    <xsl:param name="name"    select="''"/>
    <xsl:param name="id_name" select="''"/>

    <xsl:value-of select="."/>
    <xsl:text>
    </xsl:text>
    <br/>
    <xsl:call-template name="mk_input">
      <xsl:with-param name="name">
	<xsl:value-of select="concat($name,position())"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="mk_input">
      <xsl:with-param name="type">hidden</xsl:with-param>
      <xsl:with-param name="name">
	<xsl:value-of select="concat($id_name,position(),'-id')"/>
      </xsl:with-param>
      <xsl:with-param name="value">
	<xsl:value-of select="@xml:id"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="position() = last()">
      <br/>
      <xsl:text>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="mk_input">
    <xsl:param name="name" select="''"/>
    <xsl:param name="value" select="''"/>
    <xsl:param name="type" select="'text'"/>

    <xsl:element name="input">
      <xsl:attribute name="type">
	<xsl:value-of select="$type"/>
      </xsl:attribute>
      <xsl:attribute name="name">
	<xsl:value-of select="$name"/>
      </xsl:attribute>
      <xsl:attribute name="value">
	<xsl:value-of select="$value"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>


</xsl:transform>
