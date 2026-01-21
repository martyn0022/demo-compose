<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="hl7:patient" mode="eLS-LanguageSpoken">
		<!--
			Field : Patient Primary Language
			Target: HS.SDA3.Patient PrimaryLanguage.Code
			Target: /Container/Patient/PrimaryLanguage/Code
			Source: /ClinicalDocument/recordTarget/patientRole/patient/languageCommunication[preferenceInd/@value = 'true']/languageCode/@code
		-->
		<xsl:apply-templates select="hl7:languageCommunication[hl7:preferenceInd/@value = 'true']/hl7:languageCode" mode="eLS-Language"/>
		
		<!--
			Field : Patient Other Languages
			Target: HS.SDA3.Patient OtherLanguages.PatientLanguage.Code
			Target: /Container/Patient/OtherLanguages/PatientLanguage/Code
			Source: /ClinicalDocument/recordTarget/patientRole/patient/languageCommunication[preferenceInd/@value != 'true']/languageCode/@code
		-->
		<xsl:if test="hl7:languageCommunication[hl7:preferenceInd/@value != 'true']">
			<OtherLanguages>
				<xsl:apply-templates select="hl7:languageCommunication[hl7:preferenceInd/@value != 'true']/hl7:languageCode" mode="eLS-PatientLanguage"/>
			</OtherLanguages>
		</xsl:if>				
	</xsl:template>
	
	<xsl:template match="hl7:languageCode" mode="eLS-Language">
		<xsl:param name="languageType" select="'PrimaryLanguage'"/>
		
		<xsl:apply-templates select="." mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" select="$languageType"/>
		</xsl:apply-templates>
	</xsl:template>	
	
	<xsl:template match="hl7:languageCode" mode="eLS-PatientLanguage">
		<PatientLanguage>
			<xsl:apply-templates select="." mode="eLS-Language">
				<xsl:with-param name="languageType" select="'PreferredLanguage'"/>
			</xsl:apply-templates>

			<!--
				Field : Patient Language Mode Code
				Target: HS.SDA3.Patient OtherLanguages.PatientLanguage.LanguageModeCode
				Target: /Container/Patient/OtherLanguages/PatientLanguage/LanguageModeCode
				Source: /ClinicalDocument/recordTarget/patientRole/patient/languageCommunication/modeCode
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="../hl7:modeCode" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'LanguageModeCode'"/>
			</xsl:apply-templates>

			<!--
				Field : Patient Language Proficiency Level
				Target: HS.SDA3.Patient OtherLanguages.PatientLanguage.LanguageProficiencyLevel
				Target: /Container/Patient/OtherLanguages/PatientLanguage/LanguageProficiencyLevel
				Source: /ClinicalDocument/recordTarget/patientRole/patient/languageCommunication/proficiencyLevelCode
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="../hl7:proficiencyLevelCode" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'LanguageProficiencyLevel'"/>
			</xsl:apply-templates>

			<!--
				Field : Patient Language Preferred
				Target: HS.SDA3.Patient OtherLanguages.PatientLanguage.Preferred
				Target: /Container/Patient/OtherLanguages/PatientLanguage/Preferred
				Source: /ClinicalDocument/recordTarget/patientRole/patient/languageCommunication/preferenceInd
			-->
			<Preferred><xsl:value-of select="../hl7:preferenceInd/@value"/></Preferred>

		</PatientLanguage>
	</xsl:template>
	
</xsl:stylesheet>