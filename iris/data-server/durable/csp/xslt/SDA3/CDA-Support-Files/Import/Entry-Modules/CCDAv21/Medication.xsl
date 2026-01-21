<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:isc="http://extension-functions.intersystems.com" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="isc hl7 xsi">
	<!-- AlsoInclude: Comment.xsl -->
	
	<xsl:template match="hl7:substanceAdministration" mode="eM-Medication">
		<!--
			medicationType:
			MED    = Medication from CDA Medications, Medications Administered, or Hospital Discharge Medications
			MEDPOC = Medication from CDA Plan of Care
			VXU    = Vaccination from CDA Immunizations
		-->
		<xsl:param name="medicationType" select="'MED'"/>
		
		<xsl:variable name="elementName">
			<xsl:choose>
				<xsl:when test="$medicationType = 'MED'">Medication</xsl:when>
				<xsl:when test="$medicationType = 'MEDPOC'">Medication</xsl:when>
				<xsl:otherwise>Vaccination</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:element name="{$elementName}">
						
			<!-- 
				Medication Context 
			-->
			<xsl:if test="($medicationType != 'VXU')"> <Context>request</Context> </xsl:if>

			<!-- 
				Medication DoNotPerform 
			-->
			<xsl:if test="($medicationType != 'VXU') and (@negationInd='true')"> <DoNotPerform>true</DoNotPerform></xsl:if>

			<!-- 
				Medication RequestIntent 
			-->
			<xsl:if test="($medicationType != 'VXU') and (@moodCode = 'EVN')"> <RequestIntent><Code>plan</Code><Description>plan</Description><SDACodingStandard> http://hl7.org/fhir/ValueSet/medicationrequest-intent</SDACodingStandard></RequestIntent></xsl:if>
			<xsl:if test="($medicationType != 'VXU') and (@moodCode = 'INT')"> <RequestIntent><Code>order</Code><Description>order</Description><SDACodingStandard> http://hl7.org/fhir/ValueSet/medicationrequest-intent</SDACodingStandard></RequestIntent></xsl:if>

				
			<!--
				Field : Medication EventTime
				Target: HS.SDA3.Medication EventTime
				Target: /Container/Medications/Medication/EventTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:effectiveTime[1]/hl7:low/@value
			-->
			<xsl:if test="hl7:effectiveTime[1]/hl7:low/@value">
				<EventTime>
					<xsl:apply-templates select="hl7:effectiveTime[1]/hl7:low/@value" mode="fn-E-paramName-timestamp"/>
				</EventTime>
			</xsl:if>
			
			<!--
				Field : Medication AsNeeded
				Target: HS.SDA3.Medication AsNeeded
				Target: /Container/Medications/Medication/AsNeeded
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:precondition
			-->
			<xsl:if test="hl7:precondition"> 
				<AsNeeded>true</AsNeeded> 
			</xsl:if>
				
			<!--
				Field : Medication OrderQuantity
				Target: HS.SDA3.Medication OrderQuantity
				Target: /Container/Medications/Medication/OrderQuantity
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT']/hl7:quantity/@value
			-->
			<!--
				Field : Medication OrderUnits
				Target: HS.SDA3.Medication OrderUnits
				Target: /Container/Medications/Medication/OrderUnits
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT']/hl7:quantity/@unit
			-->	
			<xsl:if test="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT']/hl7:quantity"> 
				<OrderQuantity>
					<xsl:value-of select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT']/hl7:quantity/@value" /> 
				</OrderQuantity>
				<xsl:if test="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT']/hl7:quantity/@unit">
					<OrderUnits>
					<Code><xsl:value-of select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT']/hl7:quantity/@unit"/></Code>
					<SDACodingStandard>'http://unitsofmeasure.org'</SDACodingStandard>
				</OrderUnits>	
				</xsl:if>
			</xsl:if>
				
			<!--
				Field : Medication DispenseEndTime
				Target: HS.SDA3.Medication DispenseEndTime
				Target: /Container/Medications/Medication/DispenseEndTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']/hl7:effectiveTime/hl7:high/@value
			-->	
			<xsl:if test="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT']/hl7:effectiveTime/hl7:high/@value">
				<DispenseEndTime>
					<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT']/hl7:effectiveTime/hl7:high/@value" mode="fn-E-paramName-timestamp"/>
				</DispenseEndTime>
			</xsl:if>

			<!-- Vaccination Mappings -->
			<xsl:if test="($medicationType = 'VXU')">

				<!--
					Field : Vaccination SiteCode
					Target: HS.SDA3.Vaccination SiteCode
					Target: /Container/Vaccinations/Vaccination/SiteCode
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:approachSiteCode
				-->	
				<xsl:if test="string-length(hl7:approachSiteCode/@code)">
					<SiteCode>
						<xsl:apply-templates select="hl7:approachSiteCode" mode="fn-CodeTableDetail"/>
					</SiteCode>
				</xsl:if>
				
				<!--
					Field : Vaccination StatusReason
					Target: HS.SDA3.Vaccination StatusReason
					Target: /Container/Vaccinations/Vaccination/StatusReason
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:code
				-->	
				<xsl:if test="string-length(hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:code)">
					<StatusReason>
						<xsl:value-of select="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:code" />
					</StatusReason>
				</xsl:if>

				<!--
					Field : Vaccination Performer
					Target: HS.SDA3.Vaccination Performer
					Target: /Container/Vaccinations/Vaccination/Performer
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:performer/hl7:assignedEntity
				-->	
				<xsl:if test="string-length(hl7:performer/hl7:assignedEntity)">
					<Performer>
						<xsl:if test="hl7:performer/hl7:assignedEntity/hl7:id/@extension">
							<Code>
								<xsl:value-of select="hl7:performer/hl7:assignedEntity/hl7:id/@extension" />
							</Code>
						</xsl:if>
						<IdentifierTypeCode>AP</IdentifierTypeCode>
						<xsl:apply-templates select="hl7:performer/hl7:assignedEntity/hl7:addr" mode="fn-T-pName-address"/>									
						<xsl:apply-templates select="hl7:performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name" mode="fn-T-pName-ContactName"/>
						<xsl:if test="hl7:performer/hl7:assignedEntity/hl7:representedOrganization/hl7:name">
							<xsl:apply-templates select="hl7:performer/hl7:assignedEntity/hl7:representedOrganization/hl7:name" mode="fn-CodeTable">
								<xsl:with-param name="hsElementName" select="'AtOrganization'"/>
							</xsl:apply-templates>
						</xsl:if>
					</Performer>
				</xsl:if>
				
				<!--
					Field : Vaccination Reaction
					Target: HS.SDA3.Vaccination Reaction
					Target: /Container/Vaccinations/Vaccination/Reaction
					Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:entryRelationship[@typeCode='MFST']/hl7:observation
				-->
				<xsl:if test="hl7:entryRelationship[@typeCode='MFST']/hl7:observation">
					<Reaction>
						<xsl:apply-templates select="hl7:entryRelationship[@typeCode='MFST']/hl7:observation/hl7:id" mode="fn-SdaId"/>
						<Type>Observation</Type>
					</Reaction>
				</xsl:if>
				
				<xsl:apply-templates select="." mode="eM-AuthorTime"/>
			</xsl:if>	
				

				<!-- Dosage Steps Mappings -->

			<xsl:if test="($medicationType != 'VXU')">
				<DosageSteps><DosageStep>

					<!--
						Field : Medication Route
						Target: HS.SDA3.DosageStep Route
						Target: /Container/Medications/Medication/DosageSteps/DosageStep/Route
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:routeCode/@code
					-->
					<xsl:if test="string-length(hl7:routeCode/@code)">
						<Route>
							<xsl:apply-templates select="hl7:routeCode" mode="fn-CodeTableDetail"/>
						</Route>
					</xsl:if>

					<!--
						Field : Medication Site
						Target: HS.SDA3.DosageStep Site
						Target: /Container/Medications/Medication/DosageSteps/DosageStep/Site
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:approachSiteCode/@code
					-->
					<xsl:if test="string-length(hl7:approachSiteCode/@code)">
						<Site>
							<xsl:apply-templates select="hl7:approachSiteCode" mode="fn-CodeTableDetail"/>
						</Site>
					</xsl:if>

					<!--
						Field : Medication Frequency
						Target: HS.SDA3.DosageStep Frequency
						Target: /Container/Medications/Medication/DosageSteps/DosageStep/Frequency
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:effectiveTime[@xsi:type='PIVL_TS']
					-->
					<xsl:if test="hl7:effectiveTime[@xsi:type='PIVL_TS']">
						<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='PIVL_TS']" mode="eM-Frequency"/>
					</xsl:if>
					
					<!--
						Field : Medication MaxDoseNumerator
						Target: HS.SDA3.DosageStep MaxDoseNumerator
						Target: /Container/Medications/Medication/DosageSteps/DosageStep/MaxDoseNumerator
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:maxDoseQuantity/hl7:numerator
					-->
					<xsl:if test="hl7:maxDoseQuantity/hl7:numerator[not(@nullFlavor)]">
						<MaxDoseNumerator>
							<Value>
								<xsl:value-of select="hl7:maxDoseQuantity/hl7:numerator/@value"/>
							</Value>
							<UnitOfMeasure>
								<xsl:if test="hl7:maxDoseQuantity/hl7:numerator/@code">
									<Code><xsl:value-of select="hl7:maxDoseQuantity/hl7:numerator/@code"/></Code>
								</xsl:if>
								<xsl:if test="hl7:maxDoseQuantity/hl7:numerator/@unit">
									<Description><xsl:value-of select="hl7:maxDoseQuantity/hl7:numerator/@unit"/></Description>
								</xsl:if>
							</UnitOfMeasure>
						</MaxDoseNumerator>
					</xsl:if>
					
					<!--
						Field : Medication MaxDoseDenominator
						Target: HS.SDA3.DosageStep MaxDoseDenominator
						Target: /Container/Medications/Medication/DosageSteps/DosageStep/MaxDoseDenominator
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:maxDoseQuantity/hl7:denominator
					-->
					<xsl:if test="hl7:maxDoseQuantity/hl7:denominator[not(@nullFlavor)]">
						<MaxDoseDenominator>
							<Value>
								<xsl:value-of select="hl7:maxDoseQuantity/hl7:denominator/@value"/>
							</Value>
							<UnitOfMeasure>
								<xsl:if test="hl7:maxDoseQuantity/hl7:denominator/@code">
									<Code><xsl:value-of select="hl7:maxDoseQuantity/hl7:denominator/@code"/></Code>
								</xsl:if>
								<xsl:if test="hl7:maxDoseQuantity/hl7:denominator/@unit">
									<Description><xsl:value-of select="hl7:maxDoseQuantity/hl7:denominator/@unit"/></Description>
								</xsl:if>
							</UnitOfMeasure>
						</MaxDoseDenominator>
					</xsl:if>

					<!--
						Field : Medication DoseQuantity
						Target: HS.SDA3.DosageStep DoseQuantity
						Target: /Container/Medications/Medication/DosageSteps/DosageStep/DoseQuantity
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:doseQuantity
					-->
					<xsl:if test="string-length(hl7:doseQuantity/@value)">
						<DoseQuantity>
							<xsl:value-of select="hl7:doseQuantity/@value"/>
						</DoseQuantity>
					</xsl:if>
					<xsl:if test="string-length(hl7:doseQuantity/@unit)">
						<DoseUoM>
							<Code>
								<xsl:value-of select="hl7:doseQuantity/@unit"/>
							</Code>
							<SDACodingStandard>"http://unitsofmeasure.org"</SDACodingStandard>
						</DoseUoM>
					</xsl:if>
					
					<!--
						Field : Medication RateQuantity
						Target: HS.SDA3.DosageStep RateQuantity
						Target: /Container/Medications/Medication/DosageSteps/DosageStep/RateQuantity
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:rateQuantity
					-->
					<xsl:if test="string-length(hl7:rateQuantity/@value)">
						<RateQuantity>
							<xsl:value-of select="hl7:rateQuantity/@value"/>
						</RateQuantity>
					</xsl:if>
					<xsl:if test="string-length(hl7:rateQuantity/@unit)">
						<RateUoM>
							<Code>
								<xsl:value-of select="hl7:rateQuantity/@unit"/>
							</Code>
							<SDACodingStandard>"http://unitsofmeasure.org"</SDACodingStandard>
						</RateUoM>
					</xsl:if>
					

					<!--
						Field : Medication RepeatTiming
						Target: HS.SDA3.DosageStep RepeatTiming
						Target: /Container/Medications/Medication/DosageSteps/DosageStep/RepeatTiming
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:effectiveTime[operator='A' and xsi:type='EIVL_TS']/hl7:event/@code
					-->
					<xsl:if test="hl7:effectiveTime[operator='A' and xsi:type='EIVL_TS']/hl7:event/@code">
						<RepeatTiming>
							<xsl:value-of select="hl7:effectiveTime[operator='A' and xsi:type='EIVL_TS']/hl7:event/@code"/>
						</RepeatTiming>
					</xsl:if>
					
					<!--
						Field : Medication RepeatOffset
						Target: HS.SDA3.DosageStep RepeatOffset
						Target: /Container/Medications/Medication/DosageSteps/DosageStep/RepeatOffset
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:effectiveTime[operator='A' and xsi:type='EIVL_TS']/hl7:offset/@value
					-->
					<xsl:if test="hl7:effectiveTime[@operator='A' and @xsi:type='EIVL_TS']/hl7:offset/@value">
						<RepeatOffset>
							<xsl:choose>
								<xsl:when test="hl7:effectiveTime[@operator='A' and @xsi:type='EIVL_TS']/hl7:offset/@unit = 'min'">
									<xsl:value-of select="hl7:effectiveTime[@operator='A' and @xsi:type='EIVL_TS']/hl7:offset/@value"/>
								</xsl:when>
								<xsl:when test="hl7:effectiveTime[@operator='A' and @xsi:type='EIVL_TS']/hl7:offset/@unit = 'h'">
									<xsl:value-of select="number(hl7:effectiveTime[@operator='A' and @xsi:type='EIVL_TS']/hl7:offset/@value) * 60"/>
								</xsl:when>
							</xsl:choose>
						</RepeatOffset>
					</xsl:if>
					
					<!--
						Field : Medication TextInstruction
						Target: HS.SDA3.DosageStep TextInstruction
						Target: /Container/Medications/Medication/DosageSteps/DosageStep/TextInstruction
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:entryRelationship/hl7:substanceAdministration[hl7:code/@code='76662-6']/@text
					-->
					<xsl:if test="hl7:entryRelationship/hl7:substanceAdministration[hl7:code/@code='76662-6']/@text">
						<TextInstruction>
							<xsl:apply-templates select="hl7:entryRelationship/hl7:substanceAdministration[hl7:code/@code='76662-6']/@text" mode="eM-TextInstruction"/>
						</TextInstruction>
					</xsl:if>
					
					<!--
						Field : Medication PatientInstruction
						Target: HS.SDA3.DosageStep PatientInstruction
						Target: /Container/Medications/Medication/DosageSteps/DosageStep/PatientInstruction
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:entryRelationship[@typeCode='SUBJ' and @inversionInd='true']/hl7:act/hl7:text
					-->
					<xsl:if test="(hl7:entryRelationship[@typeCode='SUBJ' and @inversionInd='true']/hl7:act/hl7:text) or (hl7:entryRelationship[@typeCode='SUBJ' and @inversionInd='true']/hl7:act/hl7:code/hl7:originalText)">
						<xsl:choose>
							<xsl:when test="hl7:entryRelationship[@typeCode='SUBJ' and @inversionInd='true']/hl7:act/hl7:text/hl7:reference[not(@nullFlavor)]">
								<xsl:variable name="referenceValue" select="substring-after(hl7:entryRelationship[@typeCode='SUBJ' and @inversionInd='true']/hl7:act/hl7:text/hl7:reference/@value, '#')"/>
								<PatientInstruction>
									<xsl:value-of select="normalize-space(key('narrativeKey', $referenceValue))"/>
								</PatientInstruction>
							</xsl:when>
							<xsl:when test="hl7:entryRelationship[@typeCode='SUBJ' and @inversionInd='true']/hl7:act/hl7:text">
								<PatientInstruction>
									<xsl:value-of select="hl7:entryRelationship[@typeCode='SUBJ' and @inversionInd='true']/hl7:act/hl7:text"/>
								</PatientInstruction>
							</xsl:when>
							<xsl:otherwise>
								<PatientInstruction>
									<xsl:value-of select="hl7:entryRelationship[@typeCode='SUBJ' and @inversionInd='true']/hl7:act/hl7:code/hl7:originalText"/>
								</PatientInstruction>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					
					<!--
						Field : Medication CodedInstruction
						Target: HS.SDA3.DosageStep CodedInstruction
						Target: /Container/Medications/Medication/DosageSteps/DosageStep/CodedInstruction
						Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:entryRelationship[@typeCode='SUBJ' and @inversionInd='true']/hl7:act/hl7:code
					-->
					<xsl:if test="hl7:entryRelationship[@typeCode='SUBJ' and @inversionInd='true']/hl7:act/hl7:code">
						<xsl:apply-templates select="hl7:entryRelationship[@typeCode='SUBJ' and @inversionInd='true']/hl7:act/hl7:code" mode="fn-CodeTable">
							<xsl:with-param name="hsElementName" select="'CodedInstruction'"/>
						</xsl:apply-templates>
					</xsl:if>
				</DosageStep></DosageSteps>
			</xsl:if>
			
			<!--
				Field : Medication Placer Id
				Target: HS.SDA3.AbstractOrder PlacerId
				Target: /Container/Medications/Medication/PlacerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/id[2]
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/id[2]
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/id[2]
				StructuredMappingRef: PlacerId
			-->
			<!--
				Field : Immunization Placer Id
				Target: HS.SDA3.AbstractOrder PlacerId
				Target: /Container/Vaccinations/Vaccination/PlacerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[2]
				StructuredMappingRef: PlacerId
			-->
			<xsl:apply-templates select="." mode="fn-PlacerId">
				<xsl:with-param name="makeDefault" select="'0'"/>
			</xsl:apply-templates>
			
			<!--
				Field : Medication Filler Id
				Target: HS.SDA3.AbstractOrder FillerId
				Target: /Container/Medications/Medication/FillerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/id[3]
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/id[3]
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/id[3]
				StructuredMappingRef: FillerId
			-->
			<!--
				Field : Immunization Filler Id
				Target: HS.SDA3.AbstractOrder FillerId
				Target: /Container/Vaccinations/Vaccination/FillerId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id[3]
				StructuredMappingRef: FillerId
			-->
			<xsl:apply-templates select="." mode="fn-FillerId">
				<xsl:with-param name="makeDefault" select="'0'"/>
			</xsl:apply-templates>

			<!--
				Field : Medication Coded Product Name
				Target: HS.SDA3.AbstractOrder OrderItem
				Target: /Container/Medications/Medication/OrderItem
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code
				StructuredMappingRef: CodeTableDetail
			-->
			<!--
				Field : Immunization Coded Product Name
				Target: HS.SDA3.AbstractOrder OrderItem
				Target: /Container/Vaccinations/Vaccination/OrderItem
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/code
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'OrderItem'"/>
				<xsl:with-param name="importOriginalText" select="'1'"/>
			</xsl:apply-templates>

			<!--
				Field : Medication ManufacturerName
				Target: HS.SDA3.Medication ManufacturerName
				Target: /Container/Medications/Medication/ManufacturerName
				Source: hl7:consumable/hl7:manufacturedProduct/hl7:manufacturerOrganization/hl7:name
			-->
			<!--
				Field : Medication ManufacturerOrganization
				Target: HS.SDA3.Medication ManufacturerOrganization
				Target: /Container/Medications/Medication/ManufacturerOrganization
				Source: hl7:consumable/hl7:manufacturedProduct/hl7:manufacturerOrganization
				StructuredMappingRef: OrganizationDetail
			-->
			<xsl:if test="string-length(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturerOrganization/hl7:name)">
				<ManufacturerName>
					<xsl:value-of select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturerOrganization/hl7:name" />
				</ManufacturerName>
				<ManufacturerOrganization>
					<Code><xsl:value-of select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturerOrganization/hl7:id/@extension" /></Code>
					<SDACodingStandard><xsl:value-of select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturerOrganization/hl7:id/@root" /></SDACodingStandard>
					<Description><xsl:value-of select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturerOrganization/hl7:name" /></Description>
					<xsl:apply-templates select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturerOrganization/hl7:addr" mode="fn-T-pName-address"/>
					<xsl:apply-templates select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturerOrganization" mode="fn-T-pName-ContactInfo"/>
				</ManufacturerOrganization>
			</xsl:if>

			<!--
				Field : Medication Dosage Form
				Target: HS.SDA3.Medication DosageForm
				Target: /Container/Medications/Medication/DosageForm
				Source: hl7:administrationUnitCode
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:if test="string-length(hl7:administrationUnitCode/@code)">
				<DosageForm>
					<xsl:apply-templates select="hl7:administrationUnitCode" mode="fn-CodeTableDetail"/>
				</DosageForm>
			</xsl:if>

			<!--
				Field : Medication Ingredient
				Target: HS.SDA3.Medication Ingredient
				Target: /Container/Medications/Medication/Ingredient
				Source: hl7:participant[@typeCode='CSM']
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:if test="hl7:participant[@typeCode='CSM']">
				<Ingredient>
					<xsl:apply-templates select="hl7:participant[@typeCode='CSM']/hl7:participantRole/hl7:playingEntity/hl7:code" mode="fn-CodeTableDetail"/>
				</Ingredient>
			</xsl:if>

			<!--
				Field : Medication Author
				Target: HS.SDA3.AbstractOrder EnteredBy
				Target: /Container/Medications/Medication/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/author
				StructuredMappingRef: EnteredByDetail
			-->
			<!--
				Field : Immunization Author
				Target: HS.SDA3.AbstractOrder EnteredBy
				Target: /Container/Vaccinations/Vaccination/EnteredBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/author
				StructuredMappingRef: EnteredByDetail
			-->
			<xsl:apply-templates select="." mode="fn-EnteredBy"/>
			
			<!--
				Field : Medication Information Source
				Target: HS.SDA3.AbstractOrder EnteredAt
				Target: /Container/Medications/Medication/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/informant
				StructuredMappingRef: EnteredAt
			-->
			<!--
				Field : Immunization Information Source
				Target: HS.SDA3.AbstractOrder EnteredAt
				Target: /Container/Vaccinations/Vaccination/EnteredAt
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/informant
				StructuredMappingRef: EnteredAt
			-->
			<xsl:apply-templates select="." mode="fn-EnteredAt"/>
			
			<!-- Medication EnteredOn -->
			<xsl:if test="$medicationType!='VXU'">
				<xsl:apply-templates select="." mode="eM-AuthorTime"/>
			</xsl:if> 
			
			<!--
				Field : Medication Id
				Target: HS.SDA3.AbstractOrder ExternalId
				Target: /Container/Medications/Medication/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/id
				StructuredMappingRef: ExternalId
			-->
			<!--
				Field : Immunization Id
				Target: HS.SDA3.AbstractOrder ExternalId
				Target: /Container/Vaccinations/Vaccination/ExternalId
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/id
				StructuredMappingRef: ExternalId
			-->
			<xsl:apply-templates select="." mode="fn-Identifiers"/>

			<!--
				Field : Medication Entering Organization
				Target: HS.SDA3.AbstractOrder EnteringOrganization
				Target: /Container/Medications/Medication/EnteringOrganization
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/informant
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/informant
				StructuredMappingRef: EnteringOrganization
			-->
			<!--
				Field : Immunization Entering Organization
				Target: HS.SDA3.AbstractOrder EnteringOrganization
				Target: /Container/Vaccinations/Vaccination/EnteringOrganization
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/informant
				StructuredMappingRef: EnteringOrganization
			-->
			<xsl:apply-templates select="." mode="fn-EnteringOrganization"/>
			
			<!--
				Field : Medication Ordering Clinician
				Target: HS.SDA3.AbstractOrder OrderedBy
				Target: /Container/Medications/Medication/OrderedBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
			-->
			<!--
				Field : Immunization Ordering Clinician
				Target: HS.SDA3.AbstractOrder OrderedBy
				Target: /Container/Vaccinations/Vaccination/OrderedBy
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='INT']/author
			-->
			<xsl:apply-templates select="hl7:author" mode="fn-OrderedBy-Author"/>

			<!-- Frequency -->
			<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='PIVL_TS']" mode="eM-Frequency"/>			

			<!-- Duration -->
			<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='IVL_TS']" mode="eM-Duration"/>			

			<!-- Medication Status -->
			<xsl:choose>
				<xsl:when test="$medicationType='VXU'">
					<xsl:apply-templates select="." mode="eM-Status">
						<xsl:with-param name="statusMedicationType" select="$medicationType"/>
					</xsl:apply-templates>
				</xsl:when> 
				<xsl:otherwise>
					<Status>
						<xsl:choose>
							<xsl:when test="hl7:statusCode/@code = 'active'">A</xsl:when>
							<xsl:when test="hl7:statusCode/@code = 'suspended'">H</xsl:when>
							<xsl:when test="hl7:statusCode/@code = 'aborted'">D</xsl:when>
							<xsl:when test="hl7:statusCode/@code = 'completed'">CM</xsl:when>
							<xsl:when test="hl7:statusCode/@code = 'nullified'">I</xsl:when>
						</xsl:choose>
					</Status>
				</xsl:otherwise>
			</xsl:choose>
						
						
			<!-- Free-text SIG, TextInstruction -->
			<xsl:if test="$medicationType='MED' or $medicationType='MEDPOC'">
				<xsl:apply-templates select="hl7:text" mode="eM-TextInstruction"/>
			</xsl:if>

			<!--
				Field : Vaccination NumberOfRefills
				Target: HS.SDA3.Vaccination NumberOfRefills
				Target: /Container/Vaccinations/Vaccination/NumberOfRefills
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:repeatNumber/@value
			-->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='INT'][hl7:repeatNumber]" mode="eM-NumberOfRefills"/>
			<xsl:apply-templates select="hl7:repeatNumber[@moodCode='EVN'][hl7:repeatNumber]" mode="eM-NumberOfRefills"/>
			<!-- The connotation of repeatNumber will vary, based on the moodCode. -->
			
			<!--
				Field : Medication Start Date/Time
				Target: HS.SDA3.AbstractOrder FromTime
				Target: /Container/Medications/Medication/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
			-->
			<!--
				Field : Medication End Date/Time
				Target: HS.SDA3.AbstractOrder ToTime
				Target: /Container/Medications/Medication/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			-->
			<xsl:if test="$medicationType!='VXU'">
				<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='IVL_TS']/hl7:low" mode="fn-StartTime"/>
				<xsl:apply-templates select="hl7:effectiveTime[@xsi:type='IVL_TS']/hl7:high" mode="fn-EndTime"/>
			</xsl:if>
			
			<!--
				Field : Vaccination FromTime
				Target: HS.SDA3.AbstractOrder FromTime
				Target: /Container/Vaccinations/Vaccination/FromTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/hl7:substanceAdministration/hl7:effectiveTimelow/@value
			-->
			<!--
				Field : Vaccination ToTime
				Target: HS.SDA3.AbstractOrder ToTime
				Target: /Container/Vaccinations/Vaccination/ToTime
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/hl7:substanceAdministration/hl7:effectiveTime/@value
			-->
			<xsl:if test="$medicationType='VXU'">
				<xsl:if test="hl7:effectiveTime/@value">
					<xsl:apply-templates select="hl7:effectiveTime/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'ToTime'"/>
					</xsl:apply-templates>
				</xsl:if>
				<xsl:if test="hl7:effectiveTime/hl7:low/@value">
					<xsl:apply-templates select="hl7:effectiveTime/hl7:low/@value" mode="fn-E-paramName-timestamp">
						<xsl:with-param name="emitElementName" select="'FromTime'"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:if>
			
			<!-- Drug Product -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']" mode="eM-DrugProduct">
				<xsl:with-param name="medicationType" select="$medicationType"/>
			</xsl:apply-templates>

			<!-- Rate Amount -->
			<xsl:apply-templates select="hl7:rateQuantity" mode="eM-RateAmountAndUnits"/>	

			<!-- Dose Quantity -->
			<xsl:apply-templates select="hl7:doseQuantity" mode="eM-DoseQuantityAndUoM"/>
			
			<!--
				Field : Medication Route
				Target: HS.SDA3.AbstractMedication Route
				Target: /Container/Medications/Medication/OrderItem
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/routeCode
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/routeCode
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/routeCode
				StructuredMappingRef: CodeTableDetail
			-->
			<!--
				Field : Immunization Route
				Target: HS.SDA3.AbstractMedication Route
				Target: /Container/Vaccinations/Vaccination/Route
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/routeCode
				StructuredMappingRef: CodeTableDetail
			-->
			<xsl:apply-templates select="hl7:routeCode" mode="fn-CodeTable">
				<xsl:with-param name="hsElementName" select="'Route'"/>
			</xsl:apply-templates>
			
			<!-- Indication -->
			<xsl:if test="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value[not(@nullFlavor)]">
				<xsl:choose>
					<xsl:when test="$medicationType != 'VXU'">
						<IndicationCoded>
							<xsl:if test="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@code">
								<Code><xsl:value-of select="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@code" /></Code>
							</xsl:if>
							<xsl:if test="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@codeSystem">
								<SDACodingStandard><xsl:value-of select="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@codeSystem" /></SDACodingStandard>
							</xsl:if>
							<xsl:if test="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@displayName">
								<Description><xsl:value-of select="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@displayName" /></Description>
							</xsl:if>
						</IndicationCoded>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@code">
						<StatusReason>
							<xsl:if test="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@code">
								<Code><xsl:value-of select="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@code" /></Code>
							</xsl:if>
							<xsl:if test="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@codeSystem">
								<SDACodingStandard><xsl:value-of select="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@codeSystem" /></SDACodingStandard>
							</xsl:if>
							<xsl:if test="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@displayName">
								<Description><xsl:value-of select="hl7:entryRelationship[@typeCode='RSON']/hl7:observation/hl7:value/@displayName" /></Description>
							</xsl:if>
						</StatusReason>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			
			<!--
				Field : Medication Comments
				Target: HS.SDA3.AbstractOrder Comments
				Target: /Container/Medications/Medication/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
			-->
			<!--
				Field : Immunization Comments
				Target: HS.SDA3.AbstractOrder Comments
				Target: /Container/Vaccinations/Vaccination/Comments
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/act[code/@code='48767-8']/text
			-->
			<xsl:apply-templates select="." mode="eCm-Comment"/>
			
			<!-- Component Medications -->
			<xsl:if test="hl7:entryRelationship[@typeCode='COMP']/hl7:substanceAdministration">
				<ComponentMeds>
					<xsl:apply-templates select="hl7:entryRelationship[@typeCode='COMP']/hl7:substanceAdministration" mode="eM-ComponentMed">
						<xsl:with-param name="medicationType" select="$medicationType"/>
					</xsl:apply-templates>
				</ComponentMeds>
			</xsl:if>
			
			<!-- Prescription Number -->
			<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']" mode="eM-PrescriptionNumber"/>

			<!-- Check if there is data to include in <Administrations> -->
			<xsl:variable name="refusalObservations" select="hl7:entryRelationship[@typeCode='RSON']/hl7:observation[@moodCode='EVN' and hl7:templateId/@root=$ccda-ImmunizationRefusalReason]"/>
			
			<xsl:variable name="authorTimes" select="hl7:author/hl7:time | hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']/hl7:author/hl7:time"/>
			<xsl:variable name="startTimes" select="./hl7:effectiveTime[@value] | hl7:effectiveTime/hl7:low"/>
			<xsl:variable name="endTimes" select="hl7:effectiveTime/hl7:high"/>

			<!-- 
				Include <Administrations> if there is a LotNumber, RefusalReason, EnteredOn, FromTime or ToTime. 
				Note that EnteredOn, FromTime and ToTime are only included if there is exactly one value for the given field. 
			-->
			<xsl:if test="string-length(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:lotNumberText) or count($refusalObservations) > 0 
				or ($medicationType='VXU' and ((count($authorTimes) = 1) or (count($startTimes) = 1) or (count($endTimes) = 1)))">
				<Administrations>
					<Administration>
						<!--
							Field : Vaccination Lot Number
							Target: HS.SDA3.Administration LotNumber
							Target: /Container/Vaccinations/Vaccination/Administrations/Administration/LotNumber
							Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/consumable/manufacturedProduct/manufacturedMaterial/lotNumberText
						-->
						<xsl:for-each select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial">
							<xsl:if test="hl7:lotNumberText/text()">
								<LotNumber><xsl:value-of select="hl7:lotNumberText/text()" /></LotNumber>
							</xsl:if>
						</xsl:for-each>

						<!--
							Field : Vaccination ManufacturerName
							Target: HS.SDA3.Administration ManufacturerName
							Target: /Container/Vaccinations/Vaccination/Administrations/Administration/ManufacturerName
							Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/hl7:consumable/hl7:manufacturedMaterial/hl7:manufacturerOrganization
						-->	
						<xsl:if test="string-length(hl7:consumable/hl7:manufacturedMaterial/hl7:manufacturerOrganization)">
							<ManufacturerName>
								<xsl:value-of select="hl7:consumable/hl7:manufacturedMaterial/hl7:manufacturerOrganization" />
							</ManufacturerName>
						</xsl:if>
						
						<!--
							Field : Vaccination RefusalReason
							Target: HS.SDA3.Administration RefusalReason
							Target: /Container/Vaccinations/Vaccination/Administrations/Administration/RefusalReason
							Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation[@moodCode='EVN' and hl7:templateId/@root='2.16.840.1.113883.10.20.22.4.53']
						-->
						<xsl:for-each select="$refusalObservations">
							<RefusalReason>
								<Code><xsl:value-of select="hl7:code/@code" /></Code>
								<Description><xsl:value-of select="hl7:code/@displayName" /></Description>
							</RefusalReason>
						</xsl:for-each>

						<xsl:if test="$medicationType='VXU'">
							<!-- Vaccination EnteredOn -->
							<xsl:if test="count($authorTimes) = 1">
								<xsl:apply-templates select="." mode="eM-AuthorTime"/>
							</xsl:if>

							<!--
								Field : Immunization Start Date/Time
								Target: HS.SDA3.AbstractOrder FromTime
								Target: /Container/Vaccinations/Vaccination/Administrations/Administration/FromTime
								Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime/@value
								Note  : SDA Vaccination FromTime uses either CDA Immunization effectiveTime/@value
										or effectiveTime/low/@value.  Both values will not be present, and for
										CDA Immunization it is most likely that only effectiveTime/@value will
										be present.
							-->
							<!--
								Field : Immunization End Date/Time
								Target: HS.SDA3.AbstractOrder ToTime
								Target: /Container/Vaccinations/Vaccination/Administrations/Administration/ToTime
								Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
								Note  : SDA Vaccination ToTime uses CDA Immunization effectiveTime/high/@value
										but it is very unlikely that that value will be present.  This is okay, as
										importing only SDA Vaccination FromTime is sufficient.
							-->
							<xsl:if test="count($startTimes) = 1">
								<xsl:apply-templates select="./hl7:effectiveTime[@value] | hl7:effectiveTime/hl7:low" mode="fn-StartTime"/>
							</xsl:if>
							<xsl:if test="count($endTimes) = 1">
								<xsl:apply-templates select="hl7:effectiveTime/hl7:high" mode="fn-EndTime"/>
							</xsl:if>
						</xsl:if> 
					</Administration>
				</Administrations>
			</xsl:if> 

			<!--
				Field : Medication Encounter
				Target: HS.SDA3.AbstractOrder EncounterNumber
				Target: /Container/Medications/Medication/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/encounter/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/encounter/id
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/encounter/id
				Note  : If the CDA encounter link @extension is present then
						it is imported to SDA EncounterNumber.  Otherwise if
						the encounter link @root is present then it is used.
						If there is no encounter link on the CDA Medication and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->
			<!--
				Field : Immunization Encounter
				Target: HS.SDA3.AbstractOrder EncounterNumber
				Target: /Container/Vaccinations/Vaccination/EncounterNumber
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/encounter/id
				Note  : If the CDA encounter link @extension is present then
						it is imported to SDA EncounterNumber.  Otherwise if
						the encounter link @root is present then it is used.
						If there is no encounter link on the CDA Immunization and
						there is an encompassingEncounter in the CDA document
						header then the id from the encompassingEncounter is
						imported to SDA EncounterNumber.
			-->
			<EncounterNumber><xsl:apply-templates select="." mode="fn-EncounterID-Entry"/></EncounterNumber>

			<!-- Custom SDA Data-->
			<xsl:apply-templates select="." mode="eM-ImportCustom-Medication">
				<xsl:with-param name="medicationType" select="$medicationType"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="hl7:supply" mode="eM-DrugProduct">
		<!--
			Field : Medication Coded Product Name
			Target: HS.SDA3.AbstractMedication DrugProduct
			Target: /Container/Medications/Medication/DrugProduct
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/code
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/code
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/code
			StructuredMappingRef: CodeTableDetail
		-->
		<!--
			Field : Immunization Coded Product Name
			Target: HS.SDA3.AbstractMedication DrugProduct
			Target: /Container/Vaccinations/Vaccination/DrugProduct
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/code
			StructuredMappingRef: CodeTableDetail
		-->
		
		<xsl:variable name="useFirstTranslation" select="hl7:product/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:translation[1]/@codeSystem=$noCodeSystemOID"/>
		
		<DrugProduct>		
			<xsl:apply-templates select="hl7:product/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code" mode="fn-CodeTableDetail">
				<xsl:with-param name="emitElementName" select="'DrugProduct'"/>
				<xsl:with-param name="useFirstTranslation" select="$useFirstTranslation"/>
				<xsl:with-param name="importOriginalText" select="'1'"/>
			</xsl:apply-templates>
			
			<xsl:apply-templates select="hl7:quantity[not(@nullFlavor)]" mode="eM-DrugProductQuantity"/>
			
			<!--
				Field : Medication Text Product Name
				Target: HS.SDA3.AbstractMedication DrugProduct.ProductName
				Target: /Container/Medications/Medication/DrugProduct/ProductName
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/name
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/name
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/name
			-->
			<!--
				Field : Immunization Text Product Name
				Target: HS.SDA3.AbstractMedication DrugProduct.ProductName
				Target: /Container/Vaccinations/Vaccination/DrugProduct/ProductName
				Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply/product/manufacturedProduct/manufacturedMaterial/name
			-->
			<ProductName><xsl:value-of select="hl7:product/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:name"/></ProductName>
		</DrugProduct>
	</xsl:template>

	<xsl:template match="hl7:supply" mode="eM-PrescriptionNumber">
		<!--
			Field : Medication Prescription Id
			Target: HS.SDA3.AbstractMedication PrescriptionNumber
			Target: /Container/Medications/Medication/PrescriptionNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
			Note  : If CDA id/@extension is present then it is
					imported to SDA PrescriptionNumber.  Otherwise
					if id/@root is present then import that value
					to PrescriptionNumber.
		-->
		<!--
			Field : Immunization Prescription Id
			Target: HS.SDA3.AbstractMedication PrescriptionNumber
			Target: /Container/Vaccinations/Vaccination/PrescriptionNumber
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply[@moodCode='EVN']/id
			Note  : If CDA id/@extension is present then it is
					imported to SDA PrescriptionNumber.  Otherwise
					if id/@root is present then import that value
					to PrescriptionNumber.
		-->
		<PrescriptionNumber>
			<xsl:choose>
				<xsl:when test="hl7:id/@extension"><xsl:value-of select="hl7:id/@extension"/></xsl:when>
				<xsl:when test="hl7:id/@root"><xsl:value-of select="hl7:id/@root"/></xsl:when>
			</xsl:choose>
		</PrescriptionNumber>
	</xsl:template>

	<xsl:template match="hl7:quantity" mode="eM-DrugProductQuantity">
		<!--
			Field : Medication Quantity Ordered
			Target: HS.SDA3.DrugProduct BaseQty
			Target: /Container/Medications/Medication/DrugProduct/BaseQty
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply/quantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply/quantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply/quantity/@value
		-->
		<!--
			Field : Immunization Quantity Ordered
			Target: HS.SDA3.DrugProduct BaseQty
			Target: /Container/Vaccinations/Vaccination/DrugProduct/BaseQty
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply/quantity/@value
		-->
		<!--
			Field : Medication Quantity Ordered Unit
			Target: HS.SDA3.DrugProduct BaseUnits
			Target: /Container/Medications/Medication/DrugProduct/BaseUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply/quantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply/quantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply/quantity/@unit
		-->
		<!--
			Field : Immunization Quantity Ordered Unit
			Target: HS.SDA3.DrugProduct BaseUnits
			Target: /Container/Vaccinations/Vaccination/DrugProduct/BaseUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply/quantity/@unit
		-->
		<xsl:if test="@value">
			<BaseQty><xsl:value-of select="@value"/></BaseQty>
		</xsl:if>
		<xsl:if test="@unit">
			<BaseUnits>
				<Code><xsl:value-of select="@unit"/></Code>
				<Description><xsl:value-of select="@unit"/></Description>
			</BaseUnits>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:doseQuantity" mode="eM-DoseQuantityAndUoM">
		<!-- The mode formerly known as DoseQuantity -->
		<!--
			Field : Medication Dose Quantity
			Target: HS.SDA3.AbstractMedication DoseQuantity
			Target: /Container/Medications/Medication/DoseQuantity
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/doseQuantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/doseQuantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/doseQuantity/@value
		-->
		<!--
			Field : Immunization Dose Quantity
			Target: HS.SDA3.AbstractMedication DoseQuantity
			Target: /Container/Vaccinations/Vaccination/DoseQuantity
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/doseQuantity/@value
		-->
		<xsl:variable name="doseQuantity">
			<xsl:choose>
				<xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
				<xsl:when test="hl7:low/@value"><xsl:value-of select="hl7:low/@value"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($doseQuantity)">
			<DoseQuantity><xsl:value-of select="$doseQuantity"/></DoseQuantity>
		</xsl:if>
		
		<!--
			Field : Medication Dose Quantity Unit
			Target: HS.SDA3.AbstractMedication DoseUoM
			Target: /Container/Medications/Medication/DoseUoM
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/doseQuantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/doseQuantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/doseQuantity/@unit
		-->
		<!--
			Field : Immunization Dose Quantity Unit
			Target: HS.SDA3.AbstractMedication DoseUoM
			Target: /Container/Vaccinations/Vaccination/DoseUoM
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/doseQuantity/@unit
		-->
		<xsl:variable name="doseUnits">
			<xsl:choose>
				<xsl:when test="@unit"><xsl:value-of select="@unit"/></xsl:when>
				<xsl:when test="hl7:low/@unit"><xsl:value-of select="hl7:low/@unit"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($doseUnits)">
			<DoseUoM>
				<Code><xsl:value-of select="$doseUnits"/></Code>
				<SDACodingStandard>http://unitsofmeasure.org</SDACodingStandard>
				<Description><xsl:value-of select="$doseUnits"/></Description>
			</DoseUoM>			
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:supply" mode="eM-NumberOfRefills">
		<!--
			Field : Medication Number of Refills
			Target: HS.SDA3.AbstractMedication NumberOfRefills
			Target: /Container/Medications/Medication/NumberOfRefills
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply/repeatNumber/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply/repeatNumber/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply/repeatNumber/@value
			Note  : The SDA NumberOfRefills is equal to the CDA repeatNumber/@value minus 1.
		-->
		<xsl:if test="hl7:repeatNumber/@value > 0">
			<NumberOfRefills><xsl:value-of select="hl7:repeatNumber/@value - 1"/></NumberOfRefills>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:rateQuantity" mode="eM-RateAmountAndUnits">
		<!-- The mode formerly known as RateAmount -->		
		<!--
			Field : Medication Rate Quantity Amount
			Target: HS.SDA3.AbstractMedication RateAmount
			Target: /Container/Medications/Medication/RateAmount
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/rateQuantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/rateQuantity/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/rateQuantity/@value
		-->
		<!--
			Field : Immunization Rate Quantity Amount
			Target: HS.SDA3.AbstractMedication RateAmount
			Target: /Container/Vaccinations/Vaccination/RateAmount
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/rateQuantity/@value
		-->
		<xsl:variable name="rateAmount">
			<xsl:choose>
				<xsl:when test="@value"><xsl:value-of select="@value"/></xsl:when>
				<xsl:when test="hl7:low/@value"><xsl:value-of select="hl7:low/@value"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($rateAmount)">
			<RateAmount><xsl:value-of select="$rateAmount"/></RateAmount>
		</xsl:if>
		
		<!--
			Field : Medication Rate Quantity Unit
			Target: HS.SDA3.AbstractMedication RateUnits
			Target: /Container/Medications/Medication/RateUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/rateQuantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/rateQuantity/@unit
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/rateQuantity/@unit
		-->
		<!--
			Field : Immunization Rate Quantity Unit
			Target: HS.SDA3.AbstractMedication RateUnits
			Target: /Container/Vaccinations/Vaccination/RateUnits
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/rateQuantity/@unit
		-->
		<xsl:variable name="rateUnits">
			<xsl:choose>
				<xsl:when test="@unit"><xsl:value-of select="@unit"/></xsl:when>
				<xsl:when test="hl7:low/@unit"><xsl:value-of select="hl7:low/@unit"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($rateUnits)">
			<RateUnits>
				<Code><xsl:value-of select="$rateUnits"/></Code>
				<Description><xsl:value-of select="$rateUnits"/></Description>
			</RateUnits>			
		</xsl:if>		
	</xsl:template>
	
	<xsl:template match="hl7:effectiveTime" mode="eM-Frequency">
		<!--
			Field : Medication Frequency
			Target: HS.SDA3.AbstractOrder Frequency
			Target: /Container/Medications/Medication/Frequency
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='PIVL_TS']
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/effectiveTime[@xsi:type='PIVL_TS']
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/effectiveTime[@xsi:type='PIVL_TS']
			Note  : In CDA, hl7:period/@value + hl7:period/@unit always indicates an interval.
					@institutionSpecified indicates whether the original data was a
					frequency (true) or an interval (false).
					Even though the SDA property name is Frequency, it may be used to
					import an interval.
		-->			
		<xsl:variable name="frequency">
			<xsl:variable name="periodUnit" select="hl7:period/@unit"/>
			<xsl:variable name="periodValue" select="hl7:period/@value"/>
			<xsl:choose>
				<xsl:when test="$periodUnit='h' or $periodUnit='hr' or starts-with($periodUnit,'hour')">
					<xsl:choose>
						<xsl:when test="@institutionSpecified='true'">
							<xsl:choose>
								<xsl:when test="$periodValue='12'">BID</xsl:when>
								<xsl:when test="$periodValue='8'">TID</xsl:when>
								<xsl:when test="$periodValue='6'">QID</xsl:when>
								<xsl:when test="$periodValue='24'">QD</xsl:when>
								<xsl:when test="$periodValue='48'">QOD</xsl:when>
								<xsl:when test="$periodValue='4'">6xD</xsl:when>
								<xsl:when test="$periodValue='3'">8xD</xsl:when>
								<xsl:when test="$periodValue='2'">12xD</xsl:when>
								<xsl:when test="$periodValue='1'">24xD</xsl:when>
								<xsl:when test="not(contains(number(24 div $periodValue),'.'))"><xsl:value-of select="concat(number(24 div $periodValue),'xD')"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="concat('Q',$periodValue,'H')"/></xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="concat('Q',$periodValue,'H')"/></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$periodUnit='d' or starts-with($periodUnit,'day')">
					<xsl:choose>
						<xsl:when test="@institutionSpecified='true'">
							<xsl:choose>
								<xsl:when test="$periodValue='1'">QD</xsl:when>
								<xsl:when test="$periodValue='2'">QOD</xsl:when>
								<xsl:when test="$periodValue='7'">1xW</xsl:when>
								<xsl:otherwise><xsl:value-of select="concat('Q',$periodValue,'D')"/></xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="concat('Q',$periodValue,'D')"/></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$periodUnit='w' or $periodUnit='wk' or starts-with($periodUnit,'week')">
					<xsl:choose>
						<xsl:when test="@institutionSpecified='true'">
							<xsl:choose>
								<xsl:when test="$periodValue='1'">1xW</xsl:when>
								<xsl:when test="$periodValue='52'">1xY</xsl:when>
								<xsl:otherwise><xsl:value-of select="concat('Q',$periodValue,'W')"/></xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="concat('Q',$periodValue,'W')"/></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$periodUnit='mo' or $periodUnit='mon' or starts-with($periodUnit,'month')">
					<xsl:value-of select="concat('Q',$periodValue,'MON')"/>
				</xsl:when>
				<xsl:when test="$periodUnit='y' or $periodUnit='yr' or starts-with($periodUnit,'year')">
					<xsl:value-of select="concat('Q',$periodValue,'Y')"/>
				</xsl:when>
				<xsl:when test="string-length($eventCode)">
					<xsl:value-of select="$eventCode"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="string-length($frequency)">
			<Frequency>
				<Code><xsl:value-of select="$frequency"/></Code> 
				<Description><xsl:value-of select="$frequency"/></Description>
			</Frequency>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:substanceAdministration" mode="eM-Status">
		<!-- The mode formerly known as MedicationStatus -->
		<xsl:param name="statusMedicationType" select="'MED'"/>	
		<!--
			Field : Medication Order Status
			Target: HS.SDA3.AbstractOrder Status
			Target: /Container/Medications/Medication/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship/supply/@moodCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/statusCode/@code
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship/supply/@moodCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/statusCode/@code
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship/supply/@moodCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/statusCode/@code
			Note  : If CDA statusCode code = 'active' then SDA Status = 'A'.
					If CDA statusCode code = 'suspended' then SDA Status = 'H'.
					If CDA statusCode code = 'aborted' then SDA Status = 'D'.
					If CDA statusCode code = 'completed' then SDA Status = 'E'.
					If CDA statusCode code = 'nullified' then SDA Status = 'I'.
					If importing to SDA Vaccination and CDA substanceAdministration/@negationInd='true' then SDA Status='C'.
					If CDA supply moodCode='EVN' then Status='E'.
					If CDA status entryRelationship code='421139008' then SDA Status='H'.
					If CDA status entryRelationship code='55561003' then SDA Status='IP'.
					Otherwise SDA Status='unknown'.
		-->
		<!--
			Field : Immunization Order Status
			Target: HS.SDA3.AbstractOrder Status
			Target: /Container/Vaccinations/Vaccination/Status
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship/supply/@moodCode
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/statusCode/@code
			Note  : If CDA statusCode code = 'active' then SDA Status = 'A'.
					If CDA statusCode code = 'suspended' then SDA Status = 'H'.
					If CDA statusCode code = 'aborted' then SDA Status = 'D'.
					If CDA statusCode code = 'completed' then SDA Status = 'E'.
					If CDA statusCode code = 'nullified' then SDA Status = 'I'.
					If importing to SDA Vaccination and CDA substanceAdministration/@negationInd='true' then SDA Status='C'.
					If CDA supply moodCode='EVN' then Status='E'.
					If CDA status entryRelationship code='421139008' then SDA Status='H'.
					If CDA status entryRelationship code='55561003' then SDA Status='IP'.
					Otherwise SDA Status='unknown'.
		-->
		<Status>
			<xsl:choose>
				<xsl:when test="hl7:statusCode/@code = 'active'">A</xsl:when>
				<xsl:when test="hl7:statusCode/@code = 'suspended'">H</xsl:when>
				<xsl:when test="hl7:statusCode/@code = 'aborted'">D</xsl:when>
				<xsl:when test="hl7:statusCode/@code = 'completed'">E</xsl:when>
				<xsl:when test="hl7:statusCode/@code = 'nullified'">I</xsl:when>
				<xsl:when test="($statusMedicationType='VXU') and (../hl7:substanceAdministration/@negationInd='true')">C</xsl:when>
				<xsl:when test="($statusMedicationType='VXU') and (../hl7:substanceAdministration/hl7:statusCode/@code ='completed')">CM</xsl:when>
				<!--/-->
				<xsl:when test="($statusMedicationType='MEDPOC')">P</xsl:when>
				<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode = 'EVN']">E</xsl:when>
				<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value/@code = '421139008'">H</xsl:when>
				<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:observation[hl7:code/@code='33999-4']/hl7:value/@code = '55561003'">IP</xsl:when>
				<xsl:otherwise>unknown</xsl:otherwise>
			</xsl:choose>
		</Status>
	</xsl:template>
	
	<xsl:template match="hl7:entryRelationship" mode="eM-Indication">
		<!--
			Field : Medication Indication
			Target: HS.SDA3.AbstractMedication Indication
			Target: /Container/Medications/Medication/Indication
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Note  : In SDA, Indication is a String property.  However,
					in C-CDA it is a coded element.  For SDA Indication
					string, use the first found of these:
					- value/@displayName
					- value/originalText
					- value/@code
					- value/translation/@displayname
					- value/translation/@code
		-->
		<!--
			Field : Immunization Indication
			Target: HS.SDA3.AbstractMedication Indication
			Target: /Container/Vaccinations/Vaccination/Indication
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship[@typeCode='RSON']/observation/value
			Note  : In SDA, Indication is a String property.  However,
					in C-CDA it is a coded element.  For SDA Indication
					string, use the first found of these:
					- value/@displayName
					- value/originalText
					- value/@code
					- value/translation/@displayname
					- value/translation/@code
		-->	
		<xsl:variable name="obsValue" select="hl7:observation/hl7:value"/>
		<xsl:variable name="originalTextReferenceLink" select="substring-after($obsValue/hl7:originalText/hl7:reference/@value, '#')"/>
		<xsl:variable name="originalTextReferenceValue">
			<xsl:if test="string-length($originalTextReferenceLink)">
				<xsl:value-of select="normalize-space(key('narrativeKey', $originalTextReferenceLink))"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="indication">
			<xsl:choose>
				<xsl:when test="string-length($obsValue/@displayName)">
					<xsl:value-of select="$obsValue/@displayName"/>
				</xsl:when>
				<xsl:when test="string-length($originalTextReferenceValue)">
					<xsl:value-of select="$originalTextReferenceValue"/>
				</xsl:when>
				<xsl:when test="string-length($obsValue/@code)">
					<xsl:value-of select="$obsValue/@code"/>
				</xsl:when>
				<xsl:when test="string-length($obsValue/hl7:translation/@displayName)">
					<xsl:value-of select="$obsValue/hl7:translation/@displayName"/>
				</xsl:when>
				<xsl:when test="string-length($obsValue/hl7:translation/@code)">
					<xsl:value-of select="$obsValue/hl7:translation/@code"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="string-length($indication)">
			<Indication><xsl:value-of select="$indication"/></Indication>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:text" mode="eM-TextInstruction">
		<!-- The mode formerly known as Signature -->
		<!--
			Field : Medication Free Text Sig
			Target: HS.SDA3.AbstractOrder TextInstruction
			Target: /Container/Medications/Medication/TextInstruction
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/text
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/text
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/text
		-->
		<!--
			Field : Immunization Free Text Sig
			Target: HS.SDA3.AbstractOrder TextInstruction
			Target: /Container/Vaccinations/Vaccination/TextInstruction
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/text
		-->
		<xsl:variable name="sigText"><xsl:apply-templates select="." mode="fn-TextValue"/></xsl:variable>
		<xsl:if test="string-length(normalize-space($sigText))">
			<TextInstruction><xsl:value-of select="$sigText"/></TextInstruction>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hl7:effectiveTime" mode="eM-Duration">
		<!--
			Field : Medication Duration Start
			Target: HS.SDA3.AbstractOrder Duration
			Target: /Container/Medications/Medication/Duration
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/low/@value
		-->
		<!--
			Field : Medication Duration End
			Target: HS.SDA3.AbstractOrder Duration
			Target: /Container/Medications/Medication/Duration
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
		-->
		<!--
			Field : Immunization Duration
			Target: HS.SDA3.AbstractOrder Duration
			Target: /Container/Vaccinations/Vaccination/Duration
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime/@value
			Note  : CDA Immunization will most likely only have effectiveTime/@value.
					In that case effectiveTime/@value is used as the start and end
					time when calculating Duration.
		-->
		<!--
			Field : Immunization Duration
			Target: HS.SDA3.AbstractOrder Duration
			Target: /Container/Vaccinations/Vaccination/Duration
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/effectiveTime[@xsi:type='IVL_TS']/high/@value
			Note  : CDA Immunization will most likely only have effectiveTime/@value.
					In that case effectiveTime/@value is used as the start and end
					time when calculating Duration.
		-->
		<xsl:variable name="medicationStartDateTime" select="@value | hl7:low/@value"/>
		<xsl:variable name="medicationEndDateTime" select="@value | hl7:high/@value"/>
		<!--
			The Duration is the number of days from start date to
			end date, inclusive.  For example a duration of Monday
			the 1st through Friday the 5th is 5 days, not 5-1=4 days.
		-->
		<xsl:variable name="durationTemp"
			select="
				isc:evaluate('dateDiff', 'dd',
				concat(substring($medicationStartDateTime, 5, 2), '-', substring($medicationStartDateTime, 7, 2), '-', substring($medicationStartDateTime, 1, 4)),
				concat(substring($medicationEndDateTime, 5, 2), '-', substring($medicationEndDateTime, 7, 2), '-', substring($medicationEndDateTime, 1, 4)))"/>
		<xsl:variable name="durationValueInDays">
			<xsl:if test="string-length($durationTemp)">
				<xsl:value-of select="number($durationTemp) + 1"/>
			</xsl:if>
			<!-- otherwise, the null string -->
		</xsl:variable>

		<xsl:if test="string-length($durationValueInDays)">
			<Duration>
				<Code>
					<xsl:value-of select="concat($durationValueInDays, 'd')"/>
				</Code>
				<xsl:choose>
					<xsl:when test="$durationValueInDays > 1">
						<Description>
							<xsl:value-of select="concat($durationValueInDays, ' days')"/>
						</Description>
					</xsl:when>
					<xsl:otherwise>
						<Description>
							<xsl:value-of select="concat($durationValueInDays, ' day')"/>
						</Description>
					</xsl:otherwise>
				</xsl:choose>
			</Duration>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:substanceAdministration" mode="eM-ComponentMed">
		<xsl:param name="medicationType"/>
		<xsl:if test="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial">
			<DrugProduct>
				<xsl:choose>
					<xsl:when test="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/@code">
						<xsl:apply-templates select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code" mode="fn-CodeTable"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="componentName">
							<xsl:choose>
								<xsl:when test="string-length(substring-after(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/hl7:reference/@value, '#'))">
									<xsl:value-of	select="normalize-space(key('narrativeKey', substring-after(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/hl7:reference/@value, '#')))"/>
								</xsl:when>
								<xsl:when test="string-length(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/text())">
									<xsl:value-of select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:code/hl7:originalText/text()"/>
								</xsl:when>
								<xsl:when test="string-length(hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:name/text())">
									<xsl:value-of select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial/hl7:name/text()"/>
								</xsl:when>
							</xsl:choose>
						</xsl:variable>
						<Code>
							<xsl:value-of select="$componentName"/>
						</Code>
						<Description>
							<xsl:value-of select="$componentName"/>
						</Description>
					</xsl:otherwise>
				</xsl:choose>
			</DrugProduct>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="eM-AuthorTime">
		<!--
			Field : Medication Author Time
			Target: HS.SDA3.AbstractOrder EnteredOn
			Target: /Container/Medications/Medication/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/author/time/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/author/time/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/author/time/@value
		-->
		<!--
			Field : Immunization Author Time
			Target: HS.SDA3.AbstractOrder EnteredOn
			Target: /Container/Vaccinations/Vaccination/Administrations/Administration/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/author/time/@value
		-->
		<!--
			Field : Medication Author Time
			Target: HS.SDA3.AbstractOrder EnteredOn
			Target: /Container/Medications/Medication/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.1.1']/entry/substanceAdministration/entryRelationship[@typeCode='REFR']/supply[@moodCode='EVN']/author/time/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.38']/entry/substanceAdministration/entryRelationship[@typeCode='REFR']/supply[@moodCode='EVN']/author/time/@value
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.11.1']/entry/substanceAdministration/entryRelationship[@typeCode='REFR']/supply[@moodCode='EVN']/author/time/@value
		-->
		<!--
			Field : Immunization Author Time
			Target: HS.SDA3.AbstractOrder EnteredOn
			Target: /Container/Vaccinations/Vaccination/Administrations/Administration/EnteredOn
			Source: /ClinicalDocument/component/structuredBody/component/section[templateId/@root='2.16.840.1.113883.10.20.22.2.2.1']/entry/substanceAdministration/entryRelationship[@typeCode='REFR']/supply[@moodCode='EVN']/author/time/@value
		-->
		<xsl:choose>
			<xsl:when test="hl7:author/hl7:time/@value">
				<xsl:apply-templates select="hl7:author/hl7:time/@value" mode="fn-E-paramName-timestamp">
					<xsl:with-param name="emitElementName" select="'EnteredOn'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']/hl7:author/hl7:time/@value">
				<xsl:apply-templates select="hl7:entryRelationship[@typeCode='REFR']/hl7:supply[@moodCode='EVN']/hl7:author/hl7:time/@value" mode="fn-E-paramName-timestamp">
					<xsl:with-param name="emitElementName" select="'EnteredOn'"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!--
		This empty template may be overridden with custom logic.
		The input node spec is normally $sectionRootPath/hl7:entry/hl7:substanceAdministration.
		The medicationType is passed down from mode="eM-Medication" (see comments at top of that template).
	-->
	<xsl:template match="*" mode="eM-ImportCustom-Medication">
		<xsl:param name="medicationType" select="'MED'"/>
	</xsl:template>
	
</xsl:stylesheet>
