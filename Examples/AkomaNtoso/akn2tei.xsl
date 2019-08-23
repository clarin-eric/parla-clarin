<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
    exclude-result-prefixes="xs tei akn"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <!--xsl:preserve-space elements="p"/-->
    
    <xsl:param name="authority">CLARIN ERIC</xsl:param>
    
    <xsl:param name="sourceDesc">
        <bibl>
            <title type="main">Akoma Ntoso Version 1.0</title>
            <title type="sub">Examples</title>
            <idno type="URI">http://docs.oasis-open.org/legaldocml/akn-core/v1.0/os/part2-specs/examples/</idno>
        </bibl>
    </xsl:param>
    
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
                            <title>Akoma Ntoso: An example of parliamentary debate</title>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:for-each select="//akn:docDate">
                        <title>
                            <xsl:value-of select="normalize-space(.)"/>
                        </title>
                    </xsl:for-each>
                </titleStmt>
                <publicationStmt>
                    <authority>
                        <xsl:value-of select="$authority"/>
                    </authority>
                    <date when="{current-date()}"><xsl:value-of select="format-date(current-date(),'[D1]. [M1]. [Y0001]')"/></date>
                    <xsl:for-each select="//*[@eId][@wId or @GUID]">
                        <!-- @GUID is processed as idno element in teiHeader/fileDesc/publicationStmt/idno[@type='GUID'][@corresp=$akn-eId] -->
                        <idno type="{if (@wId) then 'wId' else 'GUID'}" corresp="#{@eId}">
                            <xsl:value-of select="@wId or @GUID"/>
                        </idno>
                    </xsl:for-each>
                </publicationStmt>
                <sourceDesc>
                    <xsl:copy-of select="$sourceDesc"/>
                    <xsl:call-template name="FRBR"/>
                </sourceDesc>
            </fileDesc>
            <profileDesc>
                <settingDesc>
                    <setting>
                        <name type="country" key="{akn:identification/akn:FRBRWork/akn:FRBRcountry/@value}"/>
                        <date when="{akn:identification/akn:FRBRWork/akn:FRBRdate/@date}"/>
                    </setting>
                </settingDesc>
            </profileDesc>
            <xsl:if test="akn:references/akn:TLCRole | akn:references/akn:TLCConcept | akn:references/akn:TLCProcess">
                <encodingDesc>
                    <classDecl>
                        <!-- add also other TLC -->
                        <xsl:call-template name="TLCConcept"/>
                        <xsl:call-template name="TLCProcess"/>
                        <xsl:call-template name="TLCRole"/>
                    </classDecl>
                </encodingDesc>
            </xsl:if>
            <profileDesc>
                <xsl:if test="akn:references/akn:TLCPerson | akn:references/akn:TLCOrganization">
                    <particDesc>
                        <xsl:call-template name="TLCOrganization"/>
                        <xsl:call-template name="TLCPerson"/>
                    </particDesc>
                </xsl:if>
                <langUsage>
                    <language ident="{akn:identification/akn:FRBRExpression/akn:FRBRlanguage/@language}"/>
                </langUsage>
            </profileDesc>
        </teiHeader>
    </xsl:template>
    
    <xsl:template name="FRBR">
        <xsl:for-each select="akn:identification">
            <listRelation type="FRBR" resp="{@source}">
                <xsl:for-each select="akn:FRBRWork">
                    <relation ref="http://www.w3.org/1999/02/22-rdf-syntax-ns#type" active="{akn:FRBRthis/@value}" passive="http://purl.org/vocab/frbr/core#Work"/>
                    <relation ref="http://www.w3.org/2002/07/owl#sameAs" active="http://purl.org/vocab/frbr/core#Work" passive="https://w3id.org/akn/ontology/allot/FRBRWork"/>
                    <xsl:call-template name="FRBRuri"/>
                    <xsl:call-template name="FRBRdate"/>
                    <xsl:call-template name="FRBRauthor"/>
                    <relation ref="http://purl.org/vocab/frbr/core#Place" active="{akn:FRBRthis/@value}" passive="http://eulersharp.sourceforge.net/2003/03swap/countries#{akn:FRBRcountry/@value}"/>
                </xsl:for-each>
                <relation active="{akn:FRBRWork/akn:FRBRthis/@value}" ref="http://purl.org/vocab/frbr/core#realization" passive="{akn:FRBRExpression/akn:FRBRthis/@value}"/>
                <xsl:for-each select="akn:FRBRExpression">
                    <relation ref="http://www.w3.org/1999/02/22-rdf-syntax-ns#type" active="{akn:FRBRthis/@value}" passive="http://purl.org/vocab/frbr/core#Expression"/>
                    <relation ref="http://www.w3.org/2002/07/owl#sameAs" active="http://purl.org/vocab/frbr/core#Expression" passive="https://w3id.org/akn/ontology/allot/FRBRExpression"/>
                    <xsl:call-template name="FRBRuri"/>
                    <xsl:call-template name="FRBRdate"/>
                    <xsl:call-template name="FRBRauthor"/>
                    <relation ref="http://purl.org/dc/elements/1.1/language" active="{akn:FRBRthis/@value}" passive="{akn:FRBRlanguage/@language}"/>
                </xsl:for-each>
                <relation active="{akn:FRBRExpression/akn:FRBRthis/@value}" ref="http://purl.org/vocab/frbr/core#embodiment" passive="{akn:FRBRManifestation/akn:FRBRthis/@value}"/>
                <xsl:for-each select="akn:FRBRManifestation">
                    <relation ref="http://www.w3.org/1999/02/22-rdf-syntax-ns#type" active="{akn:FRBRthis/@value}" passive="http://vocab.org/frbr/core.html#term-Manifestation"/>
                    <relation ref="http://www.w3.org/2002/07/owl#sameAs" active="http://vocab.org/frbr/core.html#term-Manifestation" passive="https://w3id.org/akn/ontology/allot/FRBRManifestation"/>
                    <xsl:call-template name="FRBRuri"/>
                    <xsl:call-template name="FRBRdate"/>
                    <xsl:call-template name="FRBRauthor"/>
                </xsl:for-each>
            </listRelation>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="FRBRuri">
        <xsl:if test="akn:FRBRuri">
            <relation ref="http://purl.org/dc/terms/isPartOf" active="{akn:FRBRthis/@value}" passive="{akn:FRBRuri/@value}"/>
        </xsl:if>
    </xsl:template>
    <xsl:template name="FRBRdate">
        <xsl:if test="akn:FRBRdate">
            <relation name="{akn:FRBRdate/@name}" ref="http://purl.org/dc/elements/1.1/date" active="{akn:FRBRthis/@value}" passive="{akn:FRBRdate/@date}"/>
        </xsl:if>
    </xsl:template>
    <xsl:template name="FRBRauthor">
        <xsl:if test="akn:FRBRauthor">
            <xsl:variable name="authorId" select="substring-after(akn:FRBRauthor/@href,'#')"/>
            <xsl:variable name="roleId" select="substring-after(akn:FRBRauthor/@as,'#')"/>
            <relation ref="http://purl.org/dc/elements/1.1/creator" active="{//akn:*[@eId=$authorId]/@href}" passive="{akn:FRBRthis/@value}"/>
            <relation ref="{//akn:*[@eId=$roleId]/@href}" active="{//akn:*[@eId=$authorId]/@href}" passive="{akn:FRBRthis/@value}"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="TLCConcept">
        <xsl:if test="akn:references/akn:TLCConcept">
            <taxonomy>
                <desc><term>TLCConcept</term></desc>
                <xsl:for-each select="akn:references/akn:TLCConcept">
                    <xsl:call-template name="TLC-category"/>
                </xsl:for-each>
            </taxonomy>
        </xsl:if>
    </xsl:template>
    <xsl:template name="TLCProcess">
        <xsl:if test="akn:references/akn:TLCProcess">
            <taxonomy>
                <desc><term>TLCProcess</term></desc>
                <xsl:for-each select="akn:references/akn:TLCProcess">
                    <xsl:call-template name="TLC-category"/>
                </xsl:for-each>
            </taxonomy>
        </xsl:if>
    </xsl:template>
    <xsl:template name="TLCRole">
        <xsl:if test="akn:references/akn:TLCRole">
            <taxonomy>
                <desc><term>TLCRole</term></desc>
                <xsl:for-each select="akn:references/akn:TLCRole">
                    <xsl:call-template name="TLC-category"/>
                </xsl:for-each>
            </taxonomy>
        </xsl:if>
    </xsl:template>
    <xsl:template name="TLC-category">
        <category xml:id="{@eId}">
            <catDesc>
                <term>
                    <xsl:value-of select="@showAs"/>
                </term>
                <idno type="AKN">
                    <xsl:value-of select="@href"/>
                </idno>
            </catDesc>
        </category>
    </xsl:template>
    <xsl:template name="TLCOrganization">
        <xsl:if test="akn:references/akn:TLCOrganization">
            <listOrg>
                <xsl:for-each select="akn:references/akn:TLCOrganization">
                    <org xml:id="{@eId}">
                        <orgName>
                            <xsl:value-of select="@showAs"/>
                        </orgName>
                        <xsl:if test="@href">
                            <idno type="AKN">
                                <xsl:value-of select="@href"/>
                            </idno>
                        </xsl:if>
                    </org>
                </xsl:for-each>
            </listOrg>
        </xsl:if>
    </xsl:template>
    <xsl:template name="TLCPerson">
        <xsl:if test="akn:references/akn:TLCPerson">
            <listPerson>
                <xsl:for-each select="akn:references/akn:TLCPerson">
                    <person xml:id="{@eId}">
                        <persName>
                            <xsl:value-of select="@showAs"/>
                        </persName>
                        <xsl:if test="@href">
                            <idno type="AKN">
                                <xsl:value-of select="@href"/>
                            </idno>
                        </xsl:if>
                    </person>
                </xsl:for-each>
            </listPerson>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="akn:coverPage">
        <div type="coverPage">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="akn:preface">
        <div type="preface">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="akn:conclusions | akn:attachments | akn:components">
        <div type="{name()}">
            <!-- Do we also need this content for the parla-clarin project? -->
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="akn:debateBody">
        <body>
            <xsl:call-template name="att-coreopt"/>
            <!-- First, we add any voting metadata. -->
            <xsl:call-template name="voting"/>
            <xsl:apply-templates/>
        </body>
    </xsl:template>
    
    <xsl:template name="voting">
        <xsl:for-each select="ancestor::akn:debate/akn:meta/akn:analysis/akn:parliamentary">
            <listEvent>
                <xsl:for-each select="akn:voting | akn:recount">
                    <event type="{name()}">
                        <xsl:call-template name="att-idopt"/>
                        <xsl:call-template name="att-outcome_ana"/>
                        <xsl:call-template name="att-refers"/>
                        <xsl:call-template name="att-link"/>
                        <desc>
                            <xsl:for-each select="akn:quorum | akn:count">
                                <measure type="{name()}">
                                    <xsl:call-template name="att-idopt"/>
                                    <xsl:if test="@refersTo">
                                        <xsl:attribute name="ana">
                                            <xsl:value-of select="@refersTo"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <xsl:if test="@href">
                                        <xsl:attribute name="corresp">
                                            <xsl:value-of select="@href"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <xsl:if test="@value">
                                        <xsl:attribute name="quantity">
                                            <xsl:value-of select="@value"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                </measure>
                            </xsl:for-each>
                        </desc>
                    </event>
                </xsl:for-each>
                <xsl:for-each select="akn:recount">
                    <listRelation>
                        <relation name="recount" active="#{@eId}" passive="#{preceding-sibling::akn:voting/@eId}"/>
                    </listRelation>
                </xsl:for-each>
            </listEvent>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="akn:debateSection">
        <xsl:variable name="element-name" select="name()"/>
        <xsl:variable name="element-att-name" select="@name"/>
        <xsl:choose>
            <!-- Removes debate sections without heding that are the same as their parent or child section. -->
            <xsl:when test="not(akn:heading) and (parent::*[name(.) = $element-name][@name=$element-att-name] or child::*[name(.) = $element-name][@name=$element-att-name])">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <div type="{name()}" subtype="{@name}">
                    <xsl:call-template name="att-coreopt"/>
                    <xsl:apply-templates/>
                    <xsl:call-template name="questionAnswer"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="akn:*[xs:string(node-name(.)) = ('address', 'adjournment', 'administrationOfOath', 'communication', 'declarationOfVote', 'ministerialStatements', 'nationalInterest', 'noticesOfMotion', 'oralStatements', 'papers', 'petitions', 'prayers', 'proceduralMotions', 'pointOfOrder', 'personalStatements', 'questions', 'resolutions', 'rollCall', 'writtenStatements')]">
        <xsl:variable name="element-name" select="name()"/>
        <xsl:choose>
            <!-- Removes debate sections without heding that are the same as their parent or child section. -->
            <xsl:when test="not(akn:heading) and (parent::*[name(.) = $element-name] or child::*[name(.) = $element-name])">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <div type="{name()}">
                    <xsl:call-template name="att-coreopt"/>
                    <xsl:apply-templates/>
                    <xsl:call-template name="questionAnswer"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ANcontainers (group): specific to the Akoma Ntoso debate vocabulary: speechGroup, speech, question, answer, other, scene, narrative, summary -->
    <xsl:template match="akn:speechGroup">
        <annotationBlock>
            <xsl:call-template name="att-coreopt"/>
            <xsl:call-template name="att-speechAtts"/>
            <xsl:apply-templates/>
        </annotationBlock>
    </xsl:template>
    <xsl:template match="akn:speech | akn:question | akn:answer">
        <xsl:choose>
            <xsl:when test=" preceding-sibling::akn:*[xs:string(node-name(.)) = ('debateSection', 'address', 'adjournment', 'administrationOfOath', 'communication', 'declarationOfVote', 'ministerialStatements', 'nationalInterest', 'noticesOfMotion', 'oralStatements', 'papers', 'petitions', 'prayers', 'proceduralMotions', 'pointOfOrder', 'personalStatements', 'questions', 'resolutions', 'rollCall', 'writtenStatements')]">
                <div>
                    <xsl:call-template name="utterance"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="utterance"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="utterance">
        <u>
            <!-- speechType -->
            <xsl:call-template name="att-coreopt"/>
            <xsl:call-template name="att-speechAtts"/>
            <xsl:apply-templates/>
            <!-- Speech relations -->
            <xsl:call-template name="speech-relation"/>
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
        <xsl:if test="akn:question[following-sibling::*[1][self::akn:answer]]">
            <listRelation>
                <xsl:for-each select="akn:question[following-sibling::*[1][self::akn:answer]]">
                    <relation name="questionAnswer" active="#{@eId}" passive="#{following-sibling::*[1][self::akn:answer]/@eId}"/>
                </xsl:for-each>
            </listRelation>
        </xsl:if>
    </xsl:template>
    <xsl:template name="speech-relation">
        <xsl:if test="@by and (@to or @refersTo)">
            <listRelation>
                <relation name="directedTo" active="{@by}" passive="{if (@to) then @to else @refersTo}"/>
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
        <!-- rend="bulleted" -->
        <list>
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </list>
    </xsl:template>
    <xsl:template match="akn:ol">
        <!-- rend="numbered" -->
        <list>
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
        <xsl:choose>
            <xsl:when test="string-length(normalize-space(.)) = 0">
                <!-- remove empty paragraphs -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{if (parent::akn:speech or parent::akn:question or parent::akn:answer) then 'seg' else 'p'}">
                    <xsl:call-template name="att-coreopt"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="akn:li">
        <item>
            <!-- dodaj atribute -->
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
    
    <!-- TOC -->
    <xsl:template match="akn:toc">
        <list type="toc">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </list>
    </xsl:template>
    <xsl:template match="akn:tocItem">
        <item>
            <xsl:call-template name="att-coreopt"/>
            <!--<xsl:call-template name="att-link"/>-->
            <xsl:if test="@level">
                <xsl:attribute name="n">
                    <xsl:value-of select="@level"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="att-link"/>
            <xsl:apply-templates/>
        </item>
    </xsl:template>
    
    <!-- basehierarchy (complexType): heading, subheadin, num -->
    <xsl:template match="akn:heading">
        <head>
            <xsl:call-template name="att-coreopt"/>
            <xsl:if test="preceding-sibling::*[1][self::akn:num]">
                <num>
                    <xsl:value-of select="preceding-sibling::*[1][self::akn:num]"/>
                    <xsl:text> </xsl:text>
                </num>
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
    
    <!-- ANtitleInline: docType, docTitle, docNumber, docProponent, docDate, legislature, session, shortTitle, docAuthority, docPurpose,
                        docCommittee, docIntroducer, docStage, docStatus, docJurisdiction, docketNumber -->
    <xsl:template match="akn:docTitle | akn:shortTitle | akn:docStage">
        <title type="{name()}">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </title>
    </xsl:template>
    <xsl:template match="akn:docProponent">
        <name type="{name()}">
            <xsl:call-template name="att-coreopt"/>
            <xsl:call-template name="att-role"/>
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    <xsl:template match="akn:docAuthority | akn:docCommittee | docIntroducer">
        <name type="{name()}">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    <xsl:template match="akn:docDate">
        <date type="{name()}">
            <xsl:call-template name="att-coreopt"/>
            <xsl:call-template name="att-date"/>
            <xsl:apply-templates/>
        </date>
    </xsl:template>
    <xsl:template match="akn:docType | akn:docPurpose | akn:docStatus | akn:docJurisdiction | akn:docketNumber">
        <term type="{name()}">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </term>
    </xsl:template>
    <xsl:template match="akn:docNumber">
        <num type="{name()}">
            <xsl:call-template name="att-coreopt"/>
            <xsl:apply-templates/>
        </num>
    </xsl:template>
    <xsl:template match="akn:legislature | akn:session">
        <term type="{name()}">
            <xsl:call-template name="att-coreopt"/>
            <!-- also add @value -->
            <xsl:apply-templates/>
        </term>
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
        <xsl:choose>
            <xsl:when test="self::akn:ol or self::akn:ul">
                <xsl:attribute name="rend">
                    <xsl:value-of select="if (self::akn:ol) then 'numbered' else 'bulleted'"/>
                    <xsl:if test="@class">
                        <xsl:value-of select="concat(' ',@class)"/>
                    </xsl:if>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="@class">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="@class"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
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
            <!-- Uredi možnost, kako bodo vrednosti atributa status vplivale na dodatne child elemente. Druga možnost je, da gre v @ana in spodnjev vrednosti v taxonomy -->
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
        <xsl:if test="@period">
            <!-- Make a proper connection (with @corresp or @ana) to the tei:taxomnomy (See: https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ND.html#NDATTSda ) -->
            <!-- AKN example: <temporalData source="{source}">
                                 <temporalGroup eId="{identifier}">
                                    <timeInterval refersTo="{ontologyRef}" [start="{eventRefRef}"] [end="{eventRefRef}"] [duration="{duration}"]/>
                                 <temporalGroup>
                              </temporalData> -->
        </xsl:if>
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
            <!-- daj v source -->
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
        <xsl:if test="@as">
            <xsl:attribute name="ana">
                <xsl:value-of select="@as"/>
            </xsl:attribute>
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
    
    <xsl:template name="att-link">
        <xsl:choose>
            <!-- overrides original transformation from @refersTo to @corresp -->
            <xsl:when test="@refersTo and @href">
                <xsl:attribute name="corresp">
                    <xsl:for-each select="@refersTo and @href">
                        <xsl:value-of select="."/>
                        <xsl:if test="position() != last()">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="not(@refersTo) and @href">
                <xsl:attribute name="corresp">
                    <xsl:value-of select="@href"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="att-outcome_ana">
        <xsl:if test="@outcome">
            <xsl:attribute name="ana">
                <xsl:value-of select="@outcome"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
