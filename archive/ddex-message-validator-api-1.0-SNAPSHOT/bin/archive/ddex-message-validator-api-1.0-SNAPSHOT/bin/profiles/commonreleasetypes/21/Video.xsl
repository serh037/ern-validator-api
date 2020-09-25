<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


   <!--PROLOG-->
   <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


   <!--KEYS AND FUNCTIONS-->


   <!--DEFAULT RULES-->


   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="Schematron Release Profile for Video (version 2.1) for the NewReleaseMessage."
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:text>© 2006-2018 Digital Data Exchange, LLC (DDEX)</svrl:text>
         <svrl:text>This ISO Schematron file is, together with all DDEX standards, subject to two licences: If you wish to evaluate whether the standard meets your needs please have a look at the Evaluation Licence at https://kb.ddex.net/display/HBK/Evaluation+Licence+for+DDEX+Standards. If you want to implement and use this DDEX standard, please take out an Implementation Licence. For details please go to http://ddex.net/apply-ddex-implementation-licence.</svrl:text>
         <svrl:text>Failing a rule with a role of 'Fatal Error' means that the Conformance Tester must recommend to not award a Conformance Certificate or to retract a Conformance Certificate if one has already been issued. Failing a rule with a role of 'Conditional Fatal Error' is the same as a 'Fatal Error', however, the rule may be ignored if the Conformance Tester has no means of asserting whether the condition expressed in the rule has been met.</svrl:text>
         <svrl:text>Failing a rule a rule with a role of 'Error' means that the Conformance Tester must recommend to award a Partial Conformance Certificate or to downgrade a Conformance Certificate that has already been issued. However, if more than 4 rules (representing 50% of all rules with a role of 'Error') have been failed at least once, the Conformance Tester must recommend to not award a Conformance Certificate or to retract a Conformance Certificate if one has already been issued. Failing a rule with a role of 'Conditional Error' is the same as an 'Error', however, the rule may be ignored if the Conformance Tester has no means of asserting whether the condition expressed in the rule has been met.</svrl:text>
         <svrl:text>The following Clauses from the Release Profile standard are NOT checked by this ISO Schematron file: 5.1.1 (partly), 5.3.1.1(1-3, 7.1, 7.3, 9), 5.3.1.2(2.1, 3-4, 5.1), 5.3.1.3(4-5), 5.3.1.4(3-5, 8), 5.3.3.1-2, 5.3.3.4, 5.4.1(4.1), 5.4.3(5), 5.4.4(3, 5), 5.5.1(2), 5.5.2(2.4, 3.5-3.7), 5.6(1, 3). This file also does not check any rules specified in the ERN Message Suite Standard (Version 4.1) specifications, sections 6.4 and 6.5, except for 6.4.8-10</svrl:text>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustContainOneRelease</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustContainOneRelease</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ICPN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ICPN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISNI</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISNI</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_GRid</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_GRid</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SICI</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SICI</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISSN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISSN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISBN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISBN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_VISAN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_VISAN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISAN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISAN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISMN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISMN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISWC</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISWC</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ISRC</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ISRC</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_UserDefinedValue</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_UserDefinedValue</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_RightSharePercentageValue</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_RightSharePercentageValue</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_IsDefaultTerritory</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_IsDefaultTerritory</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_Contributor</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_Contributor</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_DisplayArtistsMustBeSequenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_DisplayArtistsMustBeSequenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustNotHaveManyMainDisplayArtists</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustNotHaveManyMainDisplayArtists</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ResourceGroupType</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ResourceGroupType</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ResourceGroupsMustBeSequenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ResourceGroupsMustBeSequenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_PrimaryResourcesMustBeSequenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_PrimaryResourcesMustBeSequenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SequenceNumberMustBeDifferent</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SequenceNumberMustBeDifferent</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SingleSequenceInResourceGroup</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SingleSequenceInResourceGroup</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SecondaryResourcesMustNotBeSequenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SecondaryResourcesMustNotBeSequenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_CueMustHaveStartTimeOrDuration</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_CueMustHaveStartTimeOrDuration</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M30"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MainReleaseMustHaveGridOrICPN</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MainReleaseMustHaveGridOrICPN</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M31"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ReleaseMayHaveCLine</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ReleaseMayHaveCLine</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M32"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ReleaseDateMustBeProvided</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ReleaseDateMustBeProvided</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M33"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ResourceGroupTypeSide</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ResourceGroupTypeSide</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M34"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_SecondaryResourceMustHaveProprietaryId</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_SecondaryResourceMustHaveProprietaryId</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M35"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_NoContributorDuplicate</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_NoContributorDuplicate</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M36"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_FirstPublicationDateMustBeProvided</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_FirstPublicationDateMustBeProvided</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M37"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_TechnicalDetails</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_TechnicalDetails</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M38"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ChaptersMustBeReferenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ChaptersMustBeReferenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M39"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_CueSheetsMustBeReferenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_CueSheetsMustBeReferenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M40"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ResourcesMustBeReferenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ResourcesMustBeReferenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M41"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_PartiesMustBeReferenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_PartiesMustBeReferenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M42"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ReleasesMustBeReferenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ReleasesMustBeReferenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M43"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_DateShouldBeBeforeDealStartDate</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_DateShouldBeBeforeDealStartDate</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M44"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_DateShouldBeBeforeDealStartDateTime</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_DateShouldBeBeforeDealStartDateTime</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M45"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustNotContainPriceType</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustNotContainPriceType</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M46"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustContainUseType1</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustContainUseType1</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M47"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustContainUseType2</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustContainUseType2</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M48"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustContainUseType3</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustContainUseType3</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M49"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustContainUseType4</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustContainUseType4</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M50"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustContainOneTrackReleasePerPrimaryResource</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustContainOneTrackReleasePerPrimaryResource</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M51"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_TrackReleaseMustNotHaveISRC</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_TrackReleaseMustNotHaveISRC</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M52"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_TrackReleaseMustHaveOnePrimaryResource</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_TrackReleaseMustHaveOnePrimaryResource</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M53"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_TrackReleaseMustNotHaveSecondaryResources</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_TrackReleaseMustNotHaveSecondaryResources</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M54"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_TrackReleaseMustNotHaveRedundantTitles</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_TrackReleaseMustNotHaveRedundantTitles</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M55"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">VideoSingle_ReleaseProfileVersionId</xsl:attribute>
            <xsl:attribute name="name">VideoSingle_ReleaseProfileVersionId</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M56"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_ReleaseProfileVariantVersionId</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_ReleaseProfileVariantVersionId</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M57"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_MustContainShortFormMusicalWorkVideo</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_MustContainShortFormMusicalWorkVideo</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M58"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">VideoSingle_MustContainFrontCoverImage</xsl:attribute>
            <xsl:attribute name="name">VideoSingle_MustContainFrontCoverImage</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M59"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">VideoSingle_MustNotContainFrontCoverImage</xsl:attribute>
            <xsl:attribute name="name">VideoSingle_MustNotContainFrontCoverImage</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M60"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_TextSheetMusicSoftwareMustBeBonus</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_TextSheetMusicSoftwareMustBeBonus</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M61"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">VideoSingle_MainReleaseType</xsl:attribute>
            <xsl:attribute name="name">VideoSingle_MainReleaseType</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M62"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_BonusResourcesMustNotBeSequenced</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_BonusResourcesMustNotBeSequenced</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M63"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_FrontCoverImageMustBeLinked</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_FrontCoverImageMustBeLinked</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M64"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_VideoScreenCaptureMustBeLinked</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_VideoScreenCaptureMustBeLinked</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M65"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_PrimaryResourceMustHaveISRC</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_PrimaryResourceMustHaveISRC</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M66"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">MultiProfile_BonusResourceMustHaveProprietaryId</xsl:attribute>
            <xsl:attribute name="name">MultiProfile_BonusResourceMustHaveProprietaryId</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M67"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Schematron Release Profile for Video (version 2.1) for the NewReleaseMessage.</svrl:text>

   <!--PATTERN MultiProfile_MustContainOneRelease-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList" priority="1000" mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(Release) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(Release) = 1">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): A Release of this type must contain one (and only one) Release (Release Profile 2.1, Clause 5.1.1(a), Rule 1060-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ICPN-->


	  <!--RULE -->
   <xsl:template match="//ICPN" priority="1000" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ICPN"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[0-9]{8}$|^[0-9]{12,14}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[0-9]{8}$|^[0-9]{12,14}$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): An ICPN must be a string conforming to the pattern [0-9]{8} or [0-9]{12,14} (Release Profile 2.1, Clause 5.3.1.1(4a), Rule 1061-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISNI-->


	  <!--RULE -->
   <xsl:template match="//PartyId[@IsISNI = 'true']" priority="1000" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//PartyId[@IsISNI = 'true']"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[0-9]{15}[X0-9]$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[0-9]{15}[X0-9]$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): A PartyId of type 'ISNI' must be a string conforming to the pattern [0-9]{15}[X0-9] (Release Profile 2.1, Clause 5.3.1.1(4b), Rule 1062-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

   <!--PATTERN MultiProfile_GRid-->


	  <!--RULE -->
   <xsl:template match="//GRid" priority="1000" mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//GRid"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[a-zA-Z0-9]{18}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[a-zA-Z0-9]{18}$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): A GRid must be a string conforming to the pattern [a-zA-Z0-9]{18} (Release Profile 2.1, Clause 5.3.1.1(4c), Rule 1063-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SICI-->


	  <!--RULE -->
   <xsl:template match="//SICI" priority="1000" mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//SICI"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[0-9]{4}-[0-9]{3}[X0-9].+')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[0-9]{4}-[0-9]{3}[X0-9].+')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): A SICI must be a string conforming to the pattern [0-9]{4}-[0-9]{3}[X0-9].+ (Release Profile 2.1, Clause 5.3.1.1(4d), Rule 1064-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISSN-->


	  <!--RULE -->
   <xsl:template match="//ISSN" priority="1000" mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ISSN"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[0-9]{4}-[0-9]{3}[X0-9]$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[0-9]{4}-[0-9]{3}[X0-9]$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): An ISSN must be a string conforming to the pattern [0-9]{4}-[0-9]{3}[X0-9] (Release Profile 2.1, Clause 5.3.1.1(4e), Rule 1065-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISBN-->


	  <!--RULE -->
   <xsl:template match="//ISBN" priority="1000" mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ISBN"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^97[8-9][0-9]{9}[X0-9]$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^97[8-9][0-9]{9}[X0-9]$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): An ISBN must be a string conforming to the pattern 97[8-9][0-9]{9}[X0-9] (Release Profile 2.1, Clause 5.3.1.1(4f), Rule 1066-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>

   <!--PATTERN MultiProfile_VISAN-->


	  <!--RULE -->
   <xsl:template match="//VISAN" priority="1000" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//VISAN"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[A-F0-9]{24}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[A-F0-9]{24}$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): A VISAN must be a string conforming to the pattern [A-F0-9]{24} (Release Profile 2.1, Clause 5.3.1.1(4g), Rule 1067-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISAN-->


	  <!--RULE -->
   <xsl:template match="//ISAN" priority="1000" mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ISAN"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[A-F0-9]{12}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[A-F0-9]{12}$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): An ISAN must be a string conforming to the pattern [A-F0-9]{12} (Release Profile 2.1, Clause 5.3.1.1(4h), Rule 1068-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISMN-->


	  <!--RULE -->
   <xsl:template match="//ISMN" priority="1000" mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ISMN"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^979[0-9]{9}[X0-9]$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^979[0-9]{9}[X0-9]$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): An ISMN must be a string conforming to the pattern 979[0-9]{9}[X0-9] (Release Profile 2.1, Clause 5.3.1.1(4i), Rule 1069-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISWC-->


	  <!--RULE -->
   <xsl:template match="//ISWC" priority="1000" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ISWC"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[a-zA-Z][0-9]{10}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[a-zA-Z][0-9]{10}$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): An ISWC must be a string conforming to the pattern [a-zA-Z][0-9]{10} (Release Profile 2.1, Clause 5.3.1.1(4j), Rule 1070-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ISRC-->


	  <!--RULE -->
   <xsl:template match="//ISRC" priority="1000" mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//ISRC"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(., '^[a-zA-Z]{2}[a-zA-Z0-9]{3}[0-9]{7}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^[a-zA-Z]{2}[a-zA-Z0-9]{3}[0-9]{7}$')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): An ISRC must be a string conforming to the pattern [a-zA-Z]{2}[a-zA-Z0-9]{3}[0-9]{7} (Release Profile 2.1, Clause 5.3.1.1(4k), Rule 1071-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="matches(substring(.,1,2), '(FX|QM|QZ|UK|CP|DG|ZZ|AD|AE|AF|AG|AI|AL|AM|AN|AO|AQ|AR|AS|AT|AU|AW|AX|AZ|BA|BB|BD|BE|BF|BG|BH|BI|BJ|BL|BM|BN|BO|BQ|BR|BS|BT|BV|BW|BY|BZ|CA|CC|CD|CF|CG|CH|CI|CK|CL|CM|CN|CO|CR|CS|CU|CV|CW|CX|CY|CZ|DE|DJ|DK|DM|DO|DZ|EC|EE|EG|EH|ER|ES|ET|FI|FJ|FK|FM|FO|FR|GA|GB|GD|GE|GF|GG|GH|GI|GL|GM|GN|GP|GQ|GR|GS|GT|GU|GW|GY|HK|HM|HN|HR|HT|HU|ID|IE|IL|IM|IN|IO|IQ|IR|IS|IT|JE|JM|JO|JP|KE|KG|KH|KI|KM|KN|KP|KR|KW|KY|KZ|LA|LB|LC|LI|LK|LR|LS|LT|LU|LV|LY|MA|MC|MD|ME|MF|MG|MH|MK|ML|MM|MN|MO|MP|MQ|MR|MS|MT|MU|MV|MW|MX|MY|MZ|NA|NC|NE|NF|NG|NI|NL|NO|NP|NR|NU|NZ|OM|PA|PE|PF|PG|PH|PK|PL|PM|PN|PR|PS|PT|PW|PY|QA|RE|RO|RS|RU|RW|SA|SB|SC|SD|SE|SG|SH|SI|SJ|SK|SL|SM|SN|SO|SR|SS|ST|SV|SX|SY|SZ|TC|TD|TF|TG|TH|TJ|TK|TL|TM|TN|TO|TR|TT|TV|TW|TZ|UA|UG|UM|US|UY|UZ|VA|VC|VE|VG|VI|VN|VU|WF|WS|YE|YT|ZA|ZM|ZW)')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(substring(.,1,2), '(FX|QM|QZ|UK|CP|DG|ZZ|AD|AE|AF|AG|AI|AL|AM|AN|AO|AQ|AR|AS|AT|AU|AW|AX|AZ|BA|BB|BD|BE|BF|BG|BH|BI|BJ|BL|BM|BN|BO|BQ|BR|BS|BT|BV|BW|BY|BZ|CA|CC|CD|CF|CG|CH|CI|CK|CL|CM|CN|CO|CR|CS|CU|CV|CW|CX|CY|CZ|DE|DJ|DK|DM|DO|DZ|EC|EE|EG|EH|ER|ES|ET|FI|FJ|FK|FM|FO|FR|GA|GB|GD|GE|GF|GG|GH|GI|GL|GM|GN|GP|GQ|GR|GS|GT|GU|GW|GY|HK|HM|HN|HR|HT|HU|ID|IE|IL|IM|IN|IO|IQ|IR|IS|IT|JE|JM|JO|JP|KE|KG|KH|KI|KM|KN|KP|KR|KW|KY|KZ|LA|LB|LC|LI|LK|LR|LS|LT|LU|LV|LY|MA|MC|MD|ME|MF|MG|MH|MK|ML|MM|MN|MO|MP|MQ|MR|MS|MT|MU|MV|MW|MX|MY|MZ|NA|NC|NE|NF|NG|NI|NL|NO|NP|NR|NU|NZ|OM|PA|PE|PF|PG|PH|PK|PL|PM|PN|PR|PS|PT|PW|PY|QA|RE|RO|RS|RU|RW|SA|SB|SC|SD|SE|SG|SH|SI|SJ|SK|SL|SM|SN|SO|SR|SS|ST|SV|SX|SY|SZ|TC|TD|TF|TG|TH|TJ|TK|TL|TM|TN|TO|TR|TT|TV|TW|TZ|UA|UG|UM|US|UY|UZ|VA|VC|VE|VG|VI|VN|VU|WF|WS|YE|YT|ZA|ZM|ZW)')">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): An ISRC must be a string starting with an ISO 3166 code or FX, QM, QZ, UK, CP, DG or ZZ (Release Profile 2.1, Clause 5.3.1.1(4k), Rule 1071-2).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>

   <!--PATTERN MultiProfile_UserDefinedValue-->


	  <!--RULE -->
   <xsl:template match="//*[@UserDefinedValue]" priority="1000" mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//*[@UserDefinedValue]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test=".='UserDefined' or @LinkDescription='UserDefined' or @LabelType='UserDefined'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=".='UserDefined' or @LinkDescription='UserDefined' or @LabelType='UserDefined'">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): The value shall be 'UserDefined' if a user-defined value is supplied (Release Profile 2.1, Clause 5.3.1.1(5), Rule 1072-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="@Namespace"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@Namespace">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): The appropriate Namespace for the user-defined value shall be provided (Release Profile 2.1, Clause 5.3.1.1(5), Rule 1072-2).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>

   <!--PATTERN MultiProfile_RightSharePercentageValue-->


	  <!--RULE -->
   <xsl:template match="//RightSharePercentage" priority="1000" mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//RightSharePercentage"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="//RightSharePercentage &gt; 0 and //RightSharePercentage &lt; 100"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//RightSharePercentage &gt; 0 and //RightSharePercentage &lt; 100">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): A RightSharePercentage has a value between 0 and 100 (Release Profile 2.1, Clause 5.3.1.1(6), Rule 1073-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>

   <!--PATTERN MultiProfile_IsDefaultTerritory-->


	  <!--RULE -->
   <xsl:template match="//*[@IsDefault]" priority="1000" mode="M20">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//*[@IsDefault]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(../*[name(.)=name(current()) and @IsDefault = 'true']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(../*[name(.)=name(current()) and @IsDefault = 'true']) = 1">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): An IsDefault flag with value true may only be provided once (Release Profile 2.1, Clause 5.3.1.1(7.2), Rule 1074-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>

   <!--PATTERN MultiProfile_Contributor-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/SoundRecording[not(@IsSupplemental = 'true')] | *:NewReleaseMessage/ResourceList/Video[not(@IsSupplemental = 'true')]"
                 priority="1000"
                 mode="M21">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/SoundRecording[not(@IsSupplemental = 'true')] | *:NewReleaseMessage/ResourceList/Video[not(@IsSupplemental = 'true')]"/>

		    <!--ASSERT Conditional Fatal Error-->
      <xsl:choose>
         <xsl:when test="//Contributor[Role = 'Adapter' or Role = 'Arranger' or Role = 'Author' or Role = 'Composer' or Role = 'ComposerLyricist' or Role = 'Librettist' or Role = 'Lyricist' or Role = 'NonLyricAuthor' or Role = 'SubArranger' or Role = 'Translator']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//Contributor[Role = 'Adapter' or Role = 'Arranger' or Role = 'Author' or Role = 'Composer' or Role = 'ComposerLyricist' or Role = 'Librettist' or Role = 'Lyricist' or Role = 'NonLyricAuthor' or Role = 'SubArranger' or Role = 'Translator']">
               <xsl:attribute name="role">Conditional Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conditional Fatal Error (Video): Any available information on Contributors that have one of the roles Adapter, Arranger, Author, Composer, ComposerLyricist, Librettist, Lyricist, NonLyricAuthor, SubArranger, Translator should be provided (Release Profile 2.1, Clause 5.3.1.1(8), Rule 1075-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>

   <!--PATTERN MultiProfile_DisplayArtistsMustBeSequenced-->


	  <!--RULE -->
   <xsl:template match="//DisplayArtist" priority="1000" mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//DisplayArtist"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="@SequenceNumber"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@SequenceNumber">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): All DisplayArtists should be sequenced (Release Profile 2.1, Clause 5.3.1.2(1), Rule 1076-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustNotHaveManyMainDisplayArtists-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release | *:NewReleaseMessage/ResourceList/*"
                 priority="1000"
                 mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release | *:NewReleaseMessage/ResourceList/*"/>

		    <!--REPORT Conditional Error-->
      <xsl:if test="count(DisplayArtist[DisplayArtistRole = 'MainArtist']) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(DisplayArtist[DisplayArtistRole = 'MainArtist']) &gt; 1">
            <xsl:attribute name="role">Conditional Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Conditional Error (Video): Additional artists may not have a DisplayArtistRole of MainArtist (Release Profile 2.1, Clause 5.3.1.2(2), Rule 1077-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ResourceGroupType-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage[not(@ReleaseProfileVariantVersionId)]/ReleaseList/Release/ResourceGroup/ResourceGroup"
                 priority="1000"
                 mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage[not(@ReleaseProfileVariantVersionId)]/ReleaseList/Release/ResourceGroup/ResourceGroup"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="@ResourceGroupType = 'Component' or @ResourceGroupType = 'Side'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ResourceGroupType = 'Component' or @ResourceGroupType = 'Side'">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): Second-level ResourceGroups shall have a ResourceGroupType of either Side or Component unless it is a variant Release Profile (Release Profile 2.1, Clause 5.3.1.2(5.2), Rule 1078-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ResourceGroupsMustBeSequenced-->


	  <!--RULE -->
   <xsl:template match="//ResourceGroup[@ResourceGroupType = 'Component' or @ResourceGroupType = 'ComponentRelease' or @ResourceGroupType = 'Side' or @ResourceGroupType = 'MultiWorkPart']"
                 priority="1000"
                 mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ResourceGroup[@ResourceGroupType = 'Component' or @ResourceGroupType = 'ComponentRelease' or @ResourceGroupType = 'Side' or @ResourceGroupType = 'MultiWorkPart']"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="SequenceNumber"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="SequenceNumber">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): ResourceGroups of type Component, ComponentRelease, Side or MultiWorkPart shall be sequenced (Release Profile 2.1, Clause 5.3.1.2(5.3), Rule 1079-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>

   <!--PATTERN MultiProfile_PrimaryResourcesMustBeSequenced-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/SoundRecording[not(@IsSupplemental = 'true')] | *:NewReleaseMessage/ResourceList/Video[not(@IsSupplemental = 'true')]"
                 priority="1000"
                 mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/SoundRecording[not(@IsSupplemental = 'true')] | *:NewReleaseMessage/ResourceList/Video[not(@IsSupplemental = 'true')]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="//ResourceGroupContentItem[ReleaseResourceReference = current()/ResourceReference]/SequenceNumber"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//ResourceGroupContentItem[ReleaseResourceReference = current()/ResourceReference]/SequenceNumber">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): Primary Resources shall be sequenced in their ResourceGroupContentItem (Release Profile 2.1, Clause 5.3.1.2(5.4), Rule 1080-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SequenceNumberMustBeDifferent-->


	  <!--RULE -->
   <xsl:template match="//SequenceNumber" priority="1000" mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//SequenceNumber"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="count(../../*[name(.)=name(current()/..) and SequenceNumber=current()]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../../*[name(.)=name(current()/..) and SequenceNumber=current()]) &gt; 1">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): SequenceNumbers must all be different (Release Profile 2.1, Clause 5.3.1.2(5.5), Rule 1081-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SingleSequenceInResourceGroup-->


	  <!--RULE -->
   <xsl:template match="//ResourceGroup/ResourceGroup/SequenceNumber"
                 priority="1000"
                 mode="M28">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ResourceGroup/ResourceGroup/SequenceNumber"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="current() = ../../ResourceGroupContentItem/SequenceNumber">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="current() = ../../ResourceGroupContentItem/SequenceNumber">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): There is only one sequence within a ResourceGroup (Release Profile 2.1, Clause 5.3.1.2(5.6), Rule 1082-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SecondaryResourcesMustNotBeSequenced-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/SoundRecording[@IsSupplemental = 'true'] | *:NewReleaseMessage/ResourceList/Video[@IsSupplemental = 'true'] | *:NewReleaseMessage/ResourceList/Image | *:NewReleaseMessage/ResourceList/Text | *:NewReleaseMessage/ResourceList/SheetMusic | *:NewReleaseMessage/ResourceList/Software"
                 priority="1000"
                 mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/SoundRecording[@IsSupplemental = 'true'] | *:NewReleaseMessage/ResourceList/Video[@IsSupplemental = 'true'] | *:NewReleaseMessage/ResourceList/Image | *:NewReleaseMessage/ResourceList/Text | *:NewReleaseMessage/ResourceList/SheetMusic | *:NewReleaseMessage/ResourceList/Software"/>

		    <!--REPORT Error-->
      <xsl:if test="//ResourceGroupContentItem[ReleaseResourceReference = current()/ResourceReference]/SequenceNumber">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="//ResourceGroupContentItem[ReleaseResourceReference = current()/ResourceReference]/SequenceNumber">
            <xsl:attribute name="role">Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Error (Video): Secondary Resources shall not be sequenced in their ResourceGroupContentItem (Release Profile 2.1, Clause 5.3.1.2(5.7a), Rule 1083-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>

   <!--PATTERN MultiProfile_CueMustHaveStartTimeOrDuration-->


	  <!--RULE -->
   <xsl:template match="//Cue" priority="1000" mode="M30">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//Cue"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="StartTime[string-length(normalize-space(text())) &gt; 0] or Duration[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="StartTime[string-length(normalize-space(text())) &gt; 0] or Duration[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error (Video): Each Cue should have a StartTime or a Duration (Release Profile 2.1, Clause 5.3.1.2(6), Rule 1084-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="@*|node()" priority="-2" mode="M30">
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MainReleaseMustHaveGridOrICPN-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release"
                 priority="1000"
                 mode="M31">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="ReleaseId/GRid[string-length(normalize-space(text())) &gt; 0] | ReleaseId/ICPN[string-length(normalize-space(text())) &gt; 0] | ReleaseId/ProprietaryId"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ReleaseId/GRid[string-length(normalize-space(text())) &gt; 0] | ReleaseId/ICPN[string-length(normalize-space(text())) &gt; 0] | ReleaseId/ProprietaryId">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): The MainRelease shall be identified by either a GRid or by an ICPN or by a ProprietaryID (Release Profile 2.1, Clause 5.3.1.3(1), Rule 1085-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="@*|node()" priority="-2" mode="M31">
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ReleaseMayHaveCLine-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release"
                 priority="1000"
                 mode="M32">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release"/>

		    <!--ASSERT Conditional Fatal Error-->
      <xsl:choose>
         <xsl:when test="CLine"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="CLine">
               <xsl:attribute name="role">Conditional Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conditional Fatal Error (Video): Each Release may have a CLine (Release Profile 2.1, Clause 5.3.1.3(6), Rule 1086-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M32"/>
   <xsl:template match="@*|node()" priority="-2" mode="M32">
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ReleaseDateMustBeProvided-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release"
                 priority="1000"
                 mode="M33">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release"/>

		    <!--ASSERT Conditional Error-->
      <xsl:choose>
         <xsl:when test="ReleaseDate | OriginalReleaseDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ReleaseDate | OriginalReleaseDate">
               <xsl:attribute name="role">Conditional Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conditional Error (Video): An OriginalReleaseDate or a ReleaseDate shall be provided for each Release (Release Profile 2.1, Clause 5.3.1.3(7), Rule 1087-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M33"/>
   <xsl:template match="@*|node()" priority="-2" mode="M33">
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ResourceGroupTypeSide-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release[//@ResourceGroupType = 'Side']"
                 priority="1000"
                 mode="M34">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release[//@ResourceGroupType = 'Side']"/>

		    <!--ASSERT Conditional Error-->
      <xsl:choose>
         <xsl:when test="*:NewReleaseMessage/DealList/ReleaseDeal[DealReleaseReference = current()/ReleaseReference]/Deal/DealTerms/UseType[text() = 'PurchaseAsPhysicalProduct']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="*:NewReleaseMessage/DealList/ReleaseDeal[DealReleaseReference = current()/ReleaseReference]/Deal/DealTerms/UseType[text() = 'PurchaseAsPhysicalProduct']">
               <xsl:attribute name="role">Conditional Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conditional Error (Video): A ResourceGroup of type Side shall only be provided for Releases that may be available with a UseType of PurchaseAsPhysicalProduct. (Release Profile 2.1, Clause 5.3.1.3(8), Rule 1088-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M34"/>
   <xsl:template match="@*|node()" priority="-2" mode="M34">
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>

   <!--PATTERN MultiProfile_SecondaryResourceMustHaveProprietaryId-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/SoundRecording[@IsSupplemental = 'true'] | *:NewReleaseMessage/ResourceList/Image"
                 priority="1000"
                 mode="M35">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/SoundRecording[@IsSupplemental = 'true'] | *:NewReleaseMessage/ResourceList/Image"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="ResourceId/ProprietaryId[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ResourceId/ProprietaryId[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): Secondary SoundRecordings and Images shall be identified with a ProprietaryId (Release Profile 2.1, Clause 5.3.1.4(2a), Rule 1089-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M35"/>
   <xsl:template match="@*|node()" priority="-2" mode="M35">
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>

   <!--PATTERN MultiProfile_NoContributorDuplicate-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/*"
                 priority="1000"
                 mode="M36">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/*"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(Contributor)=count(Contributor[not(ContributorPartyReference=preceding-sibling::Contributor/ContributorPartyReference)])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(Contributor)=count(Contributor[not(ContributorPartyReference=preceding-sibling::Contributor/ContributorPartyReference)])">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): Contributors shall be provided only once (with multiple roles) (Release Profile 2.1, Clause 5.3.1.4(6), Rule 1090-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M36"/>
   <xsl:template match="@*|node()" priority="-2" mode="M36">
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>

   <!--PATTERN MultiProfile_FirstPublicationDateMustBeProvided-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/SoundRecording[not(@IsSupplemental = 'true')] | *:NewReleaseMessage/ResourceList/Video[not(@IsSupplemental = 'true')]"
                 priority="1000"
                 mode="M37">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/SoundRecording[not(@IsSupplemental = 'true')] | *:NewReleaseMessage/ResourceList/Video[not(@IsSupplemental = 'true')]"/>

		    <!--ASSERT Conditional Error-->
      <xsl:choose>
         <xsl:when test="count(FirstPublicationDate) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(FirstPublicationDate) &gt; 0">
               <xsl:attribute name="role">Conditional Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conditional Error (Video): For each Primary Resource at least one FirstPublicationDate shall be provided (Release Profile 2.1, Clause 5.3.1.4(7), Rule 1091-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M37"/>
   <xsl:template match="@*|node()" priority="-2" mode="M37">
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>

   <!--PATTERN MultiProfile_TechnicalDetails-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/*"
                 priority="1000"
                 mode="M38">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/*"/>

		    <!--REPORT Conditional Fatal Error-->
      <xsl:if test="TechnicalDetails">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="TechnicalDetails">
            <xsl:attribute name="role">Conditional Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Conditional Fatal Error (Video): TechnicalDetails are included, so a Resource File should be communicated (Release Profile 2.1, Clause 5.3.3.3, Rule 1092-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT Conditional Fatal Error-->
      <xsl:choose>
         <xsl:when test="TechnicalDetails"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="TechnicalDetails">
               <xsl:attribute name="role">Conditional Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conditional Fatal Error (Video): TechnicalDetails are not included, so no Resource File should be communicated (Release Profile 2.1, Clause 5.3.3.3, Rule 1092-2).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M38"/>
   <xsl:template match="@*|node()" priority="-2" mode="M38">
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ChaptersMustBeReferenced-->


	  <!--RULE -->
   <xsl:template match="//Chapter/ChapterReference" priority="1000" mode="M39">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//Chapter/ChapterReference"/>

		    <!--ASSERT Warning-->
      <xsl:choose>
         <xsl:when test=".=//*[ends-with(name(),'Reference') and name()!=name(current())]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=".=//*[ends-with(name(),'Reference') and name()!=name(current())]">
               <xsl:attribute name="role">Warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Warning (Video): All ChapterReferences must have a Reference IDREF pointing to them (Release Profile 2.1, Generic Rule G.1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M39"/>
   <xsl:template match="@*|node()" priority="-2" mode="M39">
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>

   <!--PATTERN MultiProfile_CueSheetsMustBeReferenced-->


	  <!--RULE -->
   <xsl:template match="//CueSheet/CueSheetReference" priority="1000" mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//CueSheet/CueSheetReference"/>

		    <!--ASSERT Warning-->
      <xsl:choose>
         <xsl:when test=".=//*[ends-with(name(),'Reference') and name()!=name(current())]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=".=//*[ends-with(name(),'Reference') and name()!=name(current())]">
               <xsl:attribute name="role">Warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Warning (Video): All CueSheetReferences must have a Reference IDREF pointing to them (Release Profile 2.1, Generic Rule G.2).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M40"/>
   <xsl:template match="@*|node()" priority="-2" mode="M40">
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ResourcesMustBeReferenced-->


	  <!--RULE -->
   <xsl:template match="//ResourceList/*/ResourceReference"
                 priority="1000"
                 mode="M41">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ResourceList/*/ResourceReference"/>

		    <!--ASSERT Warning-->
      <xsl:choose>
         <xsl:when test=".=//*[ends-with(name(),'Reference') and name()!=name(current())]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=".=//*[ends-with(name(),'Reference') and name()!=name(current())]">
               <xsl:attribute name="role">Warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Warning (Video): All ResourceReferences must have a Reference IDREF pointing to them (Release Profile 2.1, Generic Rule G.3).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M41"/>
   <xsl:template match="@*|node()" priority="-2" mode="M41">
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>

   <!--PATTERN MultiProfile_PartiesMustBeReferenced-->


	  <!--RULE -->
   <xsl:template match="//Party/PartyReference" priority="1000" mode="M42">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//Party/PartyReference"/>

		    <!--ASSERT Warning-->
      <xsl:choose>
         <xsl:when test=".=//*[(ends-with(name(),'Reference') and name()!=name(current()) or name()='MusicRightsSociety' or name()='Label')]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=".=//*[(ends-with(name(),'Reference') and name()!=name(current()) or name()='MusicRightsSociety' or name()='Label')]">
               <xsl:attribute name="role">Warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Warning (Video): All PartyReferences must have a Reference IDREF pointing to them (Release Profile 2.1, Generic Rule G.4).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M42"/>
   <xsl:template match="@*|node()" priority="-2" mode="M42">
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ReleasesMustBeReferenced-->


	  <!--RULE -->
   <xsl:template match="//Release/ReleaseReference" priority="1000" mode="M43">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//Release/ReleaseReference"/>

		    <!--ASSERT Warning-->
      <xsl:choose>
         <xsl:when test=".=//*[ends-with(name(),'Reference') and name()!=name(current())]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=".=//*[ends-with(name(),'Reference') and name()!=name(current())]">
               <xsl:attribute name="role">Warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Warning (Video): All ReleaseReferences must have a Reference IDREF pointing to them (Release Profile 2.1, Generic Rule G.5).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M43"/>
   <xsl:template match="@*|node()" priority="-2" mode="M43">
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>

   <!--PATTERN MultiProfile_DateShouldBeBeforeDealStartDate-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms[ValidityPeriod/StartDate]"
                 priority="1000"
                 mode="M44">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms[ValidityPeriod/StartDate]"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(ReleaseDisplayStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(ReleaseDisplayStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A ReleaseDisplayStartDate may not be later than the StartDate of the Deal (Release Profile 2.1, Clause 6.4.8(a), Rule 1098-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(TrackListingPreviewStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(TrackListingPreviewStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A TrackListingPreviewStartDate may not be later than the StartDate of the Deal (Release Profile 2.1, Clause 6.4.8(a), Rule 1098-2).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(CoverArtPreviewStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(CoverArtPreviewStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A CoverArtPreviewStartDate may not be later than the StartDate of the Deal (Release Profile 2.1, Clause 6.4.8(a), Rule 1098-3).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(ClipPreviewStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(ClipPreviewStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A ClipPreviewStartDate may not be later than the StartDate of the Deal (Release Profile 2.1, Clause 6.4.8(a), Rule 1098-4).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(substring(ReleaseDisplayStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(substring(ReleaseDisplayStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A ReleaseDisplayStartDateTime may not be later than the StartDate of the Deal (Release Profile 2.1, Clause 6.4.8(a), Rule 1098-5).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(substring(TrackListingPreviewStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(substring(TrackListingPreviewStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A TrackListingPreviewStartDateTime may not be later than the StartDate of the Deal (Release Profile 2.1, Clause 6.4.8(a), Rule 1098-6).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(substring(CoverArtPreviewStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(substring(CoverArtPreviewStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A CoverArtPreviewStartDateTime may not be later than the StartDate of the Deal (Release Profile 2.1, Clause 6.4.8(a), Rule 1098-7).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(substring(ClipPreviewStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(substring(ClipPreviewStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDate,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A ClipPreviewStartDateTime may not be later than the StartDate of the Deal (Release Profile 2.1, Clause 6.4.8(a), Rule 1098-8).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M44"/>
   <xsl:template match="@*|node()" priority="-2" mode="M44">
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>

   <!--PATTERN MultiProfile_DateShouldBeBeforeDealStartDateTime-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms[ValidityPeriod/StartDateTime]"
                 priority="1000"
                 mode="M45">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms[ValidityPeriod/StartDateTime]"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(ReleaseDisplayStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(ReleaseDisplayStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A ReleaseDisplayStartDate may not be later than the StartDateTime of the Deal (Release Profile 2.1, Clause 6.4.8(b), Rule 1099-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(TrackListingPreviewStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(TrackListingPreviewStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A TrackListingPreviewStartDate may not be later than the StartDateTime of the Deal (Release Profile 2.1, Clause 6.4.8(b), Rule 1099-2).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(CoverArtPreviewStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(CoverArtPreviewStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A CoverArtPreviewStartDate may not be later than the StartDateTime of the Deal (Release Profile 2.1, Clause 6.4.8(b), Rule 1099-3).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(ClipPreviewStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(ClipPreviewStartDate,'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A ClipPreviewStartDate may not be later than the StartDateTime of the Deal (Release Profile 2.1, Clause 6.4.8(b), Rule 1099-4).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(substring(ReleaseDisplayStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(substring(ReleaseDisplayStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A ReleaseDisplayStartDateTime may not be later than the StartDateTime of the Deal (Release Profile 2.1, Clause 6.4.8(b), Rule 1099-5).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(substring(TrackListingPreviewStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(substring(TrackListingPreviewStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A TrackListingPreviewStartDateTime may not be later than the StartDateTime of the Deal (Release Profile 2.1, Clause 6.4.8(b), Rule 1099-6).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(substring(CoverArtPreviewStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(substring(CoverArtPreviewStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A CoverArtPreviewStartDateTime may not be later than the StartDateTime of the Deal (Release Profile 2.1, Clause 6.4.8(b), Rule 1099-7).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Fatal Error-->
      <xsl:if test="translate(substring(ClipPreviewStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="translate(substring(ClipPreviewStartDateTime,1,10),'-','') &gt; translate(substring(ValidityPeriod/StartDateTime,1,10),'-','')">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A ClipPreviewStartDateTime may not be later than the StartDateTime of the Deal (Release Profile 2.1, Clause 6.4.8(b), Rule 1099-8).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M45"/>
   <xsl:template match="@*|node()" priority="-2" mode="M45">
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustNotContainPriceType-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms/PriceInformation[@PriceType]"
                 priority="1000"
                 mode="M46">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms/PriceInformation[@PriceType]"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="BulkOrderWholesalePricePerUnit or WholesalePricePerUnit">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="BulkOrderWholesalePricePerUnit or WholesalePricePerUnit">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): WholesalePricePerUnit and BulkOrderWholesalePricePerUnit may not be combined with a PriceType. (Release Profile 2.1, Clause 6.4.9, Rule 1100-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M46"/>
   <xsl:template match="@*|node()" priority="-2" mode="M46">
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustContainUseType1-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms[PriceInformation/BulkOrderWholesalePricePerUnit]"
                 priority="1000"
                 mode="M47">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms[PriceInformation/BulkOrderWholesalePricePerUnit]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="UseType='PurchaseAsPhysicalProduct'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="UseType='PurchaseAsPhysicalProduct'">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): BulkOrderWholesalePricePerUnit may only be used if UseType = PurchaseAsPhysicalProduct. (Release Profile 2.1, Clause 6.4.10(a), Rule 1101-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M47"/>
   <xsl:template match="@*|node()" priority="-2" mode="M47">
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustContainUseType2-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms[CarrierType]"
                 priority="1000"
                 mode="M48">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms[CarrierType]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="UseType='PurchaseAsPhysicalProduct'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="UseType='PurchaseAsPhysicalProduct'">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): CarrierType may only be used if UseType = PurchaseAsPhysicalProduct. (Release Profile 2.1, Clause 6.4.10(b), Rule 1102-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M48"/>
   <xsl:template match="@*|node()" priority="-2" mode="M48">
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustContainUseType3-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms[PhysicalReturns]"
                 priority="1000"
                 mode="M49">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms[PhysicalReturns]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="UseType='PurchaseAsPhysicalProduct'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="UseType='PurchaseAsPhysicalProduct'">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): PhysicalReturns may only be used if UseType = PurchaseAsPhysicalProduct. (Release Profile 2.1, Clause 6.4.10(c), Rule 1103-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M49"/>
   <xsl:template match="@*|node()" priority="-2" mode="M49">
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustContainUseType4-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms[NumberOfProductsPerCarton]"
                 priority="1000"
                 mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/DealList/ReleaseDeal/Deal/DealTerms[NumberOfProductsPerCarton]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="UseType='PurchaseAsPhysicalProduct'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="UseType='PurchaseAsPhysicalProduct'">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): NumberOfProductsPerCarton may only be used if UseType = PurchaseAsPhysicalProduct. (Release Profile 2.1, Clause 6.4.10(d), Rule 1104-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M50"/>
   <xsl:template match="@*|node()" priority="-2" mode="M50">
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustContainOneTrackReleasePerPrimaryResource-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/SoundRecording[not(@IsSupplemental = 'true')] | *:NewReleaseMessage/ResourceList/Video[not(@IsSupplemental = 'true')]"
                 priority="1000"
                 mode="M51">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/SoundRecording[not(@IsSupplemental = 'true')] | *:NewReleaseMessage/ResourceList/Video[not(@IsSupplemental = 'true')]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(//TrackRelease[ReleaseResourceReference = current()/ResourceReference]) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(//TrackRelease[ReleaseResourceReference = current()/ResourceReference]) = 1">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): A Release of this type must contain exactly one TrackRelease for each Primary Resource referenced in the Main Release (Release Profile 2.1, Clause 5.1.1(b), Rule 1105-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M51"/>
   <xsl:template match="@*|node()" priority="-2" mode="M51">
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>

   <!--PATTERN MultiProfile_TrackReleaseMustNotHaveISRC-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/TrackRelease"
                 priority="1000"
                 mode="M52">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/TrackRelease"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="ReleaseId/ISRC">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="ReleaseId/ISRC">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): An ISRC as an identifier for a TrackRelease shall be communicated as a ProprietaryId (Release Profile 2.1, Clause 5.3.1.3(3), Rule 1106-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M52"/>
   <xsl:template match="@*|node()" priority="-2" mode="M52">
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>

   <!--PATTERN MultiProfile_TrackReleaseMustHaveOnePrimaryResource-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/TrackRelease"
                 priority="1000"
                 mode="M53">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/TrackRelease"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(ReleaseResourceReference) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(ReleaseResourceReference) = 1">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): A TrackRelease must refer to one Primary Resource (Release Profile 2.1, Clause 5.6(2a), Rule 1107-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M53"/>
   <xsl:template match="@*|node()" priority="-2" mode="M53">
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>

   <!--PATTERN MultiProfile_TrackReleaseMustNotHaveSecondaryResources-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/SoundRecording[@IsSupplemental = 'true'] | *:NewReleaseMessage/ResourceList/Video[@IsSupplemental = 'true'] | *:NewReleaseMessage/ResourceList/Image | *:NewReleaseMessage/ResourceList/Text | *:NewReleaseMessage/ResourceList/SheetMusic | *:NewReleaseMessage/ResourceList/Software"
                 priority="1000"
                 mode="M54">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/SoundRecording[@IsSupplemental = 'true'] | *:NewReleaseMessage/ResourceList/Video[@IsSupplemental = 'true'] | *:NewReleaseMessage/ResourceList/Image | *:NewReleaseMessage/ResourceList/Text | *:NewReleaseMessage/ResourceList/SheetMusic | *:NewReleaseMessage/ResourceList/Software"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="ResourceReference[text() = //TrackRelease/ReleaseResourceReference]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="ResourceReference[text() = //TrackRelease/ReleaseResourceReference]">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A TrackRelease must not refer to a Secondary Resource (Release Profile 2.1, Clause 5.6(2b), Rule 1108-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M54"/>
   <xsl:template match="@*|node()" priority="-2" mode="M54">
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>

   <!--PATTERN MultiProfile_TrackReleaseMustNotHaveRedundantTitles-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/TrackRelease"
                 priority="1000"
                 mode="M55">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/TrackRelease"/>

		    <!--REPORT Error-->
      <xsl:if test="DisplayTitle = //ResourceList/*[ResourceReference = current()/ReleaseResourceReference]/DisplayTitle">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="DisplayTitle = //ResourceList/*[ResourceReference = current()/ReleaseResourceReference]/DisplayTitle">
            <xsl:attribute name="role">Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Error (Video): Title information for TrackReleases shall only be provided if it differs from the title information provided on the Resource (Release Profile 2.1, Clause 5.6(4), Rule 1109-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Error-->
      <xsl:if test="DisplayTitleText = //ResourceList/*[ResourceReference = current()/ReleaseResourceReference]/DisplayTitleText">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="DisplayTitleText = //ResourceList/*[ResourceReference = current()/ReleaseResourceReference]/DisplayTitleText">
            <xsl:attribute name="role">Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Error (Video): Title information for TrackReleases shall only be provided if it differs from the title information provided on the Resource (Release Profile 2.1, Clause 5.6(4), Rule 1109-2).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT Error-->
      <xsl:if test="AdditionalTitle = //ResourceList/*[ResourceReference = current()/ReleaseResourceReference]/AdditionalTitle">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="AdditionalTitle = //ResourceList/*[ResourceReference = current()/ReleaseResourceReference]/AdditionalTitle">
            <xsl:attribute name="role">Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Error (Video): Title information for TrackReleases shall only be provided if it differs from the title information provided on the Resource (Release Profile 2.1, Clause 5.6(4), Rule 1109-3).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M55"/>
   <xsl:template match="@*|node()" priority="-2" mode="M55">
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>

   <!--PATTERN VideoSingle_ReleaseProfileVersionId-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage" priority="1000" mode="M56">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*:NewReleaseMessage"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="@ReleaseProfileVersionId = 'Video'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ReleaseProfileVersionId = 'Video'">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): The ReleaseProfileVersionId should be 'Video' (Release Profile 2.1, Clause 5.2.1, Rule 1110-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M56"/>
   <xsl:template match="@*|node()" priority="-2" mode="M56">
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>

   <!--PATTERN MultiProfile_ReleaseProfileVariantVersionId-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage[@ReleaseProfileVariantVersionId]"
                 priority="1000"
                 mode="M57">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage[@ReleaseProfileVariantVersionId]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="@ReleaseProfileVariantVersionId = 'BoxedSet' or @ReleaseProfileVariantVersionId = 'Classical' or @ReleaseProfileVariantVersionId = 'BoxedSet Classical' or @ReleaseProfileVariantVersionId = 'Classical BoxedSet'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ReleaseProfileVariantVersionId = 'BoxedSet' or @ReleaseProfileVariantVersionId = 'Classical' or @ReleaseProfileVariantVersionId = 'BoxedSet Classical' or @ReleaseProfileVariantVersionId = 'Classical BoxedSet'">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): The ReleaseProfileVariantVersionId should conform to clause 5.2.2 (Release Profile 2.1, Clause 5.2.2, Rule 1111-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M57"/>
   <xsl:template match="@*|node()" priority="-2" mode="M57">
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>

   <!--PATTERN MultiProfile_MustContainShortFormMusicalWorkVideo-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList" priority="1000" mode="M58">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="Video/Type[text() = 'ShortFormMusicalWorkVideo']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="Video/Type[text() = 'ShortFormMusicalWorkVideo']">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): A Release of this type must contain at least one Video of type ShortFormMusicalWorkVideo (Release Profile 2.1, Clause 5.1.2(a), Rule 1112-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M58"/>
   <xsl:template match="@*|node()" priority="-2" mode="M58">
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>

   <!--PATTERN VideoSingle_MustContainFrontCoverImage-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList[count(Video)!=1]"
                 priority="1000"
                 mode="M59">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList[count(Video)!=1]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="count(Image[Type[text() = 'FrontCoverImage']]) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(Image[Type[text() = 'FrontCoverImage']]) = 1">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): A Release of this type must contain one (and only one) Image of type FrontCoverImage (Release Profile 2.1, Clause 5.1.2(b), Rule 1113-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M59"/>
   <xsl:template match="@*|node()" priority="-2" mode="M59">
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>

   <!--PATTERN VideoSingle_MustNotContainFrontCoverImage-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList[count(Video)=1]"
                 priority="1000"
                 mode="M60">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList[count(Video)=1]"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="Image/Type[text() = 'FrontCoverImage']">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="Image/Type[text() = 'FrontCoverImage']">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): A Release of this type must not contain any Image of type FrontCoverImage (Release Profile 2.1, Clause 5.1.2(c), Rule 1114-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M60"/>
   <xsl:template match="@*|node()" priority="-2" mode="M60">
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>

   <!--PATTERN MultiProfile_TextSheetMusicSoftwareMustBeBonus-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/Text | *:NewReleaseMessage/ResourceList/SheetMusic | *:NewReleaseMessage/ResourceList/Software"
                 priority="1000"
                 mode="M61">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/Text | *:NewReleaseMessage/ResourceList/SheetMusic | *:NewReleaseMessage/ResourceList/Software"/>

		    <!--REPORT Fatal Error-->
      <xsl:if test="ResourceReference = //ResourceGroupContentItem[IsBonusResource = 'true']/ReleaseResourceReference">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="ResourceReference = //ResourceGroupContentItem[IsBonusResource = 'true']/ReleaseResourceReference">
            <xsl:attribute name="role">Fatal Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Fatal Error (Video): Text, SheetMusic and Software must be bonus resources (Release Profile 2.1, Clause 5.1.2(d), Rule 1115-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M61"/>
   <xsl:template match="@*|node()" priority="-2" mode="M61">
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>

   <!--PATTERN VideoSingle_MainReleaseType-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ReleaseList/Release"
                 priority="1000"
                 mode="M62">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ReleaseList/Release"/>

		    <!--ASSERT Warning-->
      <xsl:choose>
         <xsl:when test="ReleaseType[text() = 'Album' or text() = 'Bundle' or text() = 'ClassicalAlbum' or text() = 'ClassicalDigitalBoxedSet' or text() = 'ConcertVideo' or text() = 'DigitalBoxSetRelease' or text() = 'Documentary' or text() = 'EP' or text() = 'Episode' or text() = 'LiveEventVideo' or text() = 'MaxiSingle' or text() = 'MiniAlbum' or text() = 'Playlist' or text() = 'Season' or text() = 'Series' or text() = 'VideoAlbum' or text() = 'VideoSingle' or text() = 'UserDefined']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ReleaseType[text() = 'Album' or text() = 'Bundle' or text() = 'ClassicalAlbum' or text() = 'ClassicalDigitalBoxedSet' or text() = 'ConcertVideo' or text() = 'DigitalBoxSetRelease' or text() = 'Documentary' or text() = 'EP' or text() = 'Episode' or text() = 'LiveEventVideo' or text() = 'MaxiSingle' or text() = 'MiniAlbum' or text() = 'Playlist' or text() = 'Season' or text() = 'Series' or text() = 'VideoAlbum' or text() = 'VideoSingle' or text() = 'UserDefined']">
               <xsl:attribute name="role">Warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Warning (Video): The MainRelease must have a ReleaseType according to clause 5.1.3 (Release Profile 2.1, Clause 5.1.3, Rule 1116-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M62"/>
   <xsl:template match="@*|node()" priority="-2" mode="M62">
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>

   <!--PATTERN MultiProfile_BonusResourcesMustNotBeSequenced-->


	  <!--RULE -->
   <xsl:template match="//ResourceGroupContentItem[IsBonusResource = 'true']"
                 priority="1000"
                 mode="M63">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//ResourceGroupContentItem[IsBonusResource = 'true']"/>

		    <!--REPORT Error-->
      <xsl:if test="SequenceNumber">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="SequenceNumber">
            <xsl:attribute name="role">Error</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Error (Video): Secondary Resources shall not be sequenced in their ResourceGroupContentItem (Release Profile 2.1, Clause 5.3.1.2(5.7b), Rule 1117-1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M63"/>
   <xsl:template match="@*|node()" priority="-2" mode="M63">
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>

   <!--PATTERN MultiProfile_FrontCoverImageMustBeLinked-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/Image[Type = 'FrontCoverImage']"
                 priority="1000"
                 mode="M64">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/Image[Type = 'FrontCoverImage']"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="//Release/ResourceGroup[LinkedReleaseResourceReference = current()/ResourceReference]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//Release/ResourceGroup[LinkedReleaseResourceReference = current()/ResourceReference]">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error (Video): FrontCoverImages shall be linked from the top-level ResourceGroup's LinkedReleaseResourceReference (Release Profile 2.1, Clause 5.3.1.2(5.8), Rule 1118-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M64"/>
   <xsl:template match="@*|node()" priority="-2" mode="M64">
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>

   <!--PATTERN MultiProfile_VideoScreenCaptureMustBeLinked-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/Image[Type[text() = 'VideoScreenCapture']]"
                 priority="1000"
                 mode="M65">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/Image[Type[text() = 'VideoScreenCapture']]"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="//ResourceGroupContentItem/LinkedReleaseResourceReference[@LinkDescription = 'VideoScreenCapture' and text() = current()/ResourceReference]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//ResourceGroupContentItem/LinkedReleaseResourceReference[@LinkDescription = 'VideoScreenCapture' and text() = current()/ResourceReference]">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error (Video): VideoScreenCaptures shall be linked from the ResourceGroupContentItem by a LinkedReleaseResourceReference element with a LinkDescription of VideoScreenCapture (Release Profile 2.1, Clause 5.3.1.2(5.9), Rule 1119-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M65"/>
   <xsl:template match="@*|node()" priority="-2" mode="M65">
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>

   <!--PATTERN MultiProfile_PrimaryResourceMustHaveISRC-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/SoundRecording[not(@IsSupplemental = 'true')] | *:NewReleaseMessage/ResourceList/Video[not(@IsSupplemental = 'true')]"
                 priority="1000"
                 mode="M66">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/SoundRecording[not(@IsSupplemental = 'true')] | *:NewReleaseMessage/ResourceList/Video[not(@IsSupplemental = 'true')]"/>

		    <!--ASSERT Error-->
      <xsl:choose>
         <xsl:when test="ResourceId/ISRC[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ResourceId/ISRC[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Error (Video): Primary SoundRecordings and Videos shall be identified with an ISRC (Release Profile 2.1, Clause 5.3.1.4(1), Rule 1120-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M66"/>
   <xsl:template match="@*|node()" priority="-2" mode="M66">
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>

   <!--PATTERN MultiProfile_BonusResourceMustHaveProprietaryId-->


	  <!--RULE -->
   <xsl:template match="*:NewReleaseMessage/ResourceList/*[ResourceReference = //ResourceGroupContentItem[IsBonusResource = 'true']/ReleaseResourceReference]"
                 priority="1000"
                 mode="M67">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*:NewReleaseMessage/ResourceList/*[ResourceReference = //ResourceGroupContentItem[IsBonusResource = 'true']/ReleaseResourceReference]"/>

		    <!--ASSERT Fatal Error-->
      <xsl:choose>
         <xsl:when test="ResourceId/ProprietaryId[string-length(normalize-space(text())) &gt; 0]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ResourceId/ProprietaryId[string-length(normalize-space(text())) &gt; 0]">
               <xsl:attribute name="role">Fatal Error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Fatal Error (Video): Bonus Resources shall be identified with a ProprietaryId (Release Profile 2.1, Clause 5.3.1.4(2b), Rule 1121-1).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M67"/>
   <xsl:template match="@*|node()" priority="-2" mode="M67">
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>
</xsl:stylesheet>
