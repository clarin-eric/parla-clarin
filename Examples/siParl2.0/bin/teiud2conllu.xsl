<?xml version='1.0' encoding='UTF-8'?>
<!-- Convert CLARIN.SI TEI format with UD morphology and possibly syntax to CONLL-U format -->
<!-- In case of normalised files, the "mode" parameter selects the choice/orig or choice/reg text stream -->
<!-- If @msd is not available in the chosen text stream, then @* are taken from the other one -->
<!-- This does not work for m-n mapping, where also the tokens are taken from the other one -->
<xsl:stylesheet version='2.0' 
  xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et"
  exclude-result-prefixes="fn tei et">

  <xsl:param name="mode">reg</xsl:param>
  
  <xsl:key name="id" match="tei:*" use="concat('#',@xml:id)"/>
  <xsl:key name="corresp" match="tei:*" use="substring-after(@corresp,'#')"/>

  <!-- TEI prefix replacement mechanism -->
  <xsl:variable name="prefixes" select="//tei:listPrefixDef"/>

  <!--xsl:output encoding="utf-8" method="xml" indent="yes"/-->
  <xsl:output encoding="utf-8" method="text"/>
  <xsl:strip-space elements="*"/>
  
  <xsl:template match="text()"/>
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="//tei:s//tei:choice">
	<xsl:variable name="normalised">
	  <xsl:apply-templates mode="prep" select="tei:*"/>
	</xsl:variable>
	<!--xsl:copy-of select="$normalised"/-->
	<xsl:apply-templates select="$normalised"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="prep" match="tei:*">
    <xsl:copy>
      <xsl:apply-templates mode="prep" select="@*"/>
      <xsl:apply-templates mode="prep"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="prep" match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template mode="prep" match="tei:choice">
    <xsl:choose>
      <xsl:when test="$mode = 'reg'">
	<xsl:choose>
	  <!-- Reg has @msd, just use it -->
	  <xsl:when test="tei:reg/tei:*[@msd]">
	    <xsl:apply-templates mode="prep" select="tei:reg/tei:*"/>
	  </xsl:when>
	  <!-- More than one token in reg or orig, have to use orig -->
	  <xsl:when test="tei:reg/tei:*[2] or tei:orig/tei:*[2]">
	    <xsl:message>
	      <xsl:text>Warn: using orig tokens for n-m mapping for </xsl:text>
	      <xsl:if test="@xml:id">
		<xsl:value-of select="@xml:id"/>
		<xsl:text>&#32;</xsl:text>
	      </xsl:if>
	      <xsl:value-of select="concat(tei:reg, ' // ', tei:orig)"/>
	    </xsl:message>
	    <xsl:apply-templates mode="prep" select="tei:orig/tei:*"/>
	  </xsl:when>
	  <!-- 1-1, use reg token, but orig attributes -->
	  <xsl:otherwise>
	    <xsl:call-template name="swap">
	      <xsl:with-param name="token" select="tei:reg/tei:*"/>
	      <xsl:with-param name="attributes" select="tei:orig/tei:*"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="$mode = 'orig'">
	<xsl:choose>
	  <!-- Orig has @msd, just use it -->
	  <xsl:when test="tei:orig/tei:*[@msd]">
	    <xsl:apply-templates mode="prep" select="tei:orig/tei:*"/>
	  </xsl:when>
	  <!-- More than one token in orig or reg, have to use reg -->
	  <xsl:when test="tei:orig/tei:*[2] or tei:reg/tei:*[2]">
	    <xsl:message>
	      <xsl:text>WARN: using reg tokens for n-m mapping for </xsl:text>
	      <xsl:if test="@xml:id">
		<xsl:value-of select="@xml:id"/>
		<xsl:text>&#32;</xsl:text>
	      </xsl:if>
	      <xsl:value-of select="concat(tei:orig, ' // ', tei:reg)"/>
	    </xsl:message>
	    <xsl:apply-templates mode="prep" select="tei:reg/tei:*"/>
	  </xsl:when>
	  <!-- 1-1, use orig token, but reg attributes -->
	  <xsl:otherwise>
	    <xsl:call-template name="swap">
	      <xsl:with-param name="token" select="tei:orig/tei:*"/>
	      <xsl:with-param name="attributes" select="tei:reg/tei:*"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes">
	  <xsl:text>Parameter "mode" must be "reg" or "orig"!</xsl:text>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="swap">
    <xsl:param name="token" select="tei:orig/tei:*"/>
    <xsl:param name="attributes" select="tei:reg/tei:*"/>
    <xsl:element name="{$token/name()}" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates mode="prep" select="$attributes/@*"/>
      <xsl:value-of select="$token"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:TEI">
    <xsl:value-of select="concat('# newdoc id = ', @xml:id, '&#10;')"/>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:seg">
    <xsl:value-of select="concat('# newpar id = ', @xml:id, '&#10;')"/>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:s">
    <xsl:value-of select="concat('# sent_id = ', @xml:id, '&#10;')"/>
    <xsl:variable name="text">
      <xsl:apply-templates mode="plain"/>
    </xsl:variable>
    <xsl:value-of select="concat('# text = ', normalize-space($text), '&#10;')"/>
    <xsl:apply-templates/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:gap">
  </xsl:template>
  
  <xsl:template mode="plain" match="text()"/>
  <xsl:template mode="plain" match="tei:*">
    <xsl:apply-templates mode="plain"/>
  </xsl:template>
  <xsl:template mode="plain" match="tei:c">
    <xsl:text>&#32;</xsl:text>
  </xsl:template>
  <xsl:template mode="plain" match="tei:w | tei:pc">
    <xsl:value-of select="."/>
    <xsl:if test="not(@join = 'right' or @join='both' or
		  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'left' or
		  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'both')">
      <xsl:text>&#32;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:c"/>
  <xsl:template match="tei:w | tei:pc">
    <!-- 1/ID -->
    <xsl:text></xsl:text>
    <xsl:apply-templates mode="number" select="."/>
    <xsl:text>&#9;</xsl:text>
    <!-- 2/FORM -->
    <xsl:if test="contains(text(),' ')">
      <xsl:message>
	<xsl:value-of select="concat('ERROR: tokens contains space: ', text())"/>
      </xsl:message>
    </xsl:if>
    <xsl:value-of select="text()"/>
    <xsl:text>&#9;</xsl:text>
    <!-- 3/LEMMA -->
    <xsl:choose>
      <xsl:when test="self::tei:pc">
	<xsl:value-of select="text()"/>
      </xsl:when>
      <xsl:when test="not(@lemma)">
	<xsl:message terminate="yes">
	  <xsl:value-of select="concat('ERROR: no lemma for token: ', text())"/>
	</xsl:message>
      </xsl:when>
      <xsl:when test="contains(@lemma,' ')">
	<xsl:message terminate="yes">
	  <xsl:value-of select="concat('ERROR: lemma contains space: ', @lemma)"/>
	</xsl:message>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="@lemma"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- e.g. ana="mte:Xf" msd="UposTag=X|Foreign=Yes" -->
    <xsl:text>&#9;</xsl:text>
    <!-- 4/CPOSTAG -->
    <xsl:choose>
      <xsl:when test="not(@msd)">
	<xsl:message terminate="no">
	  <xsl:value-of select="concat('ERROR: no UPOS (@msd) for token: ', text())"/>
	</xsl:message>
	<xsl:text>???</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="catfeat" select="replace(@msd, '\|.+', '')"/>
	<xsl:value-of select="replace($catfeat, 'UposTag=', '')"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 5/XPOS -->
    <xsl:choose>
      <xsl:when test="not(@ana)">
	<xsl:message terminate="no">
	  <xsl:value-of select="concat('ERROR: no msd for token: ', text())"/>
	</xsl:message>
	<xsl:text>???</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(@ana, '#')">
	<xsl:value-of select="substring-after(@ana, '#')"/>
      </xsl:when>
      <xsl:when test="contains(@ana, ':')">
	<xsl:value-of select="substring-after(@ana, ':')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="@ana"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 6/FEATS -->
    <xsl:variable name="feats" select="replace(@msd, 'UposTag=[^|]+\|?', '')"/>
    <xsl:choose>
      <xsl:when test="normalize-space($feats)">
	<!-- In TEI : was changed to _ so it doesn't clash with value prefixes -->
	<xsl:value-of select="replace($feats, '_', ':')"/>
      </xsl:when>
      <xsl:otherwise>_</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 7/HEAD -->
    <xsl:variable name="Syntax"
		  select="key('corresp',ancestor::tei:s[1]/@xml:id)[@type='UD-SYN']"/>
    <xsl:choose>
      <xsl:when test="$Syntax//tei:link">
	<xsl:call-template name="head">
	  <xsl:with-param name="links" select="$Syntax"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>-1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 8/DEPREL -->
    <xsl:choose>
      <xsl:when test="$Syntax//tei:link">
	<xsl:call-template name="rel">
	  <xsl:with-param name="links" select="$Syntax"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 9/DEPS -->
    <xsl:text>_</xsl:text>
    <xsl:text>&#9;</xsl:text>
    <!-- 10/MISC -->
    <xsl:choose>
      <!--xsl:when test="not(
		      following::tei:*[1][self::tei:c] or
		      (not(following::tei:*[self::tei:w or self::tei:pc])
		      and
		      (../following::tei:*[1][self::tei:c] or
		      not(../following-sibling::tei:*))
		      ))">
	<xsl:text>SpaceAfter=No</xsl:text>
      </xsl:when-->
      <xsl:when test="@join = 'right' or @join='both' or
		  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'left' or
		  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'both'">
	<xsl:text>SpaceAfter=No</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>_</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- Return the number of the head token -->
  <xsl:template name="head">
    <xsl:param name="links"/>
    <xsl:param name="id" select="@xml:id"/>
    <xsl:variable name="link" select="$links//tei:link[fn:matches(@target,concat(' #',$id,'$'))]"/>
    <xsl:variable name="head_id" select="substring-before($link/@target,' ')"/>
    <xsl:choose>
      <xsl:when test="key('id',$head_id)/name()= 's'">0</xsl:when>
      <xsl:when test="key('id',$head_id)[name()='pc' or name()='w']">
	<xsl:apply-templates mode="number" select="key('id',$head_id)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes">
	  <xsl:value-of select="concat('ERROR: in link cant find head ', $head_id, ' for id ', $id)"/>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="number" match="tei:*">
    <xsl:if test="not(self::tei:pc or self::tei:w)">
      <xsl:message terminate="yes">
	<xsl:value-of select="concat('ERROR: sequence number for non-token: ', text())"/>
      </xsl:message>
    </xsl:if>
    <!-- Ignore origs! -->
    <xsl:number count="tei:w[not(parent::tei:orig)] | tei:pc[not(parent::tei:orig)]"
 		level="any" from="tei:s"/>
  </xsl:template>

  <!-- Return the name of the syntactic relation -->
  <xsl:template name="rel">
    <xsl:param name="links"/>
    <xsl:param name="id" select="@xml:id"/>
    <xsl:variable name="link" select="$links//tei:link[fn:matches(@target,concat(' #',$id,'$'))]"/>
    <!-- In TEI : was changed to _ so it doesn't clash with value prefixes -->
    <xsl:value-of select="replace(
			  substring-after($link/@ana, ':'),
			  '_', ':')"/>
    <!-- This is the proper was to do it, but we simplify for siParl as above -->
    <!--xsl:variable name="ana" select="et:prefix-replace($link/@ana, $prefixes)"/>
    <xsl:value-of select="substring-after($link/$ana,'#')"/-->
  </xsl:template>

  <xsl:function name="et:prefix-replace">
    <xsl:param name="val"/>
    <xsl:param name="prefixes"/>
    <xsl:choose>
      <xsl:when test="contains($val, ':')">
	<xsl:variable name="prefix" select="substring-before($val, ':')"/>
	<xsl:variable name="val-in" select="substring-after($val, ':')"/>
	<xsl:variable name="match" select="$prefixes//tei:prefixDef[@ident = $prefix]/@matchPattern"/>
	<xsl:variable name="replace" select="$prefixes//tei:prefixDef[@ident = $prefix]/@replacementPattern"/>
	<xsl:choose>
	  <xsl:when test="not(normalize-space($replace))">
	    <xsl:message terminate="yes">
	      <xsl:value-of select="concat('Couldnt find replacement pattern in listPrefixDef for ', $val)"/>
	    </xsl:message>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="fn:replace($val-in, $match, $replace)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$val"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
