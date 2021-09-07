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
    <xsl:text>
    </xsl:text>
    <table>
      <xsl:for-each select="//t:div[t:lg and @decls]">
        <xsl:if test="count(.//t:lg/t:l)=14">
          <xsl:text>
          </xsl:text>
          <xsl:element name="tr">
            <th><xsl:value-of select="$file_name"/></th>
            <td><xsl:value-of select="normalize-space(t:head)"/></td>
            <td><xsl:value-of select="@xml:id"/></td>
            <td><xsl:value-of select="@decls"/></td>
            <td>
              <xsl:variable name="lines_per_strophe" as="xs:integer *">
                <xsl:for-each select=".//t:lg[t:l]">
                  <xsl:value-of select="count(t:l)"/>
                </xsl:for-each>
              </xsl:variable>
              <xsl:value-of select="$lines_per_strophe"/>
            </td>
            <td>
              <xsl:variable name="vowel_numbers" as="xs:integer *">
                <xsl:for-each select=".//t:lg/t:l">
                  <xsl:variable name="vowels"><xsl:value-of select="replace(.,'[^iyeæøauoå]','')"/></xsl:variable>
                  <xsl:value-of select="string-length($vowels)"/>
                </xsl:for-each>
              </xsl:variable>
              <xsl:value-of select="format-number(sum($vowel_numbers) div 14, '#.####')"/>
            </td>
          </xsl:element>
          <xsl:text>
          </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </table>
    <xsl:text>
    </xsl:text>
  </xsl:template>

</xsl:transform>
