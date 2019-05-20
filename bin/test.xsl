<?xml version="1.0"?>
<!-- doc-available.xsl -->
<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:text>&#xA;Tests of the doc-available() function:&#xA;</xsl:text>

    <xsl:text>&#xA;  doc-available('https://www.tei-c.org/Vault/P5/current/xml/tei/odd/p5subset.xml') = </xsl:text>
    <xsl:value-of select="doc-available('https://www.tei-c.org/Vault/P5/current/xml/tei/odd/p5subset.xml')"/>

    <xsl:text>&#xA;&#xA;  doc-available('http://www.functx.com/input/order.xml') = </xsl:text>
    <xsl:value-of select="doc-available('http://www.functx.com/input/order.xml')"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
