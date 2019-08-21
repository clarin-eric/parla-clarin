<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
    exclude-result-prefixes="xs tei akn"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- AKN root element: each AKN document is a TEI document -->
    <!-- At this stage of the PARLA-CLARIN project, we are only interested in parliamentary speech.
         So we only process debate subelement, and we don't process other AKN documentType elements: 
         amendmentList, officialGazette, documentCollection, act, bill, debateReport, statement, amendment, judgment, portion, doc. -->
    <xsl:template match="akn:akomaNtoso[akn:debate]">
        <!-- values of the AKN documentType and his @name are enclosed in TEI @type and @subtype -->
        <!-- Parla-CLARIN recommendation requires that the root element of the corpus should have an xml:lang attribute -->
        <TEI type="{name(*[not(self::akn:components)])}" subtype="{*[not(self::akn:components)]/@name}" xml:lang="{akn:debate/akn:meta/akn:identification/akn:FRBRExpression/akn:FRBRlanguage/@language}">
            <xsl:apply-templates select="*[not(self::akn:components)]"/>
            <!-- What to do with akn:components? I would need examples of how these elements are used. -->
        </TEI>
    </xsl:template>
    
    <xsl:template match="akn:debate">
        <xsl:apply-templates select="akn:meta"/>
        <text>
            <xsl:if test="akn:coverPage | akn:preface">
                <front>
                    <xsl:apply-templates select="akn:coverPage | akn:preface"/>
                </front>
            </xsl:if>
            <xsl:apply-templates select="akn:debateBody"/>
            <xsl:if test="akn:conclusions | akn:attachments | akn:components">
                <back>
                    <xsl:apply-templates select="akn:conclusions | akn:attachments | akn:components"/>
                </back>
            </xsl:if>
        </text>
    </xsl:template>
    
    <xsl:template match="akn:meta">
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <xsl:choose>
                        <xsl:when test="//akn:docProponent | //akn:docTitle">
                            <xsl:for-each select="//akn:docProponent">
                                <title>
                                    <xsl:value-of select="normalize-space(.)"/>
                                </title>
                            </xsl:for-each>
                            <xsl:for-each select="//akn:docTitle">
                                <title>
                                    <xsl:value-of select="normalize-space(.)"/>
                                </title>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <title>Default title???!!</title>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:for-each select="//akn:docDate">
                        <title>
                            <xsl:value-of select="normalize-space(.)"/>
                        </title>
                    </xsl:for-each>
                </titleStmt>
                <publicationStmt>
                    <p>Publication Information</p>
                </publicationStmt>
                <sourceDesc>
                    <p>FLBR data</p>
                </sourceDesc>
            </fileDesc>
            <profileDesc>
                <xsl:if test="akn:references/akn:TLCPerson">
                    <particDesc>
                        <listPerson>
                            <xsl:for-each select="akn:references/akn:TLCPerson">
                                <person xml:id="{@eId}">
                                    <persName ref="{@href}">
                                        <xsl:value-of select="@showAs"/>
                                    </persName>
                                </person>
                            </xsl:for-each>
                        </listPerson>
                    </particDesc>
                </xsl:if>
                <xsl:if test="akn:analysis/akn:parliamentary">
                    <listOrg>
                        <org>
                            <head>Parliament: Analysis of voting, recount, and quorum verification</head>
                            <listEvent>
                                <xsl:for-each select="akn:analysis/akn:parliamentary/akn:voting">
                                    <event xml:id="{@eId}" type="voting">
                                        <desc>
                                            <xsl:for-each select="akn:quorum | akn:count">
                                                <measure></measure>
                                            </xsl:for-each>
                                            <!--<measure xml:id="vot1-quo1" type="majority" quantity="80"/><!-\- Quorum Majority -\->
                                            <measure xml:id="vot1-cnt2" type="ayes" quantity="72"/>
                                            <measure xml:id="vot1-cnt3" type="noes" quantity="56"/>
                                            <date when="2011-06-25T15:49:50"/>-->
                                        </desc>
                                    </event>
                                </xsl:for-each>
                            </listEvent>
                        </org>
                    </listOrg>
                </xsl:if>
            </profileDesc>
        </teiHeader>
    </xsl:template>
    
    <xsl:template match="akn:coverPage">
        <titlePage>
            <xsl:apply-templates/>
        </titlePage>
    </xsl:template>
    
    <xsl:template match="akn:preface">
        <div type="preface">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="akn:conclusions | akn:attachments | akn:components">
        <div type="{name()}">
            <!-- Do we also need this content for the parla-clarin project? -->
        </div>
    </xsl:template>
    
    <xsl:template match="akn:debateBody">
        <body>
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </body>
    </xsl:template>
    
    <xsl:template match="akn:debateSection">
        <div type="{name()}" subtype="{@name}">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
            <xsl:call-template name="questionAnswer"/>
        </div>
    </xsl:template>
    
    <xsl:template match="akn:*[xs:string(node-name(.)) = ('address', 'adjournment', 'administrationOfOath', 'communication', 'declarationOfVote', 'ministerialStatements', 'nationalInterest', 'noticesOfMotion', 'oralStatements', 'papers', 'petitions', 'prayers', 'proceduralMotions', 'pointOfOrder', 'personalStatements', 'questions', 'resolutions', 'rollCall', 'writtenStatements')]">
        <div type="{name()}">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
            <xsl:call-template name="questionAnswer"/>
        </div>
    </xsl:template>
    
    <!-- ANcontainers (group): specific to the Akoma Ntoso debate vocabulary: speechGroup, speech, question, answer, other, scene, narrative, summary -->
    <xsl:template match="akn:speechGroup">
        <annotationBlock>
            <xsl:call-template name="att-coreopt"/>
            <!-- Unlike element tei:u tei:annotationBlock has no TEI @decls attribute: remove or include in @corresp -->
            <xsl:call-template name="att-speechAtts"/>
            <xsl:apply-templates/>
        </annotationBlock>
    </xsl:template>
    <xsl:template match="akn:speech | akn:question | akn:answer">
        <u>
            <!-- speechType -->
            <xsl:call-template name="att-coreopt"/>
            <xsl:call-template name="att-speechAtts"/>
            <xsl:apply-templates/>
        </u>
    </xsl:template>
    <xsl:template match="akn:other">
        <note type="{name()}">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    <xsl:template match="akn:narrative | akn:summary">
        <note type="{name()}">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    <xsl:template match="akn:scene">
        <incident>
            <xsl:call-template name="att-coreopt"/>
            <desc>
                <xsl:apply-templates/>
            </desc>
        </incident>
    </xsl:template>
    
    <xsl:template name="questionAnswer">
        <xsl:if test="akn:question | akn:answer">
            <listRelation>
                <xsl:for-each select="akn:question">
                    <relation name="questionAnswer" active="#{@eId}" passive="#{following-sibling::akn:answer[1]/@eId}"/>
                </xsl:for-each>
            </listRelation>
        </xsl:if>
    </xsl:template>
    
    <!-- speechType (complexType): from, blockElements (group) -->
    <xsl:template match="akn:from">
        <note type="speaker">
            <xsl:call-template name="att-coreopt"/>
            
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    
    <!-- blockElements (group): ANblock, HTMLblock, foreign, block -->
    <!-- ANblock: blockList, blockContainer, tblock, toc -->
    <!-- HTMLblock: ul, ol, table, p -->
    <xsl:template match="akn:ul">
        <list rend="bulleted">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </list>
    </xsl:template>
    <xsl:template match="akn:ol">
        <list rend="numbered">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </list>
    </xsl:template>
    <xsl:template match="akn:table">
        <table>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="akn:p">
        <xsl:element name="{if (parent::akn:speech or parent::akn:question or parent::akn:answer) then 'seg' else 'p'}">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="akn:li">
        <item>
            <xsl:apply-templates/>
        </item>
    </xsl:template>
    <xsl:template match="akn:caption">
        <head>
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </head>
    </xsl:template>
    <xsl:template match="akn:tr">
        <row>
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </row>
    </xsl:template>
    <xsl:template match="akn:th">
        <cell role="label">
            <!-- dodaj atribute -->
            <xsl:apply-templates/>
        </cell>
    </xsl:template>
    <xsl:template match="akn:td">
        <cell>
            <!-- dodaj atribute -->
            <xsl:apply-templates/>
        </cell>
    </xsl:template>
    
    <!-- basehierarchy (complexType): heading, subheadin, num -->
    <xsl:template match="akn:heading">
        <head>
            <xsl:call-template name="att-coreopt"/>
            <xsl:if test="preceding-sibling::*[1][self::akn:num]">
                <xsl:attribute name="n">
                    <xsl:value-of select="preceding-sibling::*[1][self::akn:num]"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </head>
    </xsl:template>
    <xsl:template match="akn:subheading">
        <head type="sub">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </head>
    </xsl:template>
    <xsl:template match="akn:num">
        <!-- processed by following-sibling::akn:heading as TEI @n -->
    </xsl:template>
    
    <!-- ANsemanticInline (group): date, time, person, organization, concept, object, event, location, process, role, term, quantity, def, entity -->
    <xsl:template match="akn:date">
        <date>
            <xsl:call-template name="att-coreopt"/>
            <xsl:call-template name="att-date"/>
            <xsl:apply-templates/>
        </date>
    </xsl:template>
    <xsl:template match="akn:time">
        <time>
            <xsl:call-template name="att-coreopt"/>
            <xsl:call-template name="att-time"/>
            <xsl:apply-templates/>
        </time>
    </xsl:template>
    <xsl:template match="akn:person">
        <persName>
            <xsl:call-template name="att-coreopt"/>
            <xsl:call-template name="att-role"/>
            <xsl:apply-templates/>
        </persName>
    </xsl:template>
    <xsl:template match="akn:quantity">
        <measure>
            <xsl:call-template name="att-coreopt"/>
            <xsl:call-template name="att-normalizedAtt"/>
            <xsl:apply-templates/>
        </measure>
    </xsl:template>
    
    <!-- ANinline (group): ref, mref, rref, mod, mmod, rmod, remark, recordedTime, vote, outcome, ins, del, omissis, embeddedText, embeddedStructure, opinion, placeholder, fillIn, decoration -->
    <xsl:template match="akn:recordedTime">
        <time>
            <xsl:call-template name="att-coreopt"/>
            <xsl:call-template name="att-recordedTimeType"/>
            <xsl:apply-templates/>
        </time>
    </xsl:template>
    
    <!-- All three attribute groups (coreopt, corereq and corereqreq) are processed as optional -->
    <xsl:template name="att-coreopt">
        <xsl:call-template name="att-core"/>
        <xsl:call-template name="att-HTMLattrs"/>
        <xsl:call-template name="att-enactment"/>
        <xsl:call-template name="att-idopt"/>
        <xsl:call-template name="att-idopt"/>
        <xsl:call-template name="att-refers"/>
        <xsl:call-template name="att-xmllang"/>
        <xsl:call-template name="att-alt"/>
    </xsl:template>
    
    <xsl:template name="att-core">
        <!-- We do not transfer attributes from different namespace to TEI documents. -->
    </xsl:template>
    
    <xsl:template name="att-HTMLattrs">
        <!-- AKN: These attributes are used to specify class, style and title of the element, exactly as in HTML -->
        <xsl:if test="@class and not(self::akn:ol or self::akn:ul)">
            <xsl:attribute name="rend">
                <xsl:value-of select="@class"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@style">
            <xsl:attribute name="style">
                <xsl:value-of select="@style"/>
            </xsl:attribute>
        </xsl:if>
        <!-- @title is not processed -->
    </xsl:template>
    
    <xsl:template name="att-enactment">
        <!-- AKN: These attributes are those already defined in attribute list "period", 
                  plus the attribute status, that allows to specify the status of the piece of text it wraps. -->
        <xsl:call-template name="att-period"/>
        <xsl:if test="@status">
            <!-- Uredi možnost, kako bodo vrednosti atributa status vplivale na dodatne child elemente -->
            <!-- AKN: This is the list of allowed values for the status attribute. This is the list of possible reasons for a dscrepancy between the manifestation as it should be (e.g., a faithful representation of the content of an expression), and the manifestation as it actually is. Values should be interpreted as follows:
                      - removed: the content of the element is present in the markup (manifestation) but is not present in the real content of the document (expression level) because it has been definitely removed (either ex tunc, as in annullments, or ex nunc, as in abrogations).
                        tei:del[@type='removed']
                      - temporarily removed: the content of the element is present in the markup (manifestation) but is not present in the real content of the document (expression level) because it has been temporarily removed (e.g., for a temporary suspension or limitation of efficacy).
                        tei:del[@type='temporarilyRemoved']
                      - translated: the content of the element is present in the markup (manifestation) in a different form than in the real content of the document (expression level) because it has been translated into a different language (e.g., to match the rest of the document or because of other editorial decisions).
                        tei:reg[@type='translated']
                      - editorial: the content of the element is present in the markup (manifestation) but is not present in the real content of the document (expression level) because it has been inserted as an editorial process when creating the XML markup.
                      - edited: the content of the element is different in the markup (manifestation) than in the real content of the document (expression level) because it has been amended (e.g., to remove scurrilous or offensive remarks).
                      - verbatim: the content of the element is present in the markup (manifestation) is EXACTLY as it was in the real content of the document (expression level) because usual silent fixes and edits were NOT performed (e.g. to punctuation, grammatical errors or other usually non-debatable problems).
                      - incomplete: the content of the element or the value of a required attribute is NOT present in the markup (manifestation), although it should, because the missing data is not known at the moment, but in the future it might become known. This is especially appropriate for documents in drafting phase (e.g., the publication date of the act while drafting the bill)
                      - unknown: the content of the element or the value of a required attribute is NOT present in the markup (manifestation), although it should, because the author of the manifestation does not know it.
                      - undefined: the content of the element or the value of a required attribute is NOT present in the markup (manifestation), because the information is not defined in the original document, or it doesn't exist in some legal tradition (e.g. an anonymous speech cannot specify the attribute by, or some publications do not record the numbering of the items, etc.)
                      - ignored: the content of the element or the value of a required attribute is NOT present in the markup (manifestation) because the information exists but the author of the manifestation is not interested in reporting it (e.g., omitted parts of the document due to editorial reasons, etc.)</comment>
             -->
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="att-period">
        <!-- AKN: The period attribute is used in versioned content and metadata elements to indicate a time interval in which they were in force,
                  in efficacy, or in any other type of interval as specified in the corresponding temporalGroup.
                  Connection to akn:temporalData element: the ability to describe the entire historical text of a document, associating different text
                  with different time periods. The akn:temporalData container is used to define time periods which are used when associating text
                  with the time period for which it applies. -->
        <!-- Potrebno se bo odločiti, na kaj jih bom vezal: tei:listEvent/tei:event ali tei:timeline?! -->
    </xsl:template>
    
    <xsl:template name="att-idopt">
        <xsl:if test="@eId and not(@wId or @GUID)">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="@eId"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@eId and @wId">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="@eId"/>
            </xsl:attribute>
            <!-- @wId is processed as idno element in teiHeader/fileDesc/publicationStmt/idno[@type='wId'][@corresp=$akn-eId] -->
        </xsl:if>
        <xsl:if test="@eId and @GUID">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="@eId"/>
            </xsl:attribute>
            <!-- @GUID is processed as idno element in teiHeader/fileDesc/publicationStmt/idno[@type='GUID'][@corresp=$akn-eId] -->
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="att-refers">
        <xsl:if test="@refersTo">
            <xsl:attribute name="corresp">
                <xsl:value-of select="@refersTo"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="att-xmllang">
        <xsl:if test="@xml:lang">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="@xml:lang"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@xml:space">
            <xsl:attribute name="xml:space">
                <xsl:value-of select="@xml:space"/>
            </xsl:attribute>
        </xsl:if>
        <!-- @xml:id is not processed -->
    </xsl:template>
    
    <xsl:template name="att-alt">
        <!-- The attribute alternativeTo is used to specify, when the element contains an alternative version of some content,
             the eId of the main element which this element is an alternative copy of -->
        <xsl:if test="@alternativeTo">
            <xsl:attribute name="sameAs">
                <xsl:value-of select="@alternativeTo"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="att-speechAtts">
        <xsl:call-template name="att-agent"/>
        <xsl:call-template name="att-role"/>
        <xsl:choose>
            <!-- overrides original transformation from @refersTo to @corresp -->
            <xsl:when test="@refersTo and @to">
                <xsl:attribute name="corresp">
                    <xsl:for-each select="@refersTo and @to">
                        <xsl:value-of select="."/>
                        <xsl:if test="position() != last()">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="not(@refersTo) and @to">
                <xsl:attribute name="corresp">
                    <xsl:value-of select="@to"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
        <!-- Uredi še pretvorbo in povezavo na timeline za ta atributa!!!!!!!!!!!!!! -->
        <xsl:if test="@startTime">
            
        </xsl:if>
        <xsl:if test="@endTime">
            
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="att-agent">
        <xsl:if test="@by">
            <xsl:attribute name="who">
                <xsl:value-of select="@by"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="att-role">
        <xsl:if test="@as and not(self::akn:speechGroup)">
            <xsl:choose>
                <xsl:when test="self::akn:person">
                    <xsl:choose>
                        <!-- overrides original transformation from @refersTo to @corresp -->
                        <xsl:when test="@refersTo and @ad">
                            <xsl:attribute name="corresp">
                                <xsl:for-each select="@refersTo and @as">
                                    <xsl:value-of select="."/>
                                    <xsl:if test="position() != last()">
                                        <xsl:text> </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="not(@refersTo) and @as">
                            <xsl:attribute name="corresp">
                                <xsl:value-of select="@as"/>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="decls">
                        <xsl:value-of select="@as"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="att-date">
        <xsl:if test="@date">
            <xsl:attribute name="when">
                <xsl:value-of select="@date"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="att-time">
        <xsl:if test="@time">
            <xsl:attribute name="when">
                <xsl:value-of select="@time"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="att-recordedTimeType">
        <!-- akn:recordedTime[@type='endEvent' or @type='startEvent']/@time -->
        <xsl:choose>
            <xsl:when test="@type='startEvent'">
                <xsl:attribute name="from">
                    <xsl:value-of select="@time"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="@type='endEvent'">
                <xsl:attribute name="to">
                    <xsl:value-of select="@time"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="when">
                    <xsl:value-of select="@time"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:attribute name="type">recordedTime</xsl:attribute>
    </xsl:template>
    
    <xsl:template name="att-normalizedAtt">
        <xsl:if test="@normalized and self::akn:quantity">
            <xsl:attribute name="quantity">
                <xsl:value-of select="@normalized"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
