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
    <json type="object">
      <xsl:choose>
	<xsl:when test="$id">
	  <xsl:for-each select="//node()[$id=@xml:id]">
	    <xsl:call-template name="formulate"/>
	  </xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
	  <pair name="error" type="string">No id given</pair>
	</xsl:otherwise>
      </xsl:choose>
    </json>
  </xsl:template>

  <xsl:template name="de_hash">
    <xsl:param name="string" select="''"/>
    <xsl:choose>
      <xsl:when test="contains($string,'#')">
	<xsl:value-of select="substring-after($string,'#')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="formulate">

    <xsl:variable name="bibl_id">
      <xsl:call-template name="de_hash">
	<xsl:with-param name="string" select="@decls"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="letter_id">
      <xsl:value-of select="@xml:id"/>
    </xsl:variable>

    <xsl:call-template name="mk_input">
      <xsl:with-param name="name">file</xsl:with-param>
      <xsl:with-param name="value">
	<xsl:value-of select="$file"/>
      </xsl:with-param>
      <xsl:with-param name="type">string</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="mk_input">
      <xsl:with-param name="name">xml_id</xsl:with-param>
      <xsl:with-param name="value">
	<xsl:value-of select="@xml:id"/>
      </xsl:with-param>
      <xsl:with-param name="type">string</xsl:with-param>
    </xsl:call-template>

    <xsl:variable name="all_the_same">
      <xsl:for-each
	  select="/t:TEI/descendant::node()[@xml:id=$letter_id]/descendant::t:persName/@sameAs">
	<xsl:value-of select="."/>
      </xsl:for-each>
    </xsl:variable>

    <pair name="sender" type="array">
      <xsl:if test="descendant::t:persName[@type='sender']">	
	<xsl:for-each select="descendant::t:persName[@type='sender']">	
	  <xsl:call-template name="extract_text_agent">
	    <xsl:with-param name="bibl_id" select="$bibl_id"/>
	    <xsl:with-param name="agent" select="'sender'"/>
	  </xsl:call-template>
	</xsl:for-each>
      </xsl:if>
      <xsl:for-each select="/t:TEI">
	<xsl:for-each select="descendant::t:bibl[@xml:id=$bibl_id]">
	  <xsl:for-each select="t:respStmt[t:resp='sender']">
	    <xsl:for-each select="t:name">
	      <xsl:choose>
		<xsl:when
		    test="contains($all_the_same,@xml:id)">
		</xsl:when>
		<xsl:otherwise>
		  <xsl:call-template name="extract_bibl_agent">
		    <xsl:with-param name="bibl_id" select="$bibl_id"/>
		    <xsl:with-param name="agent" select="'sender'"/>
		  </xsl:call-template>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:for-each>
	  </xsl:for-each>
	</xsl:for-each>
      </xsl:for-each>
    </pair>

    <pair name="recipient" type="array">
      <xsl:if test="descendant::t:persName[@type='recipient']">	
	<xsl:for-each select="descendant::t:persName[@type='recipient']">
	  <xsl:call-template name="extract_text_agent">
	    <xsl:with-param name="bibl_id" select="$bibl_id"/>
	    <xsl:with-param name="agent" select="'recipient'"/>
	  </xsl:call-template>
	</xsl:for-each>
      </xsl:if>
      <xsl:for-each select="/t:TEI">
	<xsl:for-each select="descendant::t:bibl[@xml:id=$bibl_id]">
	  <xsl:for-each select="t:respStmt[t:resp='recipient']">
	    <xsl:for-each select="t:name">
	      <xsl:choose>
		<xsl:when
		    test="contains($all_the_same,@xml:id)">
		</xsl:when>
		<xsl:otherwise>
		  <xsl:call-template name="extract_bibl_agent">
		    <xsl:with-param name="bibl_id" select="$bibl_id"/>
		    <xsl:with-param name="agent" select="'recipient'"/>
		  </xsl:call-template>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:for-each>
	  </xsl:for-each>
	</xsl:for-each>
      </xsl:for-each>
    </pair>

    <pair name="place" type="array">
      <xsl:if test="descendant::t:geogName">	
	<xsl:for-each select="descendant::t:geogName">
	  <xsl:call-template name="extract_text_place">
	    <xsl:with-param name="bibl_id" select="$bibl_id"/>
	  </xsl:call-template>
	</xsl:for-each>
      </xsl:if>
      <xsl:for-each select="/t:TEI">
	<xsl:for-each select="descendant::t:bibl[@xml:id=$bibl_id]">
	  <xsl:for-each select="t:location">
	    <xsl:choose>
	      <xsl:when
		  test="contains(//node()[@xml:id=$letter_id]/descendant::t:geogName/@sameAs,@xml:id)">
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:call-template name="extract_bibl_place">
		  <xsl:with-param name="bibl_id" select="$bibl_id"/>
		</xsl:call-template>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:for-each>
	</xsl:for-each>
      </xsl:for-each>
    </pair>
    
    <pair name="date" type="object">
      <xsl:for-each select="descendant::t:date[1]">
	<xsl:call-template name="mk_input">
	  <xsl:with-param name="name">text</xsl:with-param>
	  <xsl:with-param name="value">
	    <xsl:value-of select="."/>
	  </xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name="mk_input">
	  <xsl:with-param name="name">xml_id</xsl:with-param>
	  <xsl:with-param name="value">
	    <xsl:value-of select="@xml:id"/>
	  </xsl:with-param>
	  <xsl:with-param name="type">pair</xsl:with-param>
	</xsl:call-template>
      </xsl:for-each>
      <xsl:variable name="same_as">
	<xsl:for-each select="descendant::t:date[1]">
	  <xsl:value-of select="@sameAs"/>
	</xsl:for-each>
      </xsl:variable>
      <xsl:for-each select="/t:TEI">
	<xsl:for-each select="descendant::t:bibl[@xml:id=$bibl_id]">
	  <xsl:for-each select="t:date">
	    <xsl:call-template name="mk_input">
	      <xsl:with-param name="name">edtf</xsl:with-param>
	      <xsl:with-param name="value">
		<xsl:value-of select="."/>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:for-each>
	</xsl:for-each>
      </xsl:for-each>
    </pair>

  </xsl:template>

  <xsl:template name="extract_bibl_agent">
    <xsl:param name="letter_id" select="''"/>
    <xsl:param name="agent" select="''"/>
    
    <item type="object"> 
      <xsl:for-each select="t:surname">
	<xsl:call-template name="mk_input">
	  <xsl:with-param name="name">family_name</xsl:with-param>
	  <xsl:with-param name="value">
	    <xsl:value-of select="."/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="t:forename">
	<xsl:call-template name="mk_input">
	  <xsl:with-param name="name">given_name</xsl:with-param>
	  <xsl:with-param name="value">
	    <xsl:value-of select="."/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="@ref">
	<xsl:call-template name="mk_input">
	  <xsl:with-param name="name">auth_id</xsl:with-param>
	  <xsl:with-param name="value">
	    <xsl:value-of select="."/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:for-each>
    </item>
  </xsl:template>

  <xsl:template name="extract_text_agent">
    <xsl:param name="bibl_id" select="''"/>
    <xsl:param name="agent" select="''"/>

    <item type="object"> 
      <xsl:call-template name="mk_input">
	<xsl:with-param name="name">text</xsl:with-param>
	<xsl:with-param name="value">
	  <xsl:value-of select="."/>
	</xsl:with-param>
      </xsl:call-template>

      <xsl:call-template name="mk_input">
	<xsl:with-param name="name">xml_id</xsl:with-param>
	<xsl:with-param name="value">
	  <xsl:value-of select="@xml:id"/>
	</xsl:with-param>
      </xsl:call-template> 

      <xsl:variable name="same_as">
	<xsl:call-template name="de_hash">
	  <xsl:with-param name="string" select="@sameAs"/>
	</xsl:call-template>
      </xsl:variable>

      <xsl:for-each select="//t:respStmt/t:name[@xml:id = $same_as]">
	<xsl:for-each select="t:surname">
	  <xsl:call-template name="mk_input">
	    <xsl:with-param name="name">family_name</xsl:with-param>
	    <xsl:with-param name="value">
	      <xsl:value-of select="."/>
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:for-each>
	<xsl:for-each select="t:forename">
	  <xsl:call-template name="mk_input">
	    <xsl:with-param name="name">given_name</xsl:with-param>
	    <xsl:with-param name="value">
	      <xsl:value-of select="."/>
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:for-each>
	<xsl:call-template name="mk_input">
	  <xsl:with-param name="name">auth_id</xsl:with-param>
	  <xsl:with-param name="value">
	    <xsl:value-of select="@ref"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:for-each>
    </item>
  </xsl:template>

  <xsl:template name="extract_bibl_place">
    <xsl:param name="bibl_id" select="''"/>

    <item type="object"> 
      <xsl:call-template name="mk_input">
	<xsl:with-param name="name">type</xsl:with-param>
	<xsl:with-param name="value">
	  <xsl:value-of select="@type"/>
	</xsl:with-param>
      </xsl:call-template>
      <xsl:for-each select="t:placeName">
	<xsl:call-template name="mk_input">
	  <xsl:with-param name="name">name</xsl:with-param>
	  <xsl:with-param name="value">
	    <xsl:value-of select="."/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:for-each>
    </item>
  </xsl:template>

  <xsl:template name="extract_text_place">
    <xsl:param name="bibl_id" select="''"/>
    <xsl:param name="agent" select="''"/>

    <item type="object"> 
      <xsl:call-template name="mk_input">
	<xsl:with-param name="name">text</xsl:with-param>
	<xsl:with-param name="value">
	  <xsl:value-of select="."/>
	</xsl:with-param>
      </xsl:call-template>

      <xsl:call-template name="mk_input">
	<xsl:with-param name="name">xml_id</xsl:with-param>
	<xsl:with-param name="value">
	  <xsl:value-of select="@xml:id"/>
	</xsl:with-param>
      </xsl:call-template> 

      <xsl:variable name="same_as">
	<xsl:call-template name="de_hash">
	  <xsl:with-param name="string" select="@sameAs"/>
	</xsl:call-template>
      </xsl:variable>

      <xsl:for-each select="//t:location[@xml:id = $same_as]">
	<xsl:call-template name="mk_input">
	  <xsl:with-param name="name">type</xsl:with-param>
	  <xsl:with-param name="value">
	    <xsl:value-of select="@type"/>
	  </xsl:with-param>
	</xsl:call-template>
	<xsl:for-each select="t:placeName">
	  <xsl:call-template name="mk_input">
	    <xsl:with-param name="name">name</xsl:with-param>
	    <xsl:with-param name="value">
	      <xsl:value-of select="."/>
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:for-each>
      </xsl:for-each>
    </item>
  </xsl:template>

  <xsl:template name="mk_field">
    <xsl:param name="name"    select="''"/>

    <xsl:element name="item">
      <xsl:attribute name="type">object</xsl:attribute>
      <xsl:call-template name="mk_input">
	<xsl:with-param name="name">
	  <xsl:value-of select="$name"/>
	</xsl:with-param>
	<xsl:with-param name="value">
	  <xsl:value-of select="."/>
	</xsl:with-param>
	<xsl:with-param name="type">pair</xsl:with-param>
      </xsl:call-template>

      <xsl:call-template name="mk_input">
	<xsl:with-param name="name" select="'xml_id'"/>
	<xsl:with-param name="value">
	  <xsl:value-of select="@xml:id"/>
	</xsl:with-param>
	<xsl:with-param name="type">pair</xsl:with-param>
      </xsl:call-template>
    </xsl:element>

  </xsl:template>

  <xsl:template name="mk_input">
    <xsl:param name="name" select="''"/>
    <xsl:param name="value" select="''"/>
    <xsl:param name="type" select="'pair'"/>

    <xsl:element name="pair">
      <xsl:attribute name="type">
	<xsl:value-of select="$type"/>
      </xsl:attribute>
      <xsl:attribute name="name">
	<xsl:value-of select="$name"/>
      </xsl:attribute>
      <xsl:value-of select="$value"/>
    </xsl:element>
  </xsl:template>


</xsl:transform>
