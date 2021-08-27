<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:t="http://www.tei-c.org/ns/1.0"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               exclude-result-prefixes="xsl t"
               version="2.0">

  <xsl:output method="xml"
              omit-xml-declaration="yes"
              encoding="UTF-8"/>

  <xsl:param name="file_name" select="''"/>
  
  <xsl:template match="/">
    <table>

      <xsl:variable name="doc" select="."/>

      <xsl:variable name="structures" as="xs:string *">
        <xsl:for-each select="$doc//tr">
          <xsl:value-of select="td[4]/string()"/>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="table">
        <xsl:for-each select="distinct-values($structures)">
          <xsl:variable name="my_val" select="."/>
          <xsl:variable name="my_count" select="count($doc//tr[td[4] = $my_val])"/>

          <tr>
            <td>
              <xsl:value-of select="$my_val"/>
            </td>
            <td>               
              <xsl:value-of select="$my_count"/>
            </td>
          </tr>
        </xsl:for-each>
      </xsl:variable>

      <xsl:for-each select="$table/tr">
        <xsl:sort select="td[2]" data-type="number" order="descending"  />
        <xsl:copy-of select="."/>
      </xsl:for-each>
      
    </table>
  </xsl:template>
</xsl:transform>
