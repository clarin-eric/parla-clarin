<?xml version="1.1" encoding="utf-8"?>
<xsl:stylesheet 
    xmlns:htm="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" 
    xmlns:et="http://nl.ijs.si/et"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="htm fn et tei"
    version="2.0">
  <xsl:output method="text"/>
  <xsl:template match="text()"/>
  <xsl:template match="/">
    <xsl:apply-templates select="//tei:u"/>
  </xsl:template>
  <xsl:template match="tei:u">
    <xsl:apply-templates select="tei:seg"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="tei:seg">
    <xsl:variable name="seg">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($seg)"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="tei:gap">
    <xsl:if test="not(preceding-sibling::tei:*[1]/self::tei:gap)">
      <xsl:text> ⋯ </xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:w | tei:pc">
    <xsl:value-of select="."/>
    <xsl:if test="not(@join='right' or @join='both' or
		  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'left' or
		  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'both')">
      <xsl:text>&#32;</xsl:text>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
