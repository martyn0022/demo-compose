<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" exclude-result-prefixes="isc hl7 sdtc">
	<!-- AlsoInclude: InformationSource.xsl LanguageSpoken.xsl -->
	
	<xsl:template match="*" mode="ePI-PersonalInformation">

		<xsl:variable name="hasLegal" select="hl7:patient/hl7:name[(@use='L' or not(@use)) and not(@nullFlavor)]"/>
		<xsl:variable name="hasAlias" select="hl7:patient/hl7:name[@use='P'] or count(hl7:patient/hl7:name[(@use='L' or not(@use)) and not(@nullFlavor)]) &gt; 1"/>
		
		<!--
			Field : Patient Name
			Target: /ClinicalDocument/recordTarget/patientRole/patient/name[@use='L']
			Source: /Container/Patient/Name
			Source: HS.SDA3.Patient Name
			StructuredMappingRef: ContactName
		-->
		<!--
			Field : Patient Alias Names
			Target: /ClinicalDocument/recordTarget/patientRole/patient/name[@use='P']
			Source: /Container/Patient/Aliases/Name
			Source: HS.SDA3.Patient Aliases.Name
			StructuredMappingRef: ContactName
		-->
		<xsl:apply-templates select="hl7:patient/hl7:name[(@use='L' or not(@use)) and not(@nullFlavor)][1]" mode="fn-T-pName-ContactName"/>
		
		<xsl:if test="$hasAlias">
			<Aliases>
				<xsl:apply-templates select="hl7:patient/hl7:name[@use='P']" mode="fn-T-pName-ContactName"/>
				<xsl:apply-templates select="hl7:patient/hl7:name[(@use='L' or not(@use)) and not(@nullFlavor)][position() &gt; 1]" mode="fn-T-pName-ContactName"/>
			</Aliases>
		</xsl:if>
		
		<xsl:if test="not($hasLegal)">
			<BlankNameReason>
				<xsl:choose>
					<xsl:when test="$hasAlias">S</xsl:when>
					<xsl:otherwise>U</xsl:otherwise>
				</xsl:choose>
			</BlankNameReason>
		</xsl:if>
		
		<!-- Language Module -->
		<xsl:apply-templates select="hl7:patient" mode="eLS-LanguageSpoken"/>

		<!--
			Field : Patient Gender
			Target: HS.SDA3.Patient Gender
			Target: /Container/Patient/Gender
			Source: /ClinicalDocument/recordTarget/patientRole/patient/administrativeGenderCode
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:patient/hl7:administrativeGenderCode" mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" select="'Gender'"/>
		</xsl:apply-templates>

		<!--
			Field : Patient BirthGender
			Target: HS.SDA3.Patient BirthGender
			Target: /Container/Patient/BirthGender
			Source: /ClinicalDocument/component/structuredBody/component/section/entry/observation[templateId/@root='2.16.840.1.113883.10.20.22.4.200']/value
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:for-each select="../../hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:entry[not(.//@negationInd='true')]/hl7:observation[hl7:templateId/@root=$ccda-BirthSexObservation]/hl7:value" >
			<xsl:apply-templates select="." mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'BirthGender'"/>
			</xsl:apply-templates>
		</xsl:for-each>

		<!--
			Field : Patient Marital Status
			Target: HS.SDA3.Patient MaritalStatus
			Target: /Container/Patient/MaritalStatus
			Source: /ClinicalDocument/recordTarget/patientRole/patient/maritalStatusCode
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:patient/hl7:maritalStatusCode" mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" select="'MaritalStatus'"/>
		</xsl:apply-templates>
		
		<!--
			Field : Patient Religion
			Target: HS.SDA3.Patient Religion
			Target: /Container/Patient/Religion
			Source: /ClinicalDocument/recordTarget/patientRole/patient/religiousAffiliationCode
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:apply-templates select="hl7:patient/hl7:religiousAffiliationCode" mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" select="'Religion'"/>
		</xsl:apply-templates>
		
		<!--
			Field : Patient Race
			Target: HS.SDA3.Patient Races
			Target: /Container/Patient/Races/Race[1]
			Source: /ClinicalDocument/recordTarget/patientRole/patient/raceCode
			StructuredMappingRef: CodeTableDetail
		-->
		<!--
			Field : Patient Additional Races
			Target: HS.SDA3.Patient Races
			Target: /Container/Patient/Races/Race[2..n]
			Source: /ClinicalDocument/recordTarget/patientRole/patient/sdtc:raceCode
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:if test="hl7:patient/hl7:raceCode or hl7:patient/sdtc:raceCode">
			<Races>
				<xsl:apply-templates select="hl7:patient/hl7:raceCode" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'Race'"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="hl7:patient/sdtc:raceCode" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'Race'"/>
				</xsl:apply-templates>
			</Races>
		</xsl:if>
		
		<!--
			Field : Patient Ethnicity
			Target: HS.SDA3.Patient EthnicGroup
			Target: /Container/Patient/EthnicGroup
			Source: /ClinicalDocument/recordTarget/patientRole/patient/ethnicGroupCode
			StructuredMappingRef: CodeTableDetail
		-->
		<xsl:if test="hl7:patient/hl7:ethnicGroupCode or hl7:patient/sdtc:ethnicGroupCode">
			<EthnicGroups>
				<xsl:apply-templates select="hl7:patient/hl7:ethnicGroupCode" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'EthnicGroup'"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="hl7:patient/sdtc:ethnicGroupCode" mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'EthnicGroup'"/>
				</xsl:apply-templates>
			</EthnicGroups>
		</xsl:if>

		<!--
			Field : Patient Date of Birth
			Target: HS.SDA3.Patient BirthTime
			Target: /Container/Patient/BirthTime
			Source: /ClinicalDocument/recordTarget/patientRole/patient/birthTime/@value
		-->
		<xsl:apply-templates select="hl7:patient/hl7:birthTime" mode="fn-I-timestamp">
			<xsl:with-param name="emitElementName" select="'BirthTime'"/>
		</xsl:apply-templates>

		<!--
			Field : Patient Information Source
			Target: HS.SDA3.Patient EnteredAt
			Target: /Container/Patient/EnteredAt
			Source: /ClinicalDocument/recordTarget/patientRole/providerOrganization
			Source: /ClinicalDocument/author[not(assignedAuthor/assignedAuthoringDevice)]
			StructuredMappingRef: EnteredAt
		-->
		<xsl:choose>
			<xsl:when test="hl7:providerOrganization">
				<xsl:apply-templates select="hl7:providerOrganization" mode="fn-EnteredAt"/>
			</xsl:when>
			<xsl:when test="$defaultAuthorRootPath">
				<xsl:apply-templates select="$defaultAuthorRootPath" mode="fn-EnteredAt"/>
			</xsl:when>
		</xsl:choose>
		

		<!--
			Field : Patient Birth Place
			Target: HS.SDA3.Patient BirthPlace
			Target: /Container/Patient/BirthPlace
			Source: /ClinicalDocument/recordTarget/patientRole/patient/birthplace/place/addr
		-->
		<xsl:apply-templates select="hl7:patient/hl7:birthplace//hl7:place/hl7:addr" mode="fn-T-pName-address">
			<xsl:with-param name="emitElementName" select="'BirthPlace'"/>
		</xsl:apply-templates>

		<!-- Patient Numbers -->
		<xsl:apply-templates select="." mode="ePI-PatientNumbers"/>
		
		<!-- Patient Addresses -->
		<xsl:apply-templates select="." mode="fn-W-Addresses"/>
		
		<!--
			Field : Patient Contact Information
			Target: HS.SDA3.Patient ContactInfo
			Target: /Container/Patient/ContactInfo
			Source: /ClinicalDocument/recordTarget/patientRole
			StructuredMappingRef: ContactInfo
		-->
		<xsl:apply-templates select="." mode="fn-T-pName-ContactInfo"/>

		<!--
			Field : Patient Deceased Indicator
			Target: HS.SDA3.Patient IsDead
			Target: /Container/Patient/IsDead
			Source: /ClinicalDocument/recordTarget/patientRole/patient/sdtc:deceasedInd
		-->
		<IsDead><xsl:value-of select="hl7:patient/sdtc:deceasedInd/@value"/></IsDead>

		<!--
			Field : Patient Deceased Time
			Target: HS.SDA3.Patient DeathTime
			Target: /Container/Patient/DeathTime
			Source: /ClinicalDocument/recordTarget/patientRole/patient/sdtc:deceasedTime/@value
		-->
		<xsl:apply-templates select="hl7:patient/sdtc:deceasedTime" mode="fn-I-timestamp">
			<xsl:with-param name="emitElementName" select="'DeathTime'"/>
		</xsl:apply-templates>

		
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode"><xsl:with-param name="informationType" select="'Patient'"/></xsl:call-template>
		
		<!-- Information Source module -->
		<xsl:apply-templates select="$input" mode="eIS-InformationSource"/>
		<!--<xsl:apply-templates select="/hl7:ClinicalDocument/hl7:effectiveTime" mode="fn-EnteredOn"/>-->
		
		<!-- Custom SDA Data-->
		<xsl:apply-templates select="." mode="ePI-ImportCustom-PersonalInformation"/>
	</xsl:template>

	<xsl:template match="*" mode="ePI-PatientNumbers">
		<!--
			Field : Person ID
			Target: HS.SDA3.Patient PatientNumbers.PatientNumber.Number
			Target: /Container/Patient/PatientNumbers/PatientNumber[NumberType='MRN']/Number
			Source: /ClinicalDocument/recordTarget/patientRole/patient/id/@extension
		-->
		<!--
			Field : Person ID Assigning Authority Code
			Target: HS.SDA3.Patient PatientNumbers.PatientNumber.Organization.Code
			Target: /Container/Patient/PatientNumbers/PatientNumber[NumberType='MRN']/Organization/Code
			Source: /ClinicalDocument/recordTarget/patientRole/patient/id/@root
		-->
		<PatientNumbers><xsl:apply-templates select="hl7:id" mode="ePI-PatientNumber"/></PatientNumbers>
	</xsl:template>

	<xsl:template match="hl7:id" mode="ePI-PatientNumber">
		<PatientNumber>
			<Number><xsl:value-of select="@extension"/></Number>
			<Organization>
				<Code>
					<xsl:apply-templates select="." mode="fn-code-for-oid"><xsl:with-param name="OID" select="@root"/></xsl:apply-templates>
				</Code>
				<Description><xsl:value-of select="isc:evaluate('getDescriptionForOID', @root, 'AssigningAuthority')"/></Description>
			</Organization>
			<NumberType>
				<xsl:choose>
					<xsl:when test="@root='2.16.840.1.113883.4.1'">SSN</xsl:when>
					<xsl:otherwise>MRN</xsl:otherwise>
				</xsl:choose>
			</NumberType>
			<ISOAssigningAuthority><xsl:value-of select="@assigningAuthorityName"/></ISOAssigningAuthority>
		</PatientNumber>
	</xsl:template>

	<!--
		This empty template may be overridden with custom logic.
		The input node spec is hl7:ClinicalDocument/hl7:recordTarget/hl7:patientRole.
	-->
	<xsl:template match="*" mode="ePI-ImportCustom-PersonalInformation">
	</xsl:template>
	
</xsl:stylesheet>