<?xml version="1.0"?>
<!-- Transform one file (session) siParl Parla-CLARIN TEI encoded corpus
     to CQP vertical format (which is still XML though, and needs another polish) -->
<!-- Needs the file with corpus teiHeader as a parameter -->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" 
    xmlns:et="http://nl.ijs.si/et"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="fn et tei xs xi"
    version="2.0">

  <xsl:output method="xml" encoding="utf-8" indent="no" omit-xml-declaration="yes"/>
  
  <xsl:key name="id" match="tei:*" use="@xml:id"/>

  <!-- File with corpus teiHeader for information about taxonomies, person, parties -->
  <xsl:param name="tei"/>

  <!-- Prefix to DL of the parliament proceedings -->
  <xsl:param name="exist-prefix">http://exist.sistory.si/exist/apps/parla/</xsl:param>

  <!-- Separator for multi-valued attributes -->
  <xsl:param name="multi-separator">|</xsl:param>

  <!-- Key which directly finds local references -->
  <xsl:key name="idr" match="tei:*" use="concat('#', @xml:id)"/>

  <xsl:variable name="teiHeader" select="document($tei)"/>

  <!-- Date of the sesssoin as a global variable -->
  <xsl:variable name="session-date"
		select="//tei:teiHeader/tei:profileDesc/tei:settingDesc//tei:date/@when"/>

  <xsl:template match="@*"/>
  <xsl:template match="text()"/>

  <xsl:template match="tei:teiCorpus">
    <xsl:apply-templates select="tei:TEI[tei:text[@xml:lang='sl']]"/>
  </xsl:template>

  <xsl:template match="tei:TEI">
    <session id="{@xml:id}">
      <xsl:attribute name="year" select="substring-before($session-date, '-')"/>
      <xsl:attribute name="month" select="fn:replace($session-date, '-..$', '')"/>
      <xsl:attribute name="date" select="$session-date"/>
      
      <!-- Looks like (so "main" titles are always the same, ignore):
	  <titleStmt>
            <title type="main" xml:lang="sl">Dobesedni zapis seje delovnih teles Državnega zbora Republike Slovenije [siParl-ana]</title>
            <title type="main" xml:lang="en">Verbatim record of the session of the working bodies of the National Assembly of the Republic of Slovenia [siParl-ana]</title>
            <title type="sub" xml:lang="sl">Komisija za evropske zadeve: 61. redna seja (15. 12. 1999)</title>
            <title type="sub" xml:lang="sl">Odbor za mednarodne odnose: 113. redna seja (15. 12. 1999)</title>
      -->
      <xsl:attribute name="title">
	<xsl:variable name="titles">
	  <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/
				tei:title[@xml:lang='sl' and @type='sub']">
	    <xsl:value-of select="concat(normalize-space(.), $multi-separator)"/>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="et:trim($titles)"/>
      </xsl:attribute>

      <!-- Reference to mandate, looks like this:
	   <meeting n="2" corresp="#DZ" ana="#parl.term #DZ.2">2. mandat</meeting>
	   in corpus teiHeader:
	   <org xml:id="DZ" role="parliament" ana="#parl.national #par.lower">
	   <orgName xml:lang="sl">Državni zbor Republike Slovenije</orgName>
	   <orgName xml:lang="en">National Assembly of the Republic of Slovenia</orgName>
	   ...
	   <event xml:id="DZ.1" from="1992-12-23" to="1996-11-27">
  	     <label xml:lang="sl">1. mandat</label>
	     <label xml:lang="en">Term 1</label>
	   </event>
      -->
      <xsl:variable name="mandate-ref"
		    select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:meeting
			    [key('idr', substring-before(@ana, ' '), $teiHeader)/
			    contains(tei:catDesc[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang='en'],
			    'Legislative period')]/
			    substring-after(@ana, ' ')"/>
      <xsl:attribute name="mandate"
		     select="et:format-mandate(key('idr', $mandate-ref, $teiHeader), 'sl')"/>
      <xsl:attribute name="mandate_en"
		     select="et:format-mandate(key('idr', $mandate-ref, $teiHeader), 'en')"/>

      <!-- Reference to organisation and type of meeting, looks like this:
           <meeting n="61" corresp="#KZEZ" ana="#parl.meeting.regular">Redna</meeting>
           <meeting n="113" corresp="#OZMO" ana="#parl.meeting.regular">Redna</meeting>
	   <meeting n="2" corresp="#DZ" ana="#parl.term #DZ.2">2. mandat</meeting>
	   in corpus teiHeader (missing English!):
	   <org xml:id="KZEZ" ana="#parl.committee">
             <orgName>Komisija za evropske zadeve</orgName>
           </org>
      -->
      <xsl:attribute name="organ">
	<xsl:variable name="organs">
	  <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:meeting/
				key('idr', @corresp, $teiHeader)/tei:orgName
				[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='sl']]">
	    <xsl:value-of select="concat(normalize-space(.), $multi-separator)"/>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="et:trim($organs)"/>
      </xsl:attribute>
      <xsl:attribute name="type">
	<xsl:variable name="types">
	  <xsl:for-each select="distinct-values(
				tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:meeting/
				key('idr', @ana, $teiHeader)/self::tei:category/
				tei:catDesc[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='sl']]
				)">
	    <xsl:value-of select="concat(normalize-space(.), $multi-separator)"/>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="et:trim($types)"/>
      </xsl:attribute>
      <xsl:attribute name="type_en">
	<xsl:variable name="types">
	  <xsl:for-each select="distinct-values(
				tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:meeting/
				key('idr', @ana, $teiHeader)/self::tei:category/
				tei:catDesc[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang='en']
				)">
	    <xsl:value-of select="concat(normalize-space(.), $multi-separator)"/>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="et:trim($types)"/>
      </xsl:attribute>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates select="tei:text/tei:body//tei:u"/>
    </session>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:u">
    <xsl:variable name="segs">
      <xsl:apply-templates select=".//tei:seg"/>
    </xsl:variable>
    <!-- Only output if not empty -->
    <xsl:if test="normalize-space($segs)">
      <speech>
	<xsl:variable name="speaker" select="key('idr', @who, $teiHeader)"/>
	<xsl:attribute name="who" select="$speaker/@xml:id"/>
	<xsl:attribute name="name" select="et:format-name($speaker//tei:persName[1])"/>
	<!--xsl:attribute name="gender" select="$speaker/tei:sex/@value"/-->
	<!-- Fix errors in source (M M, m) -->
	<xsl:attribute name="gender">
	  <xsl:choose>
	    <xsl:when test="$speaker/tei:sex">
	      <xsl:value-of select="upper-case($speaker/tei:sex[1]/@value)"/>
	    </xsl:when>
	    <!-- 'unknown' does not have sex -->
	    <xsl:otherwise>-</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
	<xsl:attribute name="birth">
	  <xsl:choose>
	    <xsl:when test="$speaker/tei:birth">
	      <!-- Return year only -->
	      <xsl:value-of select="replace($speaker/tei:birth/@when, '(-\d\d)+$', '')"/>
	    </xsl:when>
	    <xsl:otherwise>-</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
	<!-- Neokusno?
	<xsl:attribute name="death">
	  <xsl:choose>
	    <xsl:when test="$speaker/tei:death">
	      <xsl:value-of select="substring-before($speaker/tei:death/@when, '-')"/>
	    </xsl:when>
	    <xsl:otherwise>-</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute-->
	<xsl:attribute name="type">
	  <xsl:choose>
	    <xsl:when test="key('idr', @ana, $teiHeader)/
			    contains(tei:catDesc[@xml:lang='en'],
			    'Chairperson')">predsedujoči</xsl:when>
	    <xsl:otherwise>redni govornik</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
	<xsl:attribute name="type_en">
	  <xsl:choose>
	    <xsl:when test="key('idr', @ana, $teiHeader)/
			    contains(tei:catDesc[@xml:lang='en'],
			    'Chairperson')">Chairperson</xsl:when>
	    <xsl:otherwise>Regular speaker</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
	<xsl:attribute name="role"       select="et:speaker-role($speaker, 'sl')"/>
	<xsl:attribute name="role_en"    select="et:speaker-role($speaker, 'en')"/>
	<xsl:attribute name="party_init" select="et:speaker-party($speaker, 'init', 'sl')"/>
	<xsl:attribute name="party"      select="et:speaker-party($speaker, 'yes',  'sl')"/>
	<xsl:attribute name="party_en"   select="et:speaker-party($speaker, 'yes',  'en')"/>
	<xsl:text>&#10;</xsl:text>
	<xsl:copy-of select="$segs"/>
      </speech>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:seg">
    <xsl:if test=".//tei:w or .//tei:pc">
      <p id="{@xml:id}">
	<xsl:attribute name="dl" select="et:id2dl(@xml:id)"/>
	<xsl:text>&#10;</xsl:text>
	<xsl:apply-templates/>
      </p>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:name">
    <xsl:copy>
      <xsl:copy-of select="@type"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:s">
    <xsl:choose>
      <xsl:when test="tei:w or tei:pc">
	<xsl:copy>
	  <xsl:text>&#10;</xsl:text>
	  <xsl:apply-templates/>
	</xsl:copy>
	<xsl:text>&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="tei:gap">
	<xsl:apply-templates/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:gap">
    <xsl:if test="not(preceding-sibling::tei:*[1]/self::tei:gap)">
      <xsl:copy/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <!-- TOKENS -->
  <xsl:template match="tei:c"/>
  <xsl:template match="tei:pc | tei:w">
    <xsl:value-of select="concat(.,'&#9;',et:output-annotations(.))"/>
    <xsl:call-template name="deps"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test="@join = 'right' or @join='both' or
		  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'left' or
		  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'both'">
      <g/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="deps">
    <xsl:param name="type">UD-SYN</xsl:param>
    <xsl:variable name="id" select="@xml:id"/>
    
    <xsl:variable name="s" select="ancestor::tei:s"/>
    <xsl:choose>
      <xsl:when test="$s/tei:linkGrp[@type=$type]">
	<xsl:variable name="link"
		      select="$s/tei:linkGrp[@type=$type]/tei:link
			      [fn:ends-with(@target,concat(' #',$id))]"/>
	<xsl:value-of select="concat('&#9;', substring-after($link/@ana,'syn:'))"/>
	<xsl:variable name="target" select="key('id', fn:replace($link/@target,'#(.+?) #.*','$1'))"/>
	<xsl:choose>
	  <xsl:when test="$target/self::tei:s">
	    <xsl:text>&#9;-&#9;-&#9;-&#9;-&#9;-</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="concat('&#9;', et:output-annotations($target))"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>&#9;-&#9;-&#9;-&#9;-&#9;-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="et:output-annotations">
    <xsl:param name="token"/>
    <xsl:variable name="n" select="replace($token/@xml:id, '.+\.(t\d+)$', '$1')"/>
    <xsl:variable name="msd" select="substring-after($token/@ana,'mte:')"/>
    <xsl:variable name="lemma">
      <xsl:choose>
	<xsl:when test="$token/@lemma">
	  <xsl:value-of select="$token/@lemma"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="substring($token,1,1)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ud-pos" select="replace(replace($token/@msd, 'UposTag=', ''), '\|.+', '')"/>
    <xsl:variable name="ud-feats">
      <xsl:variable name="fs" select="replace($token/@msd, 'UposTag=[^|]+\|?', '')"/>
      <xsl:choose>
	<xsl:when test="normalize-space($fs)">
	  <xsl:value-of select="replace($fs, '\|', ' ')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>-</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="concat($lemma, '&#9;', $msd, '&#9;',
			  $ud-pos, '&#9;', $ud-feats, '&#9;', $n)"/>
  </xsl:function>

  <!-- Convert seg/@xml:id to URL of DARIAH-SI digital library -->
  <xsl:function name="et:id2dl">
    <!-- DL looks like:
	 http://exist.sistory.si/exist/apps/parla/
	 OZFIMP-Nujna-056-2004-03-01
	 .xml?id=
	 SDT3-OZFIMP-Nujna-056-2004-03-01.seg136
	 &odd=parla.odd&view=div#
	 SDT3-OZFIMP-Nujna-056-2004-03-01.seg136
    -->
    <xsl:param name="id"/>
    <xsl:value-of select="$exist-prefix"/>
    <xsl:value-of select="substring-before(substring-after($id, '-'), '.seg')"/>
    <xsl:text>.xml?id=</xsl:text>
    <xsl:value-of select="$id"/>
    <xsl:text>&amp;odd=parla.odd&amp;view=div#</xsl:text>
    <xsl:value-of select="$id"/>
  </xsl:function>
  
  <!-- Mandate looks like this in corpus teiHeader:
       <event xml:id="DZ.1" from="1992-12-23" to="1996-11-27">
         <label xml:lang="sl">1. mandat</label>
         <label xml:lang="en">Term 1</label>
       </event>
  -->
  <xsl:function name="et:format-mandate">
    <xsl:param name="mandate-event" as="element(tei:event)"/>
    <xsl:param name="lang" as="xs:string"/>
    <xsl:value-of select="$mandate-event/
			  tei:label[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang = $lang]]"/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="concat($mandate-event/@from, ' - ', $mandate-event/@to)"/>
    <xsl:text>)</xsl:text>
  </xsl:function>

  <!-- Format the name of a person from persName -->
  <xsl:function name="et:format-name">
    <xsl:param name="persName"/>
    <xsl:choose>
      <xsl:when test="$persName/tei:surname[2] and $persName/tei:forename">
	<xsl:value-of select="concat($persName/tei:surname[1], ' ',
			      $persName/tei:surname[2], ', ',
			      $persName/tei:forename[1])"/>
      </xsl:when>
      <xsl:when test="$persName/tei:surname and $persName/tei:forename">
	<xsl:value-of select="normalize-space(
			      concat($persName/tei:surname[1], ', ',
			      $persName/tei:forename[1]))"/>
      </xsl:when>
      <xsl:when test="$persName/tei:surname">
	<xsl:value-of select="normalize-space($persName/tei:surname[1])"/>
      </xsl:when>
      <xsl:when test="normalize-space($persName)">
	<xsl:value-of select="$persName"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output if the speaker is an MP or merely a 'visitor'
       when speaking (= global $session-date) -->
  <xsl:function name="et:speaker-role" as="xs:string">
     <!-- The element of the speaker -->
    <xsl:param name="speaker" as="element(tei:person)"/>
     <!-- Role in which language -->
     <xsl:param name="lang" as="xs:string"/>
     <xsl:variable name="role"
		   select="$speaker/tei:affiliation[@role='MP']
			   [et:between-dates($session-date, @from, @to)]/@role"/>
     <xsl:if test="$role[2]">
       <xsl:message>
	 <xsl:text>ERROR: doubled MP role for </xsl:text>
	 <xsl:value-of select="$speaker/@xml:id"/>
	 <xsl:text> on </xsl:text>
	 <xsl:value-of select="$session-date"/>
       </xsl:message>
     </xsl:if>
     <xsl:choose>
       <xsl:when test="$lang = 'sl' and normalize-space($role[1])">član parlamenta</xsl:when>
       <xsl:when test="$lang = 'en' and normalize-space($role[1])">MP</xsl:when>
       <xsl:when test="$lang = 'sl'">zunanji govornik</xsl:when>
       <xsl:when test="$lang = 'en'">External speaker</xsl:when>
       <xsl:otherwise>
	 <xsl:message>
	   <xsl:text>ERROR: bad language for speaker role: </xsl:text>
	   <xsl:value-of select="$lang"/>
	 </xsl:message>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:function>
  
  <!-- Output the name of the party (in global $teiHeader)
       the speaker belongs to when speaking (= global $session-date) -->
  <xsl:function name="et:speaker-party" as="xs:string">
     <!-- The element of the speaker -->
    <xsl:param name="speaker" as="element(tei:person)"/>
     <!-- Full ('yes') or abbreviated ('init') name of the party -->
    <xsl:param name="full" as="xs:string"/>
     <!-- Party name in which language -->
    <xsl:param name="lang" as="xs:string"/>
    <xsl:variable name="parties">
      <xsl:variable name="tmp">
	<!-- Should be actually just one for a given date! -->
	<xsl:for-each select="$speaker/tei:affiliation[@role='member']">
	  <xsl:if test="et:between-dates($session-date, @from, @to)">
	    <xsl:variable name="party"
			  select="key('idr', @ref, $teiHeader)"/>
	    <xsl:if test="$party/tei:orgName[@full=$full]
			  [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang=$lang]">
	      <xsl:value-of select="$party/tei:orgName[@full=$full]
				    [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang=$lang]"/>
	    </xsl:if>
	    <xsl:value-of select="$multi-separator"/>
	  </xsl:if>
	</xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="et:trim($tmp)"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="matches($parties, concat('\', $multi-separator))">
	<xsl:message>
	  <xsl:text>ERROR: more than one party for </xsl:text>
	  <xsl:value-of select="$speaker/@xml:id"/>
	  <xsl:text> on </xsl:text>
	  <xsl:value-of select="$session-date"/>
	</xsl:message>
	<xsl:value-of select="replace($parties, concat('\', $multi-separator, '.+'), '')"/>
      </xsl:when>
      <!-- Speaker belongs to parties, just none when he is speaking -->
      <xsl:when test="not(normalize-space($parties)) and $speaker/tei:affiliation[@role='member']">
	<xsl:message>
	  <xsl:text>WARN: belongs to parties but not for </xsl:text>
	  <xsl:value-of select="$speaker/@xml:id"/>
	  <xsl:text> on </xsl:text>
	  <xsl:value-of select="$session-date"/>
	</xsl:message>
	<xsl:text>-</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space($parties)">
	<xsl:value-of select="$parties"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Is the first date between the following two? -->
  <xsl:function name="et:between-dates" as="xs:boolean">
    <xsl:param name="date" as="xs:string"/>
    <xsl:param name="from" as="xs:string"/>
    <xsl:param name="to" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="xs:date(et:fix-date($date)) &gt;= xs:date(et:fix-date($from)) and
	              xs:date(et:fix-date($date)) &lt;= xs:date(et:fix-date($to))">
	<xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Fix too short dates a la "2018-02" -->
  <xsl:function name="et:fix-date">
    <xsl:param name="date"/>
    <xsl:choose>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d-\d\d$')">
	<xsl:value-of select="$date"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d$')">
	<xsl:message>
	  <xsl:text>WARN: short date </xsl:text>
	  <xsl:value-of select="$date"/>
	</xsl:message>
	<xsl:value-of select="concat($date, '-01')"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d$')">
	<xsl:message>
	  <xsl:text>WARN: short date </xsl:text>
	  <xsl:value-of select="$date"/>
	</xsl:message>
	<xsl:value-of select="concat($date, '-01-01')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes">
	  <xsl:text>ERROR: bad date </xsl:text>
	  <xsl:value-of select="$date"/>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Get rid of final multi-separator -->
  <xsl:function name="et:trim">
    <xsl:param name="val"/>
    <xsl:value-of select="normalize-space(
			  fn:replace($val,
			  concat('\', $multi-separator, '$'), '')
			  )"/>
  </xsl:function>
</xsl:stylesheet>
