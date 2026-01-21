<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="hl7">

	<xsl:template match="*" mode="sVS-VitalSignsSection">
		<xsl:apply-templates select="key('sectionsByRoot',$ccda-VitalSignsSectionEntriesOptional) | key('sectionsByRoot',$ccda-VitalSignsSectionEntriesRequired)" mode="sVS-VitalSignsSectionEntries">
			<!-- Pass Pregnancy Observations from the Social History Section of C-CDA 2.1 to the template so that they can be imported to the Observations Section of SDA. -->
			<xsl:with-param name="pregnancyObservations" select="key('sectionsByRoot',$ccda-SocialHistorySection)/hl7:entry/hl7:observation[hl7:templateId/@root=$ccda-PregnancyObservation or 
		hl7:templateId/@root='2.16.840.1.113883.10.20.22.4.281']"/>
			<!-- Pass in Reaction Observation from the Immunization Section of C-CDA 2.1 to the template so that they can be imported to the Observations Section of SDA.-->
			<xsl:with-param name="immunizationReactionObservations" select="key('sectionsByRoot',$ccda-ImmunizationsSectionEntriesOptional)/hl7:entry/hl7:substanceAdministration/hl7:entryRelationship[@typeCode='MFST']/hl7:observation"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="hl7:section" mode="sVS-VitalSignsSectionEntries">
		<xsl:param name="pregnancyObservations"/>
		<xsl:param name="immunizationReactionObservations"/>

		<xsl:variable name="isNoDataVitalSignsSection"><xsl:apply-templates select="." mode="sVS-IsNoDataSection-VitalSigns"/></xsl:variable>
		<!-- Vital Sign Panel Entries -->
		<xsl:variable name="vitalSignsPanelEntries" select="hl7:entry[hl7:organizer[@classCode='CLUSTER']]"/>
		<!-- Individual Vital Signs -->
		<xsl:variable name="vitalSignsSectionEntries" select="hl7:entry[
                (hl7:observation and not(hl7:organizer)) 
                or hl7:organizer/hl7:component/hl7:observation]" />
		<!-- Supporting Observations for Problem-->
		<xsl:variable name="supportingObservations" select="//hl7:section[(hl7:templateId/@root=$ccda-ProblemSectionEntriesOptional) or (hl7:templateId/@root=$ccda-ProblemSectionEntriesRequired)]/hl7:entry/hl7:act/hl7:entryRelationship/hl7:observation/hl7:entryRelationship[@typeCode='SPRT']/hl7:observation"/>

		<!-- Combine the entries from the Vital Signs section and the Pregnancy Observations from the Social History section. -->
		<xsl:variable name="isNoDataSection" select="($isNoDataVitalSignsSection='1') and (count($pregnancyObservations)=0) and (count($immunizationReactionObservations)=0)"/>
		<xsl:variable name="sectionEntries" select="$vitalSignsPanelEntries | $vitalSignsSectionEntries | $pregnancyObservations | $supportingObservations | $immunizationReactionObservations"/>

		<xsl:choose>
			<xsl:when test="$sectionEntries and not($isNoDataSection)">
				<xsl:if test="$vitalSignsPanelEntries">
					<ObservationGroups>
						<xsl:apply-templates select="$vitalSignsPanelEntries" mode="eVS-ObservationGroup"/>
					</ObservationGroups>
            	</xsl:if>
				<Observations>
					<xsl:apply-templates select="$vitalSignsSectionEntries" mode="sVS-VitalSigns"/>
					<xsl:apply-templates select="$pregnancyObservations" mode="eVS-PregnancyObservation"/>
					<xsl:apply-templates select="$supportingObservations" mode="eVS-ProblemObservation"/>
					<!-- Reaction Observation is being passed into ProblemObservation template as the required SDA3 Observation fields that are populated are the same -->
					<xsl:apply-templates select="$immunizationReactionObservations" mode="eVS-ProblemObservation"/>
				</Observations>
			</xsl:when>
			<xsl:when test="$isNoDataSection and $documentActionCode='XFRM'">
				<Observations>
					<xsl:apply-templates select="." mode="fn-XFRMAllEncounters">
						<xsl:with-param name="informationType" select="'Observation'"/>
					</xsl:apply-templates>
				</Observations>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="hl7:entry" mode="sVS-VitalSigns">
		<!-- Process CDA Append/Transform/Replace Directive -->
		<xsl:call-template name="ActionCode">
			<xsl:with-param name="informationType" select="'Observation'"/>
			<xsl:with-param name="encounterNumber"><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="." mode="eVS-VitalSign"/>
	</xsl:template>
	
	<!-- Determine if the Vital Signs section is present but has or indicates no data present.
		This logic is applied only if the section is present.
		The input node spec is $vitalSignSection.
		Return 1 if the section is present and there is no hl7:entry element.
		Otherwise Return 0 (section is present and appears to include vital signs data).
		
		You may override this template to use custom criteria to determine "No Data" section.
	-->
	<xsl:template match="hl7:section" mode="sVS-IsNoDataSection-VitalSigns">
		<xsl:choose>
			<xsl:when test="@nullFlavor">1</xsl:when>
			<xsl:when test="count(hl7:entry)=0">1</xsl:when>
			<xsl:when test="count(hl7:entry/hl7:organizer/hl7:component/hl7:observation[not(@negationInd='true')])=0">1</xsl:when>
			<xsl:when test="count(hl7:entry)=1 and (hl7:entry[1]/hl7:organizer[1]/hl7:component[1]/hl7:observation/hl7:code/@nullFlavor='NI' or hl7:entry[1]/hl7:organizer[1]/hl7:component[1]/hl7:observation/hl7:value/@nullFlavor='NI')">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>