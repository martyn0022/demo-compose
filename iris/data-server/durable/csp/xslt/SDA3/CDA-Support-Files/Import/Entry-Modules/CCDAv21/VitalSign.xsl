<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns:isc="http://extension-functions.intersystems.com" exclude-result-prefixes="isc hl7 xsi">
	<!-- AlsoInclude: Comment.xsl -->
	
	<xsl:template match="hl7:entry" mode="eVS-VitalSign">
		<!--
			Field : Vital Sign Observation
			Target: HS.SDA3.Observation
			Target: /Container/Observations/Observation
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/observation
			StructuredMappingRef: eVS-Observation-Detail
		-->
		<xsl:apply-templates
			select="hl7:organizer/hl7:component/hl7:observation[not(@negationInd='true')]"
			mode="eVS-Observation-Detail">
			<!--
				Field : Vital Sign Encounter
				Target: HS.SDA3.Observation EncounterNumber
				Target: /Container/Observations/Observation/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.4.1']/entry/organizer/component/encounter/id
				Note  : If the CDA encounter link @extension is present then
						it is imported to SDA EncounterNumber.  Otherwise if
						the encounter link @root is present then it is used.
						If there is no encounter link on the CDA Vital Sign and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->
			<xsl:with-param name="encounterNum"><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="hl7:observation" mode="eVS-OutcomeObservation-Detail">
		<!-- The mode is specifically for Health Status Evaluation and Outcome section -->
		
		<!--
			StructuredMapping: OutcomeObservation-Detail

			Field
			Target: HS.SDA3.Observation EnteredBy
			Target: ./EnteredBy
			Source: author
			StructuredMappingRef: EnteredByDetail

			Field
			Target: HS.SDA3.Observation ExternalId
			Target: ./ExternalId
			Source: ./id
			StructuredMappingRef: ExternalId

			Field
			Target: HS.SDA3.Observation ObservationTime
			Target: ./ObservationTime
			Source: ./effectiveTime

			Field
			Target: HS.SDA3.Observation ObservationCode
			Target: ./ObservationCode
			Source: ./code
			StructuredMappingRef: CodeTableDetail

			Field
			Target: HS.SDA3.Observation ObservationCode.ObservationValueUnits
			Target: ./ObservationCode/ObservationValueUnits
			Source: ./value/@unit

			Field
			Target: HS.SDA3.Observation ObservationValue
			Target: ./ObservationValue
			Source: ./value/@value
			Note  : If the Result Value Unit is not available then the
					Result Value is imported from CDA value/text() instead
					of value/@value.

			Field
			Target: HS.SDA3.Observation Status
 			Target: ./Status
			Source: ./statusCode/@code
		-->
		<Observation>			
			<xsl:apply-templates select="hl7:author" mode="fn-EnteredBy"/>			
			
			<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>
			
			<xsl:apply-templates select="." mode="fn-ExternalId"/>
			
			<xsl:apply-templates select="hl7:performer" mode="fn-Clinician"/>
			
			<xsl:apply-templates select="hl7:effectiveTime" mode="fn-I-timestamp">
				<xsl:with-param name="emitElementName" select="'ObservationTime'"/>
			</xsl:apply-templates>			
			
			<xsl:apply-templates select="." mode="eVS-ObservationCode" />
			
			<xsl:apply-templates select="hl7:value" mode="eVS-ObservationValue"/>			

			<xsl:apply-templates select="hl7:statusCode" mode="eVS-ObservationStatus"/>			

		</Observation>
	</xsl:template>

	<xsl:template match="hl7:organizer[@classCode='CLUSTER']" mode="eVS-ObservationGroup">
		<!--
    		StructuredMapping: eVS-Observation-Organizer

			Field: Observation Organizer Mapping
			Target: HS.SDA3.Observation
			Target: /Container/Observations/Observation
			Source: /ClinicalDocument/component/structuredBody/component/section/entry/organizer[@classCode='CLUSTER']

			Field
			Target: HS.SDA3.Observation ExternalId
			Target: ./ExternalId
			Source: ./id
			StructuredMappingRef: ExternalId

			Field
			Target: HS.SDA3.Observation ObservationTime
			Target: ./ObservationTime
			Source: ./effectiveTime

			Field
			Target: HS.SDA3.Observation ObservationGroupCode
			Target: ./ObservationGroupCode
			Source: ./code
			StructuredMappingRef: CodeTableDetail

			Field
			Target: HS.SDA3.Observation Status
 			Target: ./Status
			Source: ./statusCode/@code

			Note: ObservationGroupCode is set to 85353-1 and Status is always 'F' for the vital sign panel.

		-->
		<ObservationGroup>
			<xsl:apply-templates select="." mode="fn-ExternalId" />
			<xsl:apply-templates select="hl7:effectiveTime" mode="fn-I-timestamp">
				<xsl:with-param name="emitElementName" select="'ObservationTime'" />
			</xsl:apply-templates>
			<ObservationGroupCode>
				<SDACodingStandard>SCT</SDACodingStandard>
				<Code>85353-1</Code>
				<Description>Vital signs, weight, height, head circumference, oxygen saturation and BMI panel</Description>
			</ObservationGroupCode>
			<Status>F</Status>
			<References>
				<xsl:for-each select="hl7:component/hl7:observation">
					<Reference>
						<SdaID>
							<xsl:value-of select="concat('obs-', count(preceding::hl7:observation) + 1)" />
						</SdaID>
					</Reference>
				</xsl:for-each>
			</References>
		</ObservationGroup>
	</xsl:template>

	<xsl:template match="hl7:observation" mode="eVS-Observation-Detail">
		<!-- The mode formerly known as VitalSignDetail -->
		<xsl:param name="encounterNum"/>
		
		<!--
			StructuredMapping: eVS-Observation-Detail

			Field
			Target: HS.SDA3.Observation EnteredBy
			Target: ./EnteredBy
			Source: ./author
			StructuredMappingRef: EnteredByDetail
			Note  : If there is no author data at the CDA observation level
					then the CDA organizer level is used for the author data.

			Field
			Target: HS.SDA3.Observation Clinician
			Target: ./Clinician
			Source: ./author
			StructuredMappingRef: Clinician

			Field
			Target: HS.SDA3.Observation EnteredOn
			Target: ./EnteredOn
			Source: ./author/time/@value
			Note  : If there is no author data at the CDA observation level
					then the CDA organizer level is used for the author data.

			Field
			Target: HS.SDA3.Observation ExternalId
			Target: ./ExternalId
			Source: ./id
			StructuredMappingRef: ExternalId

			Field
			Target: HS.SDA3.Observation Clinician
			Target: ./Clinician
			Source: ./performer
			StructuredMappingRef: Clinician

			Field
			Target: HS.SDA3.Observation ObservationTime
			Target: ./ObservationTime
			Source: ./effectiveTime

			Field
			Target: HS.SDA3.Observation ObservationCode
			Target: ./ObservationCode
			Source: ./code
			StructuredMappingRef: CodeTableDetail

			Field
			Target: HS.SDA3.Observation ObservationCode.ObservationValueUnits
			Target: ./ObservationCode/ObservationValueUnits
			Source: ./value/@unit

			Field
			Target: HS.SDA3.Observation ObservationValue
			Target: ./ObservationValue
			Source: ./value/@value
			Note  : If the Result Value Unit is not available then the
					Result Value is imported from CDA value/text() instead
					of value/@value.

			Field
			Target: HS.SDA3.Observation Status
 			Target: ./Status
			Source: ./statusCode/@code

			Field
			Target: HS.SDA3.Observation Comments
			Target: ./Comments
			Source: ./entryRelationship/act[code/@code='48767-8']/text

			Field
			Target: HS.SDA3.Observation ReferenceRange
			Target: ./ReferenceRange
			Source: ./referenceRange/observationRange/value

			Field
			Target: HS.SDA3.Observation InterpretationCode
			Target: ./InterpretationCode
			Source: ./interpretationCode

			Field
			Target: HS.SDA3.Observation ObservationMethods
			Target: ./ObservationMethods
			Source: ./methodCode

			Field
			Target: HS.SDA3.Observation TargetSiteCode
			Target: ./TargetSiteCode
			Source: ./targetSiteCode

		-->

		<Observation>
			<EncounterNumber><xsl:value-of select="$encounterNum"/></EncounterNumber>
			
			<SdaID>
				<xsl:value-of select="concat('obs-', count(preceding::hl7:observation) + 1)" />
			</SdaID>

			<xsl:choose>
				<xsl:when test="hl7:author">
					<xsl:apply-templates select="hl7:author" mode="eVS-AuthorDetail" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="../.." mode="fn-EnteredBy"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:choose>
				<xsl:when test="hl7:informant">
					<xsl:apply-templates select="." mode="fn-EnteredAt"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="../.." mode="fn-EnteredAt"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:choose>
				<xsl:when test="hl7:author">
					<xsl:apply-templates select="hl7:author/hl7:time" mode="fn-EnteredOn"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="../../hl7:author/hl7:time" mode="fn-EnteredOn"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:apply-templates select="." mode="fn-ExternalId"/>
			
			<xsl:apply-templates select="hl7:performer" mode="fn-Clinician"/>
			
			<xsl:apply-templates select="hl7:effectiveTime" mode="fn-I-timestamp">
				<xsl:with-param name="emitElementName" select="'ObservationTime'"/>
			</xsl:apply-templates>			
			
			<xsl:apply-templates select="." mode="eVS-ObservationCode" />
			
			<xsl:apply-templates select="hl7:value" mode="eVS-ObservationValue"/>
			
			<xsl:apply-templates select="hl7:statusCode" mode="eVS-ObservationStatus"/>			

			<xsl:apply-templates select="." mode="eCm-Comment"/>

			<xsl:choose>
				<xsl:when
					test="count(hl7:referenceRange/hl7:observationRange | 
                           hl7:entryRelationship/hl7:observation/hl7:referenceRange/hl7:observationRange) > 1">
					<xsl:apply-templates
						select="hl7:referenceRange/hl7:observationRange[hl7:interpretationCode/@code='N'] | 
                    hl7:entryRelationship/hl7:observation/hl7:referenceRange/hl7:observationRange[hl7:interpretationCode/@code='N']"
						mode="eVS-ObservationRange" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates
						select="hl7:referenceRange/hl7:observationRange | 
                    hl7:entryRelationship/hl7:observation/hl7:referenceRange/hl7:observationRange"
						mode="eVS-ObservationRange" />
				</xsl:otherwise>
			</xsl:choose>

			<xsl:apply-templates select="hl7:interpretationCode" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'InterpretationCode'" />
			</xsl:apply-templates>

			<xsl:if test="hl7:methodCode">
				<ObservationMethods>
					<xsl:apply-templates select="hl7:methodCode" mode="fn-CodeTable">
						<xsl:with-param name="hsElementName" select="'ObservationMethod'" />
					</xsl:apply-templates>
				</ObservationMethods>
			</xsl:if>

			<xsl:apply-templates select="hl7:targetSiteCode" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'TargetSiteCode'" />
			</xsl:apply-templates>
			
			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="eVS-ImportCustom-VitalSign"/>
		</Observation>
	</xsl:template>
	
	<xsl:template match="hl7:value" mode="eVS-ObservationValue">
		<ObservationValue>
			<xsl:choose>
				<xsl:when test="@xsi:type = 'PQ'"><xsl:value-of select="@value"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="text()"/></xsl:otherwise>
			</xsl:choose>
		</ObservationValue>
	</xsl:template>

	<xsl:template match="hl7:observation" mode="eVS-ObservationCode">
		<xsl:apply-templates select="hl7:code" mode="fn-CodeTable">
			<xsl:with-param name="hsElementName" select="'ObservationCode'"/>
			<xsl:with-param name="observationValueUnits">
				<xsl:if test="hl7:value/@xsi:type = 'PQ' and string-length(hl7:value/@unit)">
					<xsl:value-of select="hl7:value/@unit"/>
				</xsl:if>
			</xsl:with-param>
			<xsl:with-param name="importOriginalText" select="'1'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="hl7:statusCode" mode="eVS-ObservationStatus">
		<xsl:if test="@code">
			<Status>
				<xsl:choose>
					<xsl:when test="@code = 'completed'">F</xsl:when>
					<xsl:when test="@code = 'active'">I</xsl:when>
					<xsl:when test="@code = 'held'">I</xsl:when>
					<xsl:when test="@code = 'suspended'">I</xsl:when>
					<xsl:when test="@code = 'cancelled'">X</xsl:when>
					<xsl:when test="@code = 'aborted'">X</xsl:when>
					<xsl:otherwise>F</xsl:otherwise>
				</xsl:choose>
			</Status>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:observationRange" mode="eVS-ObservationRange">
		<xsl:if test="hl7:value and (hl7:value/@xsi:type = 'IVL_PQ')">
			<xsl:call-template name="fn-ValueRange">
				<xsl:with-param name="elementName" select="'ReferenceRange'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name='referenceRangeText'>
			<xsl:choose>
				<xsl:when test="hl7:value and hl7:value/@xsi:type='ST'">
					<xsl:value-of select="hl7:value" />
				</xsl:when>
				<xsl:when test="hl7:text">
					<xsl:value-of select="hl7:text" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($referenceRangeText)">
			<ReferenceRange>
				<Text>
					<xsl:value-of select="$referenceRangeText" />
				</Text>
			</ReferenceRange>
		</xsl:if>
	</xsl:template>

	<!--
		This empty template may be overridden with custom logic.
		The input node spec is normally $sectionRootPath/hl7:entry/hl7:observation.
	-->
	<xsl:template match="*" mode="eVS-ImportCustom-VitalSign">
	</xsl:template>

	<xsl:template match="hl7:observation" mode="eVS-PregnancyObservation">
		<Observation>
			<!-- 
				Target: HS.SDA3.Observation ObservationTime
				Target: ./ObservationTime
				Source: ./effectiveTime
				Note  : Pregnancy Observation CDA effectiveTime should have only a single
							value, but it is legal to have a high and a low value.
							When importing to SDA ObservationTime, use the first found
							of effectiveTime/@value, effectiveTime/low/@value,
							effectiveTime/high/@value.
			-->
			<xsl:choose>
				<xsl:when test="hl7:effectiveTime/@value">
					<xsl:apply-templates select="hl7:effectiveTime/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'ObservationTime'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="hl7:effectiveTime/hl7:low/@value">
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'ObservationTime'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="hl7:effectiveTime/hl7:high/@value">
					<xsl:apply-templates select="hl7:effectiveTime/hl7:high/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'ObservationTime'"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>

			<ObservationCode>
				<xsl:choose>
					<xsl:when test="@moodCode = 'EVN'">
						<Code>82810-3</Code>
						<Description>Pregnancy status</Description>
					</xsl:when>
					<xsl:when test="@moodCode = 'INT'">
						<Code>86645-9</Code>
						<Description>Pregnancy intent</Description>
					</xsl:when>
				</xsl:choose>
				<SDACodingStandard>LN</SDACodingStandard>
			</ObservationCode>

			<!--
				Target: HS.SDA3.Observation ObservationCodedValue
				Target: HS.SDA3.Observation DataAbsentReason
				Target: ./ObservationCodedValue
				Target: ./DataAbsentReason
				Source: ./value
			-->
			<xsl:choose>
				<xsl:when test="hl7:value/@nullFlavor='UNK'">
					<ObservationCodedValue>
						<SDACodingStandard>http://terminology.hl7.org/CodeSystem/v3-NullFlavor</SDACodingStandard>
						<Code>UNK</Code>
						<Description>Unknown</Description>
					</ObservationCodedValue>
				</xsl:when>
				<xsl:when test="not(string-length(hl7:value/@code)) or (hl7:value/@nullFlavor)">
					<DataAbsentReason>
						<SDACodingStandard>http://terminology.hl7.org/CodeSystem/v3-NullFlavor</SDACodingStandard>
						<Code>
							<xsl:value-of select="hl7:value/@nullFlavor" />
						</Code>
					</DataAbsentReason>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:value" mode="fn-CodeTable">
						<xsl:with-param name="hsElementName" select="'ObservationCodedValue'" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>

			<!--
				Target: HS.SDA3.Observation EstimatedDOD
				Target: ./EstimatedDOD
				Source: ./hl7:observation[hl7:code/@code='11778-8']/hl7:value
			-->
			<xsl:if test="hl7:entryRelationship/hl7:observation[hl7:code/@code='11778-8']/hl7:value/@value">
				<xsl:variable name="timestamp">
					<xsl:value-of select="isc:evaluate('xmltimestamp', hl7:entryRelationship/hl7:observation[hl7:code/@code='11778-8']/hl7:value/@value)"/>
				</xsl:variable>

				<EstimatedDOD>
					<xsl:choose>
						<xsl:when test="string-length($timestamp)">
							<xsl:value-of select="$timestamp"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="hl7:entryRelationship/hl7:observation[hl7:code/@code='11778-8']/hl7:value/@value"/>
						</xsl:otherwise>
					</xsl:choose>
				</EstimatedDOD>
			 </xsl:if>

			<Categories>
				<Category>
					<SDACodingStandard>http://terminology.hl7.org/CodeSystem/observation-category</SDACodingStandard>
					<Code>social-history</Code>
					<Description>Social History</Description>
				</Category>
			</Categories>

			<!-- Since the C-CDA 2.1 specification requires that code="completed", we can import it to SDA as "F" (final) to ensure correct export to FHIR. -->
			<Status>F</Status>
		</Observation>
	</xsl:template>

	<xsl:template match="hl7:observation" mode="eVS-ProblemObservation">
		<Observation>
			<!--
				Field : Observation SdaId
				Target: HS.SDA3.Observation SupportingObservation
				Target: /Container/Observation/Observation/SdaId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='SPRT']/observation/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='SPRT']/observation/id
			-->
			<xsl:apply-templates select="hl7:id" mode="fn-SdaId"/>

			<!--
				Field : Observation Code
				Target: HS.SDA3.Observation ObservationCode
				Target: /Container/Observation/Observation/ObservationCode
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='SPRT']/observation/code
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='SPRT']/observation/code
			-->
			<xsl:apply-templates select="." mode="eVS-ObservationCode" />

			<!--
				Field : Observation Time
				Target: HS.SDA3.Observation ObservationTime
				Target: /Container/Observation/Observation/ObservationTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='SPRT']/observation/effectiveTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='SPRT']/observation/effectiveTime
			-->
			<xsl:apply-templates select="hl7:effectiveTime" mode="fn-I-timestamp">
				<xsl:with-param name="emitElementName" select="'ObservationTime'"/>
			</xsl:apply-templates>

			<!--
				Field : Observation Coded Value
				Target: HS.SDA3.Observation ObservationCodedValue
				Target: /Container/Observation/Observation/ObservationCodedValue
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='SPRT']/observation/value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='SPRT']/observation/value
			-->
			<xsl:choose>
				<xsl:when test="not(string-length(hl7:value/@code)) or (hl7:value/@nullFlavor)">
					<ObservationCodedValue>
						<SDACodingStandard>http://terminology.hl7.org/CodeSystem/v3-NullFlavor</SDACodingStandard>
						<Code>UNK</Code>
						<Description>Unknown</Description>
					</ObservationCodedValue>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="hl7:value" mode="fn-CodeTable">
						<xsl:with-param name="hsElementName" select="'ObservationCodedValue'"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>

			<!--
				Field : Observation Status
				Target: HS.SDA3.Observation Status
				Target: /Container/Observation/Observation/Status
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.5.1']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='SPRT']/observation/statusCode
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.20']/entry/act/entryRelationship/observation/entryRelationship[@typeCode='SPRT']/observation/statusCode
			-->
			<xsl:apply-templates select="hl7:statusCode" mode="eVS-ObservationStatus"/>

		</Observation>
	</xsl:template>

	<!-- 
		Field:	Observation Clinician
		Target: HS.SDA3.Observation Clinician
		Target: ./Clinician
		Source: ./author
	-->
	<xsl:template match="hl7:author" mode="eVS-AuthorDetail">
		<Clinician>
			<xsl:apply-templates select="hl7:assignedAuthor/hl7:assignedPerson/hl7:name"
				mode="fn-T-pName-ContactName" />
			<xsl:if test="hl7:assignedAuthor/hl7:representedOrganization/hl7:name">
				<AtOrganization>
					<Description>
						<xsl:value-of select="hl7:assignedAuthor/hl7:representedOrganization/hl7:name" />
					</Description>
				</AtOrganization>
			</xsl:if>
			<xsl:apply-templates select="hl7:assignedAuthor/hl7:addr"
				mode="fn-T-pName-address">
			</xsl:apply-templates>
			<xsl:apply-templates select="hl7:assignedAuthor" mode="fn-T-pName-ContactInfo" />
			<xsl:if test="hl7:assignedAuthor/hl7:code/@code">
				<xsl:apply-templates select="hl7:assignedAuthor/hl7:code"
					mode="fn-CodeTable">
					<xsl:with-param name="hsElementName" select="'CareProviderType'" />
				</xsl:apply-templates>
			</xsl:if>
		</Clinician>
	</xsl:template>
	
</xsl:stylesheet>