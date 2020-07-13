<?xml version="1.0"?>
<!-- Transform one file (session) siParl Parla-CLARIN TEI encoded corpus
     to TSV metadata, either session or utterance -->
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

  <xsl:output method="text"/>
  
  <xsl:key name="id" match="tei:*" use="@xml:id"/>

  <!-- Which metadata to output: 'sessions' or 'speeches' -->
  <xsl:param name="what">sessions</xsl:param>

  <!-- File with corpus teiHeader for information about taxonomies, person, parties -->
  <xsl:param name="tei"/>

  <!-- Separator for multi-valued attributes -->
  <xsl:param name="multi-separator">|</xsl:param>

  <!-- Key which directly finds local references -->
  <xsl:key name="idr" match="tei:*" use="concat('#', @xml:id)"/>

  <xsl:variable name="teiHeader" select="document($tei)"/>

  <!-- Date of the sesssion as a global variable -->
  <xsl:variable name="session-date"
		select="//tei:teiHeader/tei:profileDesc/tei:settingDesc//tei:date/@when"/>

  <xsl:template match="@*"/>
  <xsl:template match="text()"/>

  <xsl:template match="tei:teiCorpus">
    <xsl:apply-templates select="tei:TEI[tei:text[@xml:lang='sl']]"/>
  </xsl:template>

  <xsl:template match="tei:TEI">
    <xsl:choose>
      <xsl:when test="$what = 'sessions'">
	<xsl:call-template name="session"/>
      </xsl:when>
      <xsl:when test="$what = 'speeches'">
	<xsl:apply-templates select=".//tei:u"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:u">
    <xsl:variable name="speaker" select="key('idr', @who, $teiHeader)"/>
    <!-- Utterance ID -->
    <xsl:value-of select="@xml:id"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Speaker ID -->
    <xsl:value-of select="$speaker/@xml:id"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Speaker name -->
    <xsl:value-of select="et:format-name($speaker//tei:persName[1])"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Speaker sex -->
    <xsl:choose>
      <xsl:when test="$speaker/tei:sex">
	<xsl:value-of select="upper-case($speaker/tei:sex[1]/@value)"/>
      </xsl:when>
      <!-- 'unknown' does not have sex -->
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Speaker birth date -->
    <xsl:choose>
      <xsl:when test="$speaker/tei:birth">
	<xsl:value-of select="$speaker/tei:birth/@when"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Speaker death date -->
    <xsl:choose>
      <xsl:when test="$speaker/tei:death">
	<xsl:value-of select="$speaker/tei:death/@when"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Speaker type slv -->
    <xsl:choose>
      <xsl:when test="key('idr', @ana, $teiHeader)/
		      contains(tei:catDesc[@xml:lang='en'],
		      'Chairperson')">predsedujoči</xsl:when>
      <xsl:otherwise>redni govornik</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Speaker type eng -->
    <xsl:choose>
      <xsl:when test="key('idr', @ana, $teiHeader)/
		      contains(tei:catDesc[@xml:lang='en'],
		      'Chairperson')">Chairperson</xsl:when>
      <xsl:otherwise>Regular speaker</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Speaker role slv -->
    <xsl:value-of select="et:speaker-role($speaker, 'sl')"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Speaker role eng -->
    <xsl:value-of select="et:speaker-role($speaker, 'en')"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Speaker party initials -->
    <xsl:value-of select="et:speaker-party($speaker, 'init', 'sl')"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Speaker party name slv -->
    <xsl:value-of select="et:speaker-party($speaker, 'yes',  'sl')"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Speaker party name eng -->
    <xsl:value-of select="et:speaker-party($speaker, 'yes',  'en')"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Number of notes in utterance -->
    <xsl:value-of select="count(.//tei:note)"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Number of gaps in utterance -->
    <xsl:value-of select="count(.//tei:gap)"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Number of names in utterance -->
    <xsl:value-of select="count(.//tei:name)"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Number of segments in utterance -->
    <xsl:value-of select="count(.//tei:seg)"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Number of sentences in utterance -->
    <xsl:value-of select="count(.//tei:s)"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Number of words in utterance -->
    <xsl:value-of select="count(.//tei:w)"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Number of tokens in utterance -->
    <xsl:value-of select="count(.//tei:w) + count(.//tei:pc)"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template name="session">
    <!-- Session ID -->
    <xsl:value-of select="@xml:id"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Session date -->
    <xsl:value-of select="$session-date"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Session title(s) (in subtitle(s)) -->
    <xsl:variable name="titles">
      <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/
			    tei:title[@xml:lang='sl' and @type='sub']">
	<xsl:value-of select="concat(normalize-space(.), $multi-separator)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="et:trim($titles)"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Session mandate slv -->
    <xsl:variable name="mandate-ref"
		  select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:meeting
			  [key('idr', substring-before(@ana, ' '), $teiHeader)/
			  contains(tei:catDesc[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang='en'],
			  'Legislative period')]/
			  substring-after(@ana, ' ')"/>
    <xsl:value-of select="et:format-mandate(key('idr', $mandate-ref, $teiHeader), 'sl')"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Session mandate eng -->
    <xsl:value-of select="et:format-mandate(key('idr', $mandate-ref, $teiHeader), 'en')"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Session organisation(s) -->
    <xsl:variable name="organs">
      <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:meeting/
			    key('idr', @corresp, $teiHeader)/tei:orgName
			    [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='sl']]">
	<xsl:value-of select="concat(normalize-space(.), $multi-separator)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="et:trim($organs)"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Session type(s) slv -->
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
    <xsl:text>&#9;</xsl:text>
    <!-- Session type(s) eng -->
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
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:function name="et:format-mandate">
    <xsl:param name="mandate-event" as="element(tei:event)"/>
    <xsl:param name="lang" as="xs:string"/>
    <xsl:value-of select="$mandate-event/
			  tei:label[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang = $lang]]"/>
    <!-- Could also put start and end dates:
    <xsl:text> (</xsl:text>
    <xsl:value-of select="concat($mandate-event/@from, ' - ', $mandate-event/@to)"/>
    <xsl:text>)</xsl:text>
    -->
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
      <!-- Speaker belongs to parties, just none when he is speaking!? -->
      <xsl:when test="not(normalize-space($parties)) and $speaker/tei:affiliation[@role='member']">
	<!--xsl:message>
	  <xsl:text>WARN: belongs to parties but not for </xsl:text>
	  <xsl:value-of select="$speaker/@xml:id"/>
	  <xsl:text> on </xsl:text>
	  <xsl:value-of select="$session-date"/>
	</xsl:message-->
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
