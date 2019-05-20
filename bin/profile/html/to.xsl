<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="tei html"
    version="2.0">
    <!-- import base conversion style -->
    <!--xsl:import href="../default/html/to.xsl"/-->
    <xsl:import href="../../Stylesheets/profiles/default/html/to.xsl"/>

    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet" type="stylesheet">
      <desc>

         <p>This software is dual-licensed:

1. Distributed under a Creative Commons Attribution-ShareAlike 3.0
Unported License http://creativecommons.org/licenses/by-sa/3.0/ 

2. http://www.opensource.org/licenses/BSD-2-Clause
		
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

This software is provided by the copyright holders and contributors
"as is" and any express or implied warranties, including, but not
limited to, the implied warranties of merchantability and fitness for
a particular purpose are disclaimed. In no event shall the copyright
holder or contributors be liable for any direct, indirect, incidental,
special, exemplary, or consequential damages (including, but not
limited to, procurement of substitute goods or services; loss of use,
data, or profits; or business interruption) however caused and on any
theory of liability, whether in contract, strict liability, or tort
(including negligence or otherwise) arising in any way out of the use
of this software, even if advised of the possibility of such damage.
</p>
<p>Author: et</p>
      </desc>
   </doc>

   <!-- Indent only for debugging! -->
   <xsl:output method="xhtml" indent="no" omit-xml-declaration="yes"/>
   <xsl:preserve-space elements="head p li span hi"/>

   <xsl:param name="cssFile">http://nl.ijs.si/tei/convert/profiles/jsi/html/jsi-tei.css</xsl:param>
   <xsl:param name="homeURL">https://github.com/clarin-eric/parla-clarin</xsl:param>
   <xsl:param name="homeLabel">Parla-CLARIN</xsl:param>
   <xsl:param name="STDOUT">true</xsl:param>
   <!--xsl:param name="STDOUT">false</xsl:param>
   <xsl:param name="outputDir">../docs</xsl:param>
   <xsl:param name="outputName">parla-clarin</xsl:param-->
   <xsl:param name="outputEncoding">utf-8</xsl:param>
   <xsl:param name="splitLevel">-1</xsl:param>
   <xsl:param name="autoToc">true</xsl:param>
   <xsl:param name="footnoteBackLink">true</xsl:param>
   <xsl:param name="numberFigures"/>

</xsl:stylesheet>
