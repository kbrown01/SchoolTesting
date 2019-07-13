<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
    version="1.0">
    <!-- Header/Footer Structures -->
    <xsl:template name="header">
        <fo:table margin-top="{$default.header-start}" border-bottom="1pt solid black" width="100%">
            <fo:table-body>
                <fo:table-row>
                    <fo:table-cell text-align="left">
                        <xsl:element name="fo:block" use-attribute-sets="header">
                            <xsl:call-template name="output-content">
                                <xsl:with-param name="element" select="forminfo/header1"/>
                            </xsl:call-template>
                        </xsl:element>
                    </fo:table-cell>
                    <fo:table-cell text-align="right">
                        <xsl:element name="fo:block" use-attribute-sets="header">
                            <xsl:call-template name="output-content">
                                <xsl:with-param name="element" select="forminfo/header2"/>
                            </xsl:call-template>
                        </xsl:element>
                    </fo:table-cell>
                </fo:table-row>
                <xsl:if test="forminfo/header3 | forminfo/header4">
                    <fo:table-row>
                        <fo:table-cell text-align="left">
                            <xsl:element name="fo:block" use-attribute-sets="header">
                                <xsl:call-template name="output-content">
                                    <xsl:with-param name="element" select="forminfo/header3"/>
                                </xsl:call-template>
                            </xsl:element>
                        </fo:table-cell>
                        <fo:table-cell text-align="right">
                            <xsl:element name="fo:block" use-attribute-sets="header">
                                <xsl:call-template name="output-content">
                                    <xsl:with-param name="element" select="forminfo/header4"/>
                                </xsl:call-template>
                            </xsl:element>
                        </fo:table-cell>
                    </fo:table-row>
                </xsl:if>
            </fo:table-body>
        </fo:table>
    </xsl:template>

    <xsl:template name="footer">
        <fo:table padding-top="{$default.footer-start}" border-top="1pt solid black" width="100%">
            <fo:table-column column-width="33%"/>
            <fo:table-column column-width="34%"/>
            <fo:table-column column-width="33%"/>
            <fo:table-body>
                <fo:table-row>
                    <fo:table-cell text-align="left">
                        <xsl:element name="fo:block" use-attribute-sets="footer">
                            <xsl:call-template name="output-content">
                                <xsl:with-param name="element" select="forminfo/footer1"/>
                            </xsl:call-template>
                        </xsl:element>
                    </fo:table-cell>
                    <fo:table-cell text-align="center">
                        <xsl:element name="fo:block" use-attribute-sets="footer">
                            <xsl:call-template name="output-content">
                                <xsl:with-param name="element" select="forminfo/footer2"/>
                            </xsl:call-template>
                        </xsl:element>
                    </fo:table-cell>
                    <fo:table-cell text-align="right">
                        <xsl:element name="fo:block" use-attribute-sets="footer">
                            <xsl:call-template name="output-content">
                                <xsl:with-param name="element" select="forminfo/footer3"/>
                            </xsl:call-template>
                        </xsl:element>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:template>
    <xsl:template name="output-content">
        <xsl:param name="element"/>
        <xsl:choose>
            <xsl:when test="$element/@type = 'link'">
                <fo:basic-link color="blue" text-decoration="underline">
                    <xsl:attribute name="external-destination">
                        <xsl:text>url('</xsl:text>
                        <xsl:choose>
                            <xsl:when test="$element/@url">
                                <xsl:value-of select="$element/@url"/>        
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$element"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>')</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates select="$element"/>
                </fo:basic-link>
            </xsl:when>
            <xsl:when test="$element/@type = 'logo'">
                <fo:external-graphic>
                    <xsl:attribute name="src">
                        <xsl:text>url('</xsl:text>
                        <xsl:value-of select="$element"/>
                        <xsl:text>')</xsl:text>
                    </xsl:attribute>
                </fo:external-graphic>
            </xsl:when>
            <xsl:when test="$element/@type = 'page'"> Page <fo:page-number/> of
                    <fo:page-number-citation-last ref-id="end_of_document"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$element"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
