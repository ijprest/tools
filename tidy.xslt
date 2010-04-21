<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">
	<xsl:output method="text"/>

	<!-- match the root -->
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- comment nodes -->
	<xsl:template match="//comment()">
		<xsl:param name="indent"></xsl:param>
		<xsl:choose>
			<xsl:when test="contains(preceding-sibling::node()[1],'&#10;') and not(starts-with(.,':'))">
				<xsl:call-template name="add-cr">
					<xsl:with-param name="text">
						<xsl:value-of select="preceding-sibling::node()[1]"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$indent"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&lt;!--</xsl:text>
		<xsl:if test="not(starts-with(.,':'))">
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:value-of select="normalize-space()"/>
		<xsl:text> --&gt;</xsl:text>
	</xsl:template>
	
	<!-- text nodes -->
	<xsl:template match="//text()"><xsl:value-of select="normalize-space()"/></xsl:template>
	
	<!-- nodes with children -->
	<xsl:template match="node()[.//node()]">
		<xsl:param name="indent"></xsl:param>
		<xsl:call-template name="add-cr">
			<xsl:with-param name="text">
				<xsl:value-of select="preceding-sibling::node()[1]"/>
			</xsl:with-param>
		</xsl:call-template>

		<!-- open tag -->
		<xsl:value-of select="$indent"/>
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name()"/>
		<!-- attributes -->
		<xsl:apply-templates select="." mode="attrs">
			<xsl:with-param name="indent"><xsl:value-of select="$indent"/></xsl:with-param>
		</xsl:apply-templates>
		<xsl:text>&gt;</xsl:text>

		<!-- output children; deeper indent -->
		<xsl:apply-templates select="./node()">
			<xsl:with-param name="indent">
				<xsl:text>  </xsl:text>
				<xsl:value-of select="$indent"/>
			</xsl:with-param>
		</xsl:apply-templates>
		
		<!-- close tag -->
		<xsl:if test="contains(.,'&#10;')">
			<xsl:text>&#13;</xsl:text>
			<xsl:value-of select="$indent"/>
		</xsl:if>
		<xsl:text>&lt;/</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>&gt;</xsl:text>
	</xsl:template>

	<!-- nodes w/o children -->
	<xsl:template match="node()">
		<xsl:param name="indent"></xsl:param>
		<xsl:call-template name="add-cr">
			<xsl:with-param name="text">
				<xsl:value-of select="preceding-sibling::node()[1]"/>
			</xsl:with-param>
		</xsl:call-template>

		<!-- open tag -->
		<xsl:value-of select="$indent"/>
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name()"/>
		<!-- attributes -->
		<xsl:apply-templates select="." mode="attrs">
			<xsl:with-param name="indent"><xsl:value-of select="$indent"/></xsl:with-param>
		</xsl:apply-templates>
		<xsl:text>/&gt;</xsl:text>
	</xsl:template>
	
	<!-- simple attribute -->
	<xsl:template match="@*">
		<xsl:param name="indent"><xsl:text> </xsl:text></xsl:param>
		<xsl:value-of select="$indent"/>
		<xsl:value-of select="name()"/>
		<xsl:text>="</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>"</xsl:text>
	</xsl:template>
	
	<!-- large attribute list -->
	<xsl:template match="node()[count(./@*) &gt; 4]" mode="attrs">
		<xsl:param name="indent"></xsl:param>
		<xsl:apply-templates select="./@*[position()=1]"/>
		<xsl:apply-templates select="./@*[position()>1]">
			<xsl:with-param name="indent">
				<xsl:text>&#13;</xsl:text>
				<xsl:call-template name="spaces">
					<xsl:with-param name="count">
						<xsl:value-of select="string-length(name()) + 2"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$indent"/>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<!-- small attribute list (default) -->
	<xsl:template match="node()" mode="attrs">
		<xsl:param name="indent"></xsl:param>
		<xsl:apply-templates select="./@*"/>
	</xsl:template>
	
	<!-- itemData attribute list -->
	<xsl:template match="itemData[./@*]" mode="attrs">
		<xsl:param name="indent"></xsl:param>
		<xsl:variable name="attrindent">
			<xsl:text>&#13;</xsl:text>
			<xsl:call-template name="spaces">
				<xsl:with-param name="count">
					<xsl:value-of select="string-length(name()) + 2"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$indent"/>
		</xsl:variable>

		<!-- special sorting; guid, component, bmpRow, bmpCol (all on one line) -->
		<xsl:apply-templates select="@guid"/>
		<xsl:apply-templates select="@component"/>
		<xsl:apply-templates select="@bmpRow"/>
		<xsl:apply-templates select="@bmpCol"/>
		<xsl:apply-templates select="@noBmpOnMenu"/>

		<!-- type (on new line) -->
		<xsl:apply-templates select="@type"><xsl:with-param name="indent"><xsl:value-of select="$attrindent"/></xsl:with-param></xsl:apply-templates>
		
		<!-- all other attributes, sorted -->
		<xsl:apply-templates select="./@*[name() != 'guid' and name() != 'component' and name() != 'bmpRow' and name() != 'bmpCol' and name() != 'type' and name() != 'noBmpOnMenu']">
			<xsl:sort select="name()"/>
			<xsl:with-param name="indent">
				<xsl:value-of select="$attrindent"/>
			</xsl:with-param>
		</xsl:apply-templates>
		
	</xsl:template>

	<!-- generate a number of spaces -->
	<xsl:template name="spaces">
		<xsl:param name="count">0</xsl:param>
		<xsl:if test="$count &gt; 0">
			<xsl:text> </xsl:text>
			<xsl:call-template name="spaces">
				<xsl:with-param name="count"><xsl:value-of select="$count - 1"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- generate a number of blank lines -->
	<xsl:template name="add-cr">
		<xsl:param name="text"></xsl:param>
		<xsl:variable name="text-new"><xsl:value-of select="substring-after($text,'&#10;')"/></xsl:variable>
		<xsl:if test="contains($text,'&#10;')">
			<xsl:text>&#13;</xsl:text>
			<xsl:call-template name="add-cr">
				<xsl:with-param name="text">
					<xsl:value-of select="$text-new"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
