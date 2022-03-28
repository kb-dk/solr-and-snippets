<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:my="urn:things"
    exclude-result-prefixes="t my fn"
    version="2.0">

  <xsl:param name="coll" select="''"/>
  <xsl:variable name="txtfile" select="concat($coll,'/',fn:replace($doc,'com.xml','txt.xml'))"/>
  <xsl:variable name="txtdoc" select="document($txtfile)"/>


  <xsl:param name="use_marker" select="'no'"/>
  

  <xsl:variable name="witnesses">
    <xsl:copy-of select="/t:TEI//t:sourceDesc/t:listWit/*"/>
  </xsl:variable>

  <xsl:variable name="grenditions">
    <xsl:copy-of select="/t:TEI//t:tagsDecl/*"/>
  </xsl:variable>

  <xsl:template mode="text" match="t:corr">
    <span title="rættelse">
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template mode="apparatus" match="t:corr">
    <span title="rættelse">
      <xsl:call-template name="add_id"/>
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">before</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
      <xsl:if test="@wit">
	<xsl:call-template name="witness">
	  <xsl:with-param name="wit" select="@wit"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="@resp">
	<xsl:text>
	</xsl:text>
	<xsl:call-template name="witness">
	  <xsl:with-param name="wit" select="@resp"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="@evidence">
	[<xsl:value-of select="@evidence"/>]
      </xsl:if>
    </span>
  </xsl:template>


  <xsl:template match="t:add">
    <span title="tillæg">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="t:del">
    <del title="sletning">
      <xsl:call-template name="render_stuff"/>
      <xsl:apply-templates/>
    </del>
  </xsl:template>

  <xsl:template mode="apparatus" match="t:lem/t:add">
    <span title="{local-name(.)}">
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">before</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates  mode="apparatus"/><xsl:text>] </xsl:text>
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">after</xsl:with-param>
      </xsl:call-template>
    </span>
  </xsl:template>

  <xsl:template mode="apparatus" match="t:lem/t:del">
    <span title="{local-name(.)}">
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">before</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates  mode="apparatus"/>
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">after</xsl:with-param>
      </xsl:call-template>
    </span>
  </xsl:template>


  
  <xsl:template match="t:supplied"><span title="Supplering"><xsl:call-template name="add_id"/>[<xsl:apply-templates/>]</span></xsl:template>
  <xsl:template match="t:unclear"><span title="unclear"><xsl:call-template name="add_id"/><xsl:apply-templates/></span></xsl:template>
  <xsl:template mode="apparatus" match="t:unclear"><span title="unclear">&lt;<xsl:apply-templates/>&gt;</span></xsl:template>

  <xsl:template match="t:choice[t:reg and t:orig]">
    <span>
      <xsl:attribute name="title">
	oprindelig: <xsl:value-of select="t:orig"/>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:reg"/>
    </span>
  </xsl:template>

  <xsl:template match="t:choice[t:abbr and t:expan]">
    <xsl:element name="span"><!-- used to be a -->
      <xsl:attribute name="title">
	<xsl:for-each select="t:expan">
	<xsl:value-of select="."/><xsl:if test="position() &lt; last()">; </xsl:if>
	</xsl:for-each>
      </xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:apply-templates select="t:abbr"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:ref[@type='commentary']">
    <xsl:element name="a">
      <xsl:call-template name="add_id"/>
      <xsl:attribute name="title">Kommentar</xsl:attribute>
      <xsl:attribute name="class">comment</xsl:attribute>
      <xsl:if test="@target">
	<xsl:attribute name="href">
	  <xsl:call-template name="make-href"/>
	</xsl:attribute>
      </xsl:if>
      <span class="symbol comment"><span class="debug comment-stuff">&#9658;</span></span> <!-- xsl:text>&#160;</xsl:text --> <span>
        <xsl:attribute name="title">Kommentar</xsl:attribute>
        <xsl:apply-templates/>
      </span>
      <xsl:comment> moved the content till after the anchor </xsl:comment>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:seg[@type='com']">
    <xsl:element name="a">
      <xsl:attribute name="title">Kommentar</xsl:attribute>
      <xsl:attribute name="class">comment</xsl:attribute>
      <xsl:choose>
        <xsl:when test="@n">
	  <xsl:attribute name="href">
	    <xsl:call-template name="make-href"/>
	  </xsl:attribute>
	  <xsl:attribute name="id"><xsl:value-of select="@n"/></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
	  <xsl:call-template name="add_id"/>
        </xsl:otherwise>
        </xsl:choose><span class="symbol comment"><span class="debug comment-stuff">&#9658;</span></span><span>
        <xsl:attribute name="title">Kommentar</xsl:attribute><xsl:comment> where are we? </xsl:comment>
        <xsl:apply-templates/>
      </span>
    </xsl:element>    
  </xsl:template>

  <xsl:template match="t:note">
    <xsl:choose>
      <!-- this is GV -->
      <xsl:when test="ancestor::t:text[@type='com']">
	<xsl:element name="p">
	  <xsl:call-template name="add_id"/>
	  <xsl:call-template name="gv-lemma">
	    <xsl:with-param name="xid">
	      <xsl:value-of select="@xml:id"/>
	    </xsl:with-param>
	  </xsl:call-template>
	  <xsl:apply-templates mode="note_body" select="t:p"/>
	</xsl:element>
      </xsl:when>
      <!-- this is SKS -->
      <xsl:when test="@type='commentary'">
	<xsl:element name="p">
	  <xsl:call-template name="add_id"/>
	  <xsl:apply-templates select="t:label"/><xsl:text>: </xsl:text><xsl:apply-templates mode="note_body" select="t:p"/>
	</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="inline_note"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="gv-lemma">
    <xsl:param name="xid"/>
    <!-- one to many relation (sometimes one to too many) here -->
    <!-- Obviously I started something here, but I have no idea what it was about...
    <xsl:text>: </xsl:text>
    <xsl:element name="a">
      <xsl:attribute name="href">
	<xsl:value-of select="concat('/text/',fn:replace($path,'^(.*)(-com-)(.*)$','$1-txt-$3'),'#',$xid)"/>
      </xsl:attribute>
      <xsl:if test="$txtdoc">
	<xsl:value-of select="$txtdoc//t:seg[@n=$xid][1]"/>
      </xsl:if>
    </xsl:element>
    -->
  </xsl:template>

  <xsl:template mode="note_body" match="t:p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="add_id_empty_elem">
    <xsl:if test="@xml:id">
      <xsl:attribute name="id">
	<xsl:value-of select="@xml:id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:call-template name="render_stuff"/>
  </xsl:template>

  <xsl:template name="render_before_after">
    <xsl:param name="scope" select="'before'"/>
    <xsl:param name="rendit" select="./@rendition"/>
    <xsl:if test="$rendit">
      <xsl:for-each select="fn:tokenize($rendit,'\s+')">
	<xsl:variable name="rend" select="substring-after(.,'#')"/> 
	<xsl:for-each select="$grenditions/t:rendition[@xml:id = $rend][@scope=$scope]"><em><xsl:value-of select="fn:replace(.,'^.*&quot;(.*?)&quot;.*$','$1')"/></em></xsl:for-each>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render_stuff">
    <xsl:if test="contains(@rendition,'#')">
      <xsl:variable name="rend" select="substring-after(@rendition,'#')"/>  
      <xsl:choose>
	<xsl:when test="$rend = 'capiTyp'"><xsl:attribute name="style">font-variant: small-caps;</xsl:attribute></xsl:when>
	<xsl:when test="$rend = 'spa'"><xsl:attribute name="style">font-style: italic;</xsl:attribute></xsl:when>
	<xsl:when test="/t:TEI//t:rendition[@scheme='css'][@xml:id = $rend]">
	  <xsl:attribute name="style">
	    <xsl:value-of select="/t:TEI//t:rendition[@scheme='css'][@xml:id = $rend]"/>
	  </xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="class">
	    <xsl:value-of select="substring-after(@rendition,'#')"/> 
	  </xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- xsl:template match="t:milestone">
    <xsl:call-template name="witness">
      <xsl:with-param name="wit" select="@edRef"/>
    </xsl:call-template>
    <xsl:value-of select="@n"/>
    <xsl:text> 
    </xsl:text>
  </xsl:template -->

  <xsl:template  mode="apparatus" match="t:witStart">
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">before</xsl:with-param>
      </xsl:call-template>
  </xsl:template>

  <xsl:template  mode="apparatus" match="t:witEnd">
    <xsl:call-template name="render_before_after">
      <xsl:with-param name="scope">after</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="t:witDetail">
    <!-- em>
      <xsl:comment> detail </xsl:comment>
      <xsl:apply-templates/>
    </em -->
  </xsl:template>

  <xsl:template mode="apparatus" match="t:witDetail">
    <xsl:variable name="witness"><xsl:value-of select="normalize-space(substring-after(@wit,'#'))"/></xsl:variable>
    <xsl:call-template name="render_before_after">
      <xsl:with-param name="scope">before</xsl:with-param>
    </xsl:call-template>
    <xsl:element name="span">
      <xsl:attribute name="title">
	<xsl:value-of select="/t:TEI//t:listWit/t:witness[@xml:id=$witness]"/>
      </xsl:attribute>
      <em><xsl:apply-templates/> <xsl:comment> witness detail </xsl:comment></em>
      <xsl:value-of select="@n"/>
    </xsl:element>
    <xsl:call-template name="render_before_after">
      <xsl:with-param name="scope">after</xsl:with-param>
    </xsl:call-template>
    <xsl:text>
    </xsl:text>
  </xsl:template>


  <xsl:template mode="text" match="t:lem">
    <xsl:param name="data_anchor" select="''"/>
    <xsl:element name="span">
      <xsl:call-template name="add_id"/>
      <xsl:if test="$data_anchor">
        <xsl:attribute name="data-anchor"><xsl:value-of select="$data_anchor"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template mode="apparatus" match="t:lem">
    <xsl:element name="span">
      <xsl:call-template name="add_id"/>
      <xsl:choose>
        <xsl:when test="t:add">
          <xsl:apply-templates mode="apparatus" select="t:add"/>
          <xsl:call-template name="render_before_after">
	    <xsl:with-param name="scope">before</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="apparatus"/><xsl:text>] </xsl:text>
          <xsl:call-template name="render_before_after">
	    <xsl:with-param name="scope">before</xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="lemmabody"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="lemmabody">
    <xsl:choose>
      <xsl:when test="@wit">
	<xsl:call-template name="witness"/>
      </xsl:when>
      <xsl:when test="@resp">
	<xsl:call-template name="witness">
	  <xsl:with-param name="wit" select="@resp"/>
	</xsl:call-template>
      </xsl:when>
    </xsl:choose>
    <xsl:call-template name="render_before_after">
      <xsl:with-param name="scope">after</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="t:rdgGrp"> 
    <xsl:element name="span">
      <xsl:call-template name="add_id"/>
      <xsl:if test="@rendition = '#semiko'">; </xsl:if><xsl:apply-templates/><xsl:comment> rdg grp </xsl:comment>
    </xsl:element>
  </xsl:template>

  <xsl:template match="t:app">
    <xsl:call-template name="app-root"/>
  </xsl:template>
  
  <xsl:template name="app-root">

    <xsl:variable name="idstring">
      <xsl:value-of select="translate(@xml:id,'-;.','___')"/>
    </xsl:variable>
    <xsl:variable name="note">
      <xsl:value-of select="concat('apparatus',$idstring)"/>
    </xsl:variable>
    
    <xsl:element name="a">
      <xsl:attribute
          name="id"><xsl:value-of select="concat('appanchor',@xml:id)"/></xsl:attribute>
      <xsl:attribute name="class">info</xsl:attribute>
      <xsl:attribute name="title">Tekstkritik</xsl:attribute>
      <xsl:attribute name="onclick"><xsl:value-of select="$note"/>();</xsl:attribute>
      <xsl:attribute name="data-target">#info_modal</xsl:attribute>
      <xsl:attribute name="data-anchor"><xsl:value-of select="@xml:id"/></xsl:attribute>
      
      <span>
        <xsl:call-template name="apparatus-marker">
          <xsl:with-param name="marker">&#9432;</xsl:with-param>
        </xsl:call-template>
      </span>

      <xsl:apply-templates mode="text" select="t:lem">
        <xsl:with-param name="data_anchor"><xsl:value-of select="@xml:id"/></xsl:with-param>
      </xsl:apply-templates>
      
      <span class="apparatus-criticus"
            style="background-color:Aquamarine;display:none;">
        <xsl:call-template name="add_id"/>
        <xsl:apply-templates mode="apparatus" select="t:lem"/><xsl:if test="t:rdg|t:rdgGrp|t:corr|t:note">,
      </xsl:if>
      <xsl:text>
      </xsl:text>
      <xsl:for-each select="t:rdg|t:rdgGrp|t:corr|t:note">
	<xsl:apply-templates mode="apparatus"  select="."/><xsl:if test="position() &lt; last()">;
        </xsl:if><xsl:comment> <xsl:value-of select="local-name(.)"/> </xsl:comment>
        </xsl:for-each><xsl:comment> <xsl:text> </xsl:text> app </xsl:comment>
      </span>
    </xsl:element>

  </xsl:template>

  <xsl:template mode="apparatus" match="t:note">
    <xsl:element name="span">
      <xsl:call-template name="render_before_after">
        <xsl:with-param name="scope">before</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
      <xsl:call-template name="render_before_after">
        <xsl:with-param name="scope">after</xsl:with-param>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <xsl:template name="apparatus-marker">
    <xsl:param name="marker" select="'&#9432;'"/>

    <xsl:variable name="idstring">
      <xsl:value-of select="translate(@xml:id,'-;.','___')"/>
    </xsl:variable>
    <xsl:variable name="note">
      <xsl:value-of select="concat('apparatus',$idstring)"/>
    </xsl:variable>
    <xsl:attribute name="style">text-indent: 0;</xsl:attribute>
    <xsl:attribute name="class">symbol info</xsl:attribute>
    <xsl:attribute name="data-anchor"><xsl:value-of select="@xml:id"/></xsl:attribute>
    <span class="debug info-stuff"><xsl:value-of select="$marker"/></span>
    <script>
      var <xsl:value-of select="concat('disp',$idstring)"/>="none";
      function <xsl:value-of select="$note"/>() {
      var ele = document.getElementById("<xsl:value-of select="@xml:id"/>");
      if(<xsl:value-of select="concat('disp',$idstring)"/>=="none") {
      ele.style.display="inline";
      <xsl:value-of select="concat('disp',$idstring)"/>="inline";
      } else {
      ele.style.display="none";
      <xsl:value-of select="concat('disp',$idstring)"/>="none";
      }
      }
    </script>
  
  </xsl:template>

  <xsl:template match="t:sic">
    <xsl:apply-templates/> [<em>sic!</em>]
  </xsl:template>

  <xsl:template mode="apparatus"  match="t:sic">
     <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">before</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">after</xsl:with-param>
      </xsl:call-template>
  </xsl:template>


  <xsl:template  mode="apparatus"  match="t:rdg">
    <xsl:call-template name="render_before_after">
      <xsl:with-param name="scope">before</xsl:with-param>
    </xsl:call-template>
    <xsl:element name="span">
      <xsl:apply-templates  mode="apparatus" />
      <xsl:if test="@wit">
	<xsl:call-template name="witness"/>
      </xsl:if>
      <xsl:if test="@resp">
	<xsl:call-template name="witness">
	  <xsl:with-param name="wit" select="@resp"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="@evidence">
	[<xsl:value-of select="@evidence"/>]
      </xsl:if>
      <xsl:call-template name="render_before_after">
	<xsl:with-param name="scope">after</xsl:with-param>
      </xsl:call-template>
      <xsl:comment> rdg </xsl:comment>
    </xsl:element>
  </xsl:template>

  <xsl:template  mode="text"  match="t:rdg">
    <xsl:element name="span">
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <xsl:template name="witness">
    <xsl:param name="wit" select="@wit"/>
    <xsl:comment> Witness <xsl:value-of select="$wit"/> </xsl:comment>

      <xsl:for-each select="fn:tokenize($wit,'\s+')">
	<xsl:variable name="witness"><xsl:choose><xsl:when test="contains(.,'#')"><xsl:value-of select="normalize-space(substring-after(.,'#'))"/></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:variable>
        <xsl:text> </xsl:text>
        <xsl:choose>
	<xsl:when test="$witnesses//t:witness[@xml:id=$witness]">
	  <xsl:element name="em">
	    <xsl:attribute name="class">witness</xsl:attribute>
	    <xsl:attribute name="title">
	      <xsl:value-of select="$witnesses//t:witness[@xml:id=$witness]"/>
	    </xsl:attribute>
	    <xsl:value-of select="normalize-space($witness)"/></xsl:element><xsl:choose><xsl:when test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:when></xsl:choose><xsl:comment> witness </xsl:comment></xsl:when>
        <xsl:otherwise><xsl:element name="em"><xsl:value-of select="$witness"/></xsl:element></xsl:otherwise></xsl:choose>
      </xsl:for-each>

  </xsl:template>


</xsl:stylesheet>
