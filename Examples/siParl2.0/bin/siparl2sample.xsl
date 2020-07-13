<?xml version="1.0"?>
<!-- Take corpus root file and retain only files given in the "files" parameter file
     Also mark the change in the teiHeader -->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" 
    xmlns:et="http://nl.ijs.si/et"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="fn xs et tei xi"
    version="2.0">

  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="tei:*"/>
  
  <xsl:param name="files"/>
  
  <xsl:param name="change">
    <change xml:lang="en" when="{$today-iso}">
      <name>Tomaž Erjavec</name>
      <xsl:text>: Make sample file.</xsl:text>
    </change>
  </xsl:param>

  <xsl:variable name="documents">
    <xsl:variable name="text" select="unparsed-text($files)"/>
    <documents>
      <xsl:for-each select="tokenize($text, '\n')">
	<document>
	  <xsl:attribute name="href" select="replace(., '.*/', '')"/>
	</document>
      </xsl:for-each>
    </documents>
  </xsl:variable>

  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:variable name="today-slv" select="format-date(current-date(), '[D1]. [M1]. [Y]')"/>

  <xsl:template match="tei:title[matches(., '\[siParl')]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="replace(
			    replace(., '\[siParl\]', '[siParl-sample]'),
			    '\[siParl-ana\]', '[siParl-ana-sample]')"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:attribute name="when" select="$today-iso"/>
      <xsl:value-of select="$today-slv"/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:extent"/>
  <xsl:template match="tei:tagsDecl"/>
  
  <xsl:template match="tei:teiHeader">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <xsl:if test="not(tei:revisionDesc)">
	<revisionDesc>
	  <xsl:copy-of select="$change"/>
	</revisionDesc>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="$change"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="xi:include">
    <xsl:variable name="href" select="replace(@href, '.*/', '')"/>
    <xsl:choose>
      <xsl:when test="$documents//tei:document[@href=$href]">
	<xsl:copy-of select="."/>
      </xsl:when>
      <xsl:otherwise>
	<!--xsl:comment>
	  <xsl:text>xi:include href="</xsl:text>
	  <xsl:value-of select="@href"/>
	  <xsl:text>"/</xsl:text>
	</xsl:comment-->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|comment()|processing-instruction()|text()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*|comment()">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
