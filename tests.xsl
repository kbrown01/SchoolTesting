<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
    version="1.0">
    <!-- This style sheet is a modified version of checklist.xsl from RenderX.
         It has been changed to provide a new function for test taking. -->
    <!-- Include XML to string processor -->
    <xsl:import href="xml-to-string.xsl"/>
    <!-- include header and footer structures -->
    <xsl:include href="header-footer.xsl"/>
    <xsl:output method="xml" version="1.0" encoding="UTF-8"/>
    <!-- Output Type Parameter
        One of the following types:
        fillable:   output a fillable test for the student
        flat:       output a filled document with test answers for off-line grading
        compressed: output a partially-filled document with multiple choice selections graded and space for teacher comments
        blank:      output the teacher's final print version with answers and teach comments
        -->
    <xsl:param name="output-type">fillable</xsl:param>
    <!-- Your Unique Project ID for RenderX Server-side Processing -->
    <xsl:param name="projectid" select="form/@projectid"/>
    <!-- Hidden Form Submit Recipient Email (the email address to receive the form submit results) -->
    <xsl:param name="form_administrator" select="form/@form-administrator"/>
    <!-- Load Customization Parameters -->
    <xsl:include href="customize.xsl"/>
    <!-- Process the Form -->
    <xsl:template match="form">
        <xsl:element name="fo:root" use-attribute-sets="default">
            <rx:meta-info>
                <rx:meta-field name="title">
                    <xsl:attribute name="value">
                        <xsl:value-of select="@title"/>
                    </xsl:attribute>
                </rx:meta-field>
                <rx:meta-field name="author">
                    <xsl:attribute name="value">
                        <xsl:value-of select="$form_administrator"/>
                    </xsl:attribute>
                </rx:meta-field>
                <rx:meta-field name="creator" value="RenderX Checklist CoolTool"/>
                <rx:meta-field name="subject" value="Adobe PDF Form Generation using RenderX XEP"/>
                <rx:meta-field name="keywords" value="XML, XSL FO, PDF, RenderX, XEP, CoolTool"/>
            </rx:meta-info>
            <xsl:call-template name="javascript"/>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="page1" page-height="{$default.page-height}"
                    page-width="{$default.page-width}" margin-left="{$default.left-margin}"
                    margin-right="{$default.right-margin}">
                    <fo:region-body margin-top="{$default.top-margin}"
                        margin-bottom="{$default.bottom-margin}"/>
                    <fo:region-before extent="{$default.top-margin}"/>
                    <fo:region-after extent="{$default.bottom-margin}"/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <xsl:call-template name="process_form"/>
        </xsl:element>
    </xsl:template>
    <xsl:template name="process_form">
        <fo:page-sequence master-reference="page1">
            <fo:static-content flow-name="xsl-region-before">
                <xsl:call-template name="header"/>
            </fo:static-content>
            <fo:static-content flow-name="xsl-region-after">
                <xsl:call-template name="footer"/>
            </fo:static-content>
            <fo:flow flow-name="xsl-region-body" id="end_of_document">
                <!-- If in teaching mode, output the grade block -->
                <xsl:if test="$output-type='blank' or $output-type='compressed'">
                    <xsl:call-template name="grading"/>
                </xsl:if>
                <!-- Output the form -->
                <xsl:apply-templates select="data"/>
                <xsl:if test="$output-type='fillable' or $output-type='compressed'">
                    <!-- Build Buttons -->
                    <xsl:if test="not(//buttons)">
                        <xsl:call-template name="build_buttons"/>
                    </xsl:if>
                    <!-- Output hidden fields in recipient -->
                    <xsl:apply-templates select="recipient" mode="hidden-fields"/>
                    <!-- Output hidden project level information -->
                    <xsl:call-template name="project_info"/>
                    <!-- Output hidden XML file in form -->
                    <xsl:call-template name="load-xml"/>
                </xsl:if>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>

    <xsl:template match="data">
        <xsl:if test="/form/@title">
            <xsl:element name="fo:block" use-attribute-sets="document_title">
                <xsl:value-of select="/form/@title"/>
            </xsl:element>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="instructions[parent::category]">
        <fo:table-row>
            <fo:table-cell number-columns-spanned="2">
                <xsl:for-each select="para">
                    <xsl:element name="fo:block" use-attribute-sets="default">
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:for-each>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>

    <xsl:template match="instructions">
        <xsl:for-each select="para">
            <xsl:element name="fo:block" use-attribute-sets="default">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- Inline Markup -->
    <xsl:template match="b">
        <fo:inline font-weight="bold">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="i">
        <fo:inline font-style="italic">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="u">
        <fo:inline text-decoration="underline">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="link">
        <xsl:apply-templates select="ancestor::form//node()[@name = current()/@nameref]"/>
    </xsl:template>
    <xsl:template match="basic-link">
        <xsl:element name="fo:basic-link" use-attribute-sets="basic-link">
            <xsl:attribute name="external-destination">
                <xsl:text>url('</xsl:text>
                <xsl:value-of select="@url"/>
                <xsl:text>')</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="br">
        <fo:block/>
    </xsl:template>

    <!-- Overall Structures -->
    <xsl:template match="section">
        <xsl:variable name="showpart">
            <xsl:call-template name="show_part"/>
        </xsl:variable>
        <xsl:if test="string-length($showpart) > 0">
            <fo:block-container>
                <xsl:call-template name="evalbreak"/>
                <xsl:apply-templates/>
            </fo:block-container>
        </xsl:if>
    </xsl:template>

    <xsl:template match="section/title">
        <xsl:element name="fo:block" use-attribute-sets="section_title">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="category">
        <xsl:variable name="showpart">
            <xsl:call-template name="show_part"/>
        </xsl:variable>
        <xsl:if test="string-length($showpart) > 0">
            <fo:block-container>
                <xsl:call-template name="evalbreak"/>
                <fo:table
                    width="{$default.page-width} - {$default.left-margin} - {$default.right-margin}"
                    border-collapse="collapse">
                    <fo:table-column column-width="10%"/>
                    <fo:table-column column-width="90%"/>
                    <fo:table-body>
                        <!-- <xsl:call-template name="cattitle"/> -->
                        <xsl:apply-templates/>
                    </fo:table-body>
                </fo:table>
            </fo:block-container>
        </xsl:if>
    </xsl:template>

    <xsl:template match="category/title">
        <fo:table-row keep-with-next.within-page="always">
            <fo:table-cell number-columns-spanned="2">
                <xsl:element name="fo:block" use-attribute-sets="category_title">
                    <xsl:apply-templates/>
                </xsl:element>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>

    <xsl:template match="item">
        <xsl:variable name="showpart">
            <xsl:call-template name="show_part"/>
        </xsl:variable>
        <xsl:if test="string-length($showpart) > 0">
            <fo:table-row keep-together.within-page="always">
                <xsl:if test="parent::group/@nobreak='true'">
                    <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
                </xsl:if>
                <fo:table-cell text-align="right" padding-right="5pt" padding-bottom="{$default.space-between-item}">
                    <xsl:apply-templates select="checkbox"/>
                </fo:table-cell>
                <fo:table-cell padding-bottom="{$default.space-between-item}">
                    <xsl:apply-templates select="description | instructions"/>
                </fo:table-cell>
            </fo:table-row>
        </xsl:if>
    </xsl:template>

    <xsl:template match="group">
        <xsl:variable name="showpart">
            <xsl:call-template name="show_part"/>
        </xsl:variable>
        <xsl:if test="string-length($showpart) > 0">
                <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="group/title">
        <fo:table-row keep-with-next.within-page="always">
            <fo:table-cell number-columns-spanned="2">
                <xsl:element name="fo:block" use-attribute-sets="group_title">
                    <xsl:apply-templates/>
                </xsl:element>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>

    <xsl:template match="description">
        <fo:block>
            <xsl:element name="fo:inline" use-attribute-sets="description">
                <xsl:apply-templates/>
            </xsl:element>
        </fo:block>
    </xsl:template>

    <!-- Form Elements -->
    <xsl:template match="checkbox">
        <xsl:choose>
            <xsl:when test="$output-type='flat'">
                <fo:block font-family="ZapfDingbats">
                    <xsl:choose>
                        <xsl:when test="@value='true'">
                            <xsl:value-of select="$default.cb-select"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$default.cb-noselect"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </xsl:when>
            <!-- New mode for teaching, mark questions right or wrong (only multiple choice ones)-->
            <xsl:when test="($output-type='blank' or $output-type='compressed') and not(following-sibling::description/optiongroup)">
                <fo:block font-family="ZapfDingbats">
                    <xsl:choose>
                        <xsl:when test="@value='true'">
                            <xsl:value-of select="$default.cb-select"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$default.cb-noselect"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </xsl:when>
            <xsl:when test="$output-type='compressed' or $output-type='blank'">
                <fo:block font-family="ZapfDingbats">
                    <xsl:choose>
                        <!-- Only two cases exists, a description/optiongroup/option has both value='true' and correct='true' then the answer is correct, otherwise it is wrong -->
                        <xsl:when test="following-sibling::description/optiongroup/option[@value='true' and @correct='true']">
                            <xsl:value-of select="$default.ob-select"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$default.ob-incorrect"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </xsl:when>
            <xsl:when test="$output-type='fillable'">
                <fo:block margin-left="10pt" font-size="{$default.font-size}">
                    <fo:inline>
                        <xsl:element name="rx:pdf-form-field">
                            <xsl:call-template name="form_field_attributes"/>
                            <xsl:element name="rx:pdf-form-field-checkbox"
                                use-attribute-sets="checklist_appearance">
                                <rx:pdf-form-field-option text="{$default.cb-select}">
                                    <xsl:attribute name="initially-selected">
                                        <xsl:value-of select="@value"/>
                                    </xsl:attribute>
                                </rx:pdf-form-field-option>
                                <rx:pdf-form-field-option text="&#x21;"/>
                            </xsl:element>
                        </xsl:element>
                        <fo:leader leader-length="{$default.font-size} + 2pt"/>
                    </fo:inline>
                </fo:block>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="checkbox[parent::description]">
        <xsl:choose>
            <xsl:when
                test="$output-type='blank' or $output-type='flat' or $output-type='compressed'">
                <fo:inline font-family="ZapfDingbats">
                    <xsl:choose>
                        <xsl:when test="@value='true'">
                            <xsl:value-of select="$default.cb-select"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$default.cb-noselect"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:inline>
            </xsl:when>
            <xsl:when test="$output-type='fillable'">
                <fo:inline font-size="{$default.font-size} + 2pt">
                    <fo:inline>
                        <xsl:element name="rx:pdf-form-field">
                            <xsl:call-template name="form_field_attributes"/>
                            <xsl:element name="rx:pdf-form-field-checkbox"
                                use-attribute-sets="checkbox_appearance">
                                <rx:pdf-form-field-option text="{$default.cb-select}">
                                    <xsl:attribute name="initially-selected">
                                        <xsl:value-of select="@value"/>
                                    </xsl:attribute>
                                </rx:pdf-form-field-option>
                                <rx:pdf-form-field-option text="&#x21;"/>
                            </xsl:element>
                        </xsl:element>
                        <fo:leader leader-length="{$default.font-size} + 2pt"/>
                    </fo:inline>
                </fo:inline>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="textbox">
        <xsl:choose>
            <xsl:when test="$output-type='blank'">
                <xsl:choose>
                    <xsl:when test="@length">
                        <fo:leader leader-pattern="rule">
                            <xsl:attribute name="leader-length">
                                <xsl:value-of select="@length"/>
                            </xsl:attribute>
                        </fo:leader>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:leader leader-pattern="rule"
                            leader-length=".9 * ({$default.page-width} - {$default.right-margin} - {$default.left-margin})"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$output-type='flat'">
                <fo:inline>
                    <xsl:value-of select="."/>
                </fo:inline>
            </xsl:when>
            <xsl:when test="$output-type='compressed'">
                <fo:inline>
                    <xsl:value-of select="."/>
                </fo:inline>
            </xsl:when>
            <xsl:when test="$output-type='fillable'">
                <fo:inline font-size="{$default.font-size} + 4pt">
                    <rx:pdf-form-field font-size="{$default.font-size}">
                        <xsl:call-template name="form_field_attributes"/>
                        <xsl:element name="rx:pdf-form-field-text"
                            use-attribute-sets="standard_text textbox_appearance">
                            <xsl:attribute name="text">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                        </xsl:element>
                    </rx:pdf-form-field>
                    <xsl:choose>
                        <xsl:when test="@length">
                            <fo:inline>
                                <fo:leader>
                                    <xsl:attribute name="leader-length">
                                        <xsl:value-of select="@length"/>
                                    </xsl:attribute>
                                </fo:leader>
                            </fo:inline>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:block>
                                <fo:leader
                                    leader-length=".9 * ({$default.page-width} - {$default.right-margin} - {$default.left-margin})"
                                />
                            </fo:block>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:inline>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="multiline">
        <xsl:choose>
            <xsl:when test="$output-type='flat'">
                <fo:block linefeed-treatment="preserve">
                    <xsl:value-of select="."/>
                </fo:block>
            </xsl:when>
            <!-- Add a new condition for teacher comments -->
            <xsl:when test="$output-type='compressed' and ancestor::item[@user='teacher']">
                <fo:block-container text-align="start">
                    <xsl:attribute name="height">
                        <xsl:value-of select="@height"/>
                    </xsl:attribute>
                    <rx:pdf-form-field font-size="{$default.font-size}">
                        <xsl:call-template name="form_field_attributes"/>
                        <xsl:element name="rx:pdf-form-field-text"
                            use-attribute-sets="standard_text teacher_textbox_appearance">
                            <xsl:attribute name="multiline">true</xsl:attribute>
                            <xsl:attribute name="text">
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:attribute>
                        </xsl:element>
                    </rx:pdf-form-field>
                    <fo:block/>
                </fo:block-container>
            </xsl:when>
            <xsl:when test="$output-type='blank' and ancestor::item[@user='teacher']">
                <fo:block linefeed-treatment="preserve" color="red" border="1pt solid silver" background-color="lightyellow">
                    <xsl:value-of select="."/>
                </fo:block>
            </xsl:when>
            <xsl:when test="$output-type='compressed' or $output-type='blank'">
                <fo:block linefeed-treatment="preserve">
                    <xsl:value-of select="."/>
                </fo:block>
            </xsl:when>
            <xsl:when test="$output-type='fillable'">
                <fo:block-container text-align="start">
                    <xsl:attribute name="height">
                        <xsl:value-of select="@height"/>
                    </xsl:attribute>
                    <rx:pdf-form-field font-size="{$default.font-size}">
                        <xsl:call-template name="form_field_attributes"/>
                        <xsl:element name="rx:pdf-form-field-text"
                            use-attribute-sets="standard_text textbox_appearance">
                            <xsl:attribute name="multiline">true</xsl:attribute>
                            <xsl:attribute name="text">
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:attribute>
                        </xsl:element>
                    </rx:pdf-form-field>
                    <fo:block/>
                </fo:block-container>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    

    <xsl:template match="combobox">
        <xsl:variable name="testvalue">
            <xsl:for-each select="option">
                <xsl:if test="@value">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="selection">
            <xsl:choose>
                <xsl:when test="$testvalue = ''"> None </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$testvalue"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="fieldsize">
            <xsl:choose>
                <xsl:when test="@length">
                    <xsl:value-of select="@length"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>1in</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$output-type='blank'">
                <!-- Output a table with each option in a row -->
                <fo:table width="{$fieldsize} * 1.1">
                    <fo:table-column column-width="{$fieldsize} * 0.1"/>
                    <fo:table-column column-width="{$fieldsize}"/>
                    <fo:table-body>
                        <xsl:for-each select="option">
                            <fo:table-row>
                                <fo:table-cell padding-right="3pt">
                                    <fo:block font-family="ZapfDingbats">
                                        <xsl:value-of select="$default.cb-noselect"/>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block>
                                        <xsl:if test="@value">
                                            <xsl:attribute name="font-weight">bold</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="."/>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </xsl:for-each>
                    </fo:table-body>
                </fo:table>
            </xsl:when>
            <xsl:when test="$output-type='flat'">
                <fo:inline>
                    <xsl:value-of select="$selection"/>
                </fo:inline>
            </xsl:when>
            <xsl:when test="$output-type='compressed'">
                <fo:inline>
                    <xsl:value-of select="$selection"/>
                </fo:inline>
            </xsl:when>
            <xsl:when test="$output-type='fillable'">
                <fo:inline font-size="{$default.font-size} + 4pt">
                    <rx:pdf-form-field font-size="{$default.font-size}">
                        <xsl:call-template name="form_field_attributes"/>
                        <xsl:element name="rx:pdf-form-field-combobox"
                            use-attribute-sets="standard_text combobox_appearance">
                            <xsl:for-each select="option">
                                <rx:pdf-form-field-option>
                                    <xsl:attribute name="text">
                                        <xsl:value-of select="."/>
                                    </xsl:attribute>
                                    <xsl:if test="@value">
                                        <xsl:attribute name="initially-selected"
                                            >true</xsl:attribute>
                                    </xsl:if>
                                </rx:pdf-form-field-option>
                            </xsl:for-each>
                        </xsl:element>
                    </rx:pdf-form-field>
                    <fo:inline>
                        <fo:leader leader-length="{$fieldsize}"/>
                    </fo:inline>
                </fo:inline>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="optiongroup">
        <xsl:variable name="arrangement">
            <xsl:choose>
                <xsl:when test="@arrangement">
                    <xsl:value-of select="@arrangement"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$default.og-arrangement"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="option">
            <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="$arrangement = 'vertical'">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate(.,' ','&#360;')"/>
                </xsl:otherwise>
            </xsl:choose>
            </xsl:variable>
            <xsl:if test="$arrangement = 'vertical'">
                <fo:block/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$output-type='flat'">
                    <fo:inline>
                        <fo:inline font-family="ZapfDingbats" padding-left="5pt">
                            <xsl:choose>
                                <xsl:when test="@value='true'">
                                    <xsl:value-of select="$default.ob-select"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$default.cb-noselect"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:inline>
                        <fo:inline padding-left="3pt">
                            <xsl:value-of select="$value"/>
                            <xsl:text>&#x200b;</xsl:text>
                        </fo:inline>
                    </fo:inline>
                </xsl:when>
                <!-- New mode for teaching, indicate correct answers -->
                <xsl:when test="$output-type='compressed' or $output-type='blank'">
                    <fo:inline>
                        <fo:inline font-family="ZapfDingbats" padding-left="5pt">
                            <xsl:choose>
                                <xsl:when test="@value='true' and @correct='true'">
                                    <xsl:value-of select="$default.ob-select"/>
                                </xsl:when>
                                <xsl:when test="@value='true'">
                                    <xsl:value-of select="$default.ob-incorrect"/>
                                </xsl:when>
                                <xsl:when test="@correct='true'">
                                    <xsl:value-of select="$default.ob-select"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$default.cb-noselect"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:inline>
                        <fo:inline padding-left="3pt">
                            <xsl:if test="@correct='true'">
                                <xsl:attribute name="font-weight">bold</xsl:attribute>
                                <xsl:attribute name="color">green</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$value"/>
                            <xsl:text>&#x200b;</xsl:text>
                        </fo:inline>
                    </fo:inline>
                </xsl:when>
                <xsl:when test="$output-type='fillable'">
                    <fo:inline>
                        <fo:leader leader-length="5pt"/>
                    </fo:inline>
                    <fo:inline font-size="{$default.font-size} + 2pt">
                        <xsl:element name="rx:pdf-form-field"
                            use-attribute-sets="checkbox_appearance">
                            <xsl:call-template name="form_field_attributes"/>
                            <xsl:element name="rx:pdf-form-field-radio-button"
                                use-attribute-sets="checkbox_appearance">
                                <xsl:attribute name="group-name">
                                    <xsl:choose>
                                        <xsl:when test="parent::optiongroup/@name">
                                            <xsl:value-of select="parent::optiongroup/@name"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="generate-id(parent::optiongroup)"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:element name="rx:pdf-form-field-option">
                                    <xsl:attribute name="text">
                                        <xsl:value-of select="$default.ob-select"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="font-size">
                                        <xsl:value-of select="$default.font-size"/>
                                    </xsl:attribute>
                                    <xsl:if test="@value">
                                        <xsl:attribute name="initially-selected">
                                            <xsl:value-of select="@value"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                </xsl:element>
                                <xsl:element name="rx:pdf-form-field-option">
                                    <xsl:attribute name="text">
                                        <xsl:text>&#x21;</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="font-size">
                                        <xsl:value-of select="$default.font-size"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                        <fo:leader leader-length="16pt"/>
                    </fo:inline>
                    <xsl:element name="fo:inline"
                        use-attribute-sets="standard_text optiontext_appearance">
                        <xsl:value-of select="$value"/>
                        <xsl:text>&#x200b;</xsl:text>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!-- Insert the Javascript Library -->
    <xsl:template name="javascript">
        <rx:pdf-javascript name="RXjslib">
            <xsl:value-of select="document('RXjslib.js')/javascript"/>
        </rx:pdf-javascript>
    </xsl:template>
    <!-- Common Field-level Javascript Attributes -->
    <xsl:template name="calculate">
        <xsl:if test="@calculate">
            <xsl:attribute name="js-calculate">
                <xsl:value-of select="@calculate"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template name="validate">
        <xsl:if test="@validate">
            <xsl:attribute name="js-validate">
                <xsl:value-of select="@validate"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template name="format">
        <xsl:if test="@format">
            <xsl:attribute name="js-format">
                <xsl:value-of select="@format"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template name="keystroke">
        <xsl:if test="@keystroke">
            <xsl:attribute name="js-keystroke">
                <xsl:value-of select="@keystroke"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- Other Form Field Attributes -->
    <xsl:template name="form_field_attributes">
        <xsl:call-template name="fieldname"/>
        <xsl:call-template name="readonly"/>
        <xsl:call-template name="maxlen"/>
        <xsl:call-template name="calculate"/>
        <xsl:call-template name="validate"/>
        <xsl:call-template name="format"/>
        <xsl:call-template name="keystroke"/>
    </xsl:template>
    <xsl:template name="maxlen">
        <xsl:if test="@maxlen">
            <xsl:attribute name="maxlen">
                <xsl:value-of select="@maxlen"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template name="fieldname">
        <xsl:attribute name="name">
            <xsl:choose>
                <xsl:when test="@name">
                    <xsl:value-of select="@name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="generate-id(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template name="readonly">
        <xsl:if test="@readonly">
            <xsl:attribute name="readonly">
                <xsl:value-of select="@readonly"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- Hidden Fields -->
    <xsl:template match="*" mode="hidden-fields" priority="2">
        <xsl:if test="@hidden">
            <fo:block-container>
                <rx:pdf-form-field hidden="true">
                    <xsl:call-template name="fieldname"/>
                    <rx:pdf-form-field-text>
                        <xsl:attribute name="text">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </rx:pdf-form-field-text>
                </rx:pdf-form-field>
            </fo:block-container>
        </xsl:if>
        <xsl:apply-templates mode="hidden-fields"/>
    </xsl:template>
    <xsl:template match="text()" mode="hidden-fields"/>
    <!-- Other Project Information -->
    <xsl:template name="project_info">
        <fo:block-container>
            <rx:pdf-form-field hidden="true" name="projectid">
                <rx:pdf-form-field-text>
                    <xsl:attribute name="text">
                        <xsl:value-of select="$projectid"/>
                    </xsl:attribute>
                </rx:pdf-form-field-text>
            </rx:pdf-form-field>
        </fo:block-container>
        <fo:block-container>
            <rx:pdf-form-field hidden="true" name="form_administrator">
                <rx:pdf-form-field-text>
                    <xsl:attribute name="text">
                        <xsl:value-of select="$form_administrator"/>
                    </xsl:attribute>
                </rx:pdf-form-field-text>
            </rx:pdf-form-field>
        </fo:block-container>
    </xsl:template>
    <!-- Insert the Source XML into the Form Hidden for Server-side Processing -->
    <xsl:template name="load-xml">
        <xsl:variable name="xmltext">
            <xsl:call-template name="xml-to-string">
                <xsl:with-param name="node-set" select="/"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- xmltext contains the XML file. Adobe software only allows a certain number of characters in a field so we need to chop this apart and place in multiple fields -->
        <xsl:call-template name="span-string-to-hidden">
            <xsl:with-param name="index">1</xsl:with-param>
            <xsl:with-param name="splitlength">10000</xsl:with-param>
            <xsl:with-param name="string" select="$xmltext"/>
        </xsl:call-template>
    </xsl:template>
    <!-- Added for tests - output the grading area -->
    <xsl:template name="grading">
        <fo:block-container border="1pt solid red" position="absolute" left="4.5in" top="0in" height=".6in" width="2.5in" background-color="lightyellow" padding="3pt">
            <fo:block>
            <xsl:variable name="correct">
                <xsl:value-of select="count(//optiongroup/option[@value='true' and @correct='true'])"/>
            </xsl:variable>
            <xsl:variable name="totalques">
                <xsl:value-of select="count(//optiongroup)"/>
            </xsl:variable>
            <fo:table width="100%" table-layout="fixed">
                <fo:table-column width=".75in"/>
                <fo:table-column/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell border-right="1pt solid black"><fo:block>Multiple Choice:</fo:block></fo:table-cell>
                        <fo:table-cell padding-left="3pt">
                            <fo:block>
                                <fo:inline font-size="{$default.font-size}">
                                    <xsl:choose>
                                        <xsl:when test="$output-type = 'compressed'">
                                            <rx:pdf-form-field font-size="{$default.font-size}" color="red">
                                                <xsl:attribute name="name">multi-grade</xsl:attribute>
                                                <xsl:attribute name="readonly">true</xsl:attribute>
                                                <xsl:element name="rx:pdf-form-field-text">
                                                    <xsl:attribute name="text">
                                                        <xsl:value-of select="$correct"/>
                                                    </xsl:attribute>
                                                </xsl:element>
                                            </rx:pdf-form-field><fo:leader leader-length="14pt"/> out of <xsl:value-of select="$totalques"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$correct"/> out of <xsl:value-of select="$totalques"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </fo:inline>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row>
                        <fo:table-cell border-right="1pt solid black">
                            <fo:block>Essays:</fo:block>
                        </fo:table-cell>
                        <fo:table-cell padding-left="3pt">
                                <fo:block>
                                <fo:inline font-size="{$default.font-size} + 1pt">
                                    <xsl:choose>
                                        <xsl:when test="$output-type = 'compressed'">
                                            <rx:pdf-form-field font-size="{$default.font-size}" js-keystroke="isInteger();">
                                                <xsl:attribute name="name">essay-grade</xsl:attribute>
                                                <xsl:element name="rx:pdf-form-field-text"
                                                    use-attribute-sets="standard_text textbox_appearance">
                                                    <xsl:attribute name="text">
                                                        <xsl:value-of select="/form/recipient/essaygrade"/>
                                                    </xsl:attribute>
                                                </xsl:element>
                                            </rx:pdf-form-field>
                                            <fo:leader leader-length=".75in"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="/form/recipient/essaygrade"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </fo:inline>
                                </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row border-top="1pt solid black" font-weight="bold">
                        <fo:table-cell border-right="1pt solid black">
                            <fo:block margin-top="1pt" margin-bottom="1pt">Total Score:</fo:block>
                        </fo:table-cell>
                        <fo:table-cell padding-left="3pt">
                            <fo:block>
                                <fo:inline font-size="{$default.font-size}">
                                    <xsl:choose>
                                        <xsl:when test="$output-type = 'compressed'">
                                            <rx:pdf-form-field font-size="{$default.font-size}" color="red" js-calculate="calctotal();">
                                                <xsl:attribute name="name">total-grade</xsl:attribute>
                                                <xsl:attribute name="readonly">true</xsl:attribute>
                                                <xsl:element name="rx:pdf-form-field-text">
                                                    <xsl:attribute name="text">
                                                        <xsl:value-of select="/form/recipient/totalgrade"/>
                                                    </xsl:attribute>
                                                </xsl:element>
                                            </rx:pdf-form-field><fo:leader leader-length="14pt"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="/form/recipient/totalgrade"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </fo:inline>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
            </fo:block>
        </fo:block-container>
    </xsl:template>
    <!-- Output the buttons here -->
    <xsl:template match="buttons">
        <xsl:if test="$output-type='fillable' or $output-type='compressed'">
            <xsl:call-template name="build_buttons"/>
        </xsl:if>
    </xsl:template>
    <!-- Build the Form's Action Buttons -->
    <xsl:template name="build_buttons">
        <xsl:variable name="button.position">
            <xsl:choose>
                <xsl:when test="@button_position">
                    <xsl:value-of select="@button_position"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$default.button_position"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="button.align">
            <xsl:choose>
                <xsl:when test="@button_align">
                    <xsl:value-of select="@button_align"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$default.button_align"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <fo:block-container text-align="{$button.align}">
            <xsl:choose>
                <xsl:when test="$button.position='top'">
                    <xsl:attribute name="position">absolute</xsl:attribute>
                    <xsl:attribute name="top">
                        <xsl:text>-1 * </xsl:text>
                        <xsl:value-of select="$default.top-margin"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="$button.position='bottom'">
                    <xsl:attribute name="position">absolute</xsl:attribute>
                    <xsl:attribute name="top">
                        <xsl:value-of select="$default.page-height"/>
                        <xsl:text> - </xsl:text>
                        <xsl:value-of select="$default.top-margin"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="padding-top">6pt</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <fo:block padding-top="2pt">
                <fo:inline>
                    <xsl:for-each select="/form/actions/action[@mode = $output-type]">
                        <fo:inline font-size="{$default.button_height}">
                            <xsl:choose>
                                <xsl:when test="$button.align='left'">
                                    <xsl:attribute name="padding-right">3pt</xsl:attribute>
                                </xsl:when>
                                <xsl:when test="$button.align='right'">
                                    <xsl:attribute name="padding-left">3pt</xsl:attribute>
                                </xsl:when>
                                <xsl:when test="$button.align='center'">
                                    <xsl:attribute name="padding-left">1.5pt</xsl:attribute>
                                    <xsl:attribute name="padding-right">1.5pt</xsl:attribute>
                                </xsl:when>
                            </xsl:choose>
                            <rx:pdf-form-field>
                                <xsl:attribute name="name">
                                    <xsl:value-of select="@name"/>
                                </xsl:attribute>
                                <xsl:choose>
                                    <xsl:when test="@type='submit'">
                                        <xsl:element name="rx:pdf-form-field-submit"
                                            use-attribute-sets="button_appearance">
                                            <xsl:attribute name="url">
                                                <xsl:value-of select="@url"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="text">
                                                <xsl:value-of select="@text"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="submit-format">
                                                <xsl:value-of select="$default.button_submit-format"
                                                />
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:when>
                                    <xsl:when test="@type='email'">
                                        <xsl:element name="rx:pdf-form-field-submit"
                                            use-attribute-sets="button_appearance">
                                            <xsl:attribute name="url">
                                                <xsl:text>mailto:</xsl:text>
                                                <xsl:value-of select="$form_administrator"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="text">
                                                <xsl:value-of select="@text"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="submit-format">
                                                <xsl:value-of select="$default.button_submit-format"
                                                />
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:when>
                                    <xsl:when test="@type='reset'">
                                        <xsl:element name="rx:pdf-form-field-reset"
                                            use-attribute-sets="button_appearance">
                                            <xsl:attribute name="text">
                                                <xsl:value-of select="@text"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:when>
                                </xsl:choose>
                            </rx:pdf-form-field>
                            <fo:inline>
                                <fo:leader leader-length="{$default.button_width}"/>
                            </fo:inline>
                        </fo:inline>
                    </xsl:for-each>
                </fo:inline>
            </fo:block>
        </fo:block-container>
    </xsl:template>
    <!-- Collapse Form Parts for "collapsed" Print Mode -->
    <xsl:template name="show_part">
        <!-- Modified for test taking -->
        <xsl:choose>
            <xsl:when test="$output-type='blank' or $output-type='flat'">
                <xsl:text>yes</xsl:text>
            </xsl:when>
            <xsl:when test="$output-type='fillable'">
                <!-- Hide teacher items -->
                <xsl:if test="not(@user) or @user!='teacher'">
                    <xsl:text>yes</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <!-- Show teacher items -->
                <xsl:text>yes</xsl:text>
            </xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    <!-- Recursion for chopping long text string into small chunks to fit in a form field -->
    <xsl:template name="span-string-to-hidden">
        <xsl:param name="string"/>
        <xsl:param name="index"/>
        <xsl:param name="splitlength"/>
        <xsl:choose>
            <xsl:when test="number(string-length($string)) > 0">
                <xsl:call-template name="create-span-hidden-field">
                    <xsl:with-param name="text" select="substring($string, $index, $splitlength)"/>
                    <xsl:with-param name="index" select="$index"/>
                    <xsl:with-param name="name-prefix">span-</xsl:with-param>
                    <xsl:with-param name="name">currentXML</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="span-string-to-hidden">
                    <xsl:with-param name="string"
                        select="substring($string, $splitlength, number(string-length($string)))"/>
                    <xsl:with-param name="index" select="$index + 1"/>
                    <xsl:with-param name="splitlength" select="$splitlength"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="create-span-hidden-field">
        <xsl:param name="text"/>
        <xsl:param name="index"/>
        <xsl:param name="name-prefix" />
        <xsl:param name="name"/>
        <xsl:param name="seperator">
            <xsl:text>_</xsl:text>
        </xsl:param>
        <fo:block-container>
            <rx:pdf-form-field hidden="true">
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($name-prefix, $name, $seperator, $index)"/>
                </xsl:attribute>
                <rx:pdf-form-field-text>
                    <xsl:attribute name="text">
                        <xsl:value-of select="$text"/>
                    </xsl:attribute>
                </rx:pdf-form-field-text>
            </rx:pdf-form-field>
        </fo:block-container>
    </xsl:template>
    <!-- Utility Templates -->
    <!-- Output lines for blank mode -->
    <xsl:template name="outputline">
        <xsl:param name="line" select="1"/>
        <xsl:param name="totallines" select="1"/>
        <xsl:if test="$line &lt; ($totallines + 1)">
            <fo:block>
                <fo:leader leader-pattern="rule"
                    leader-length=".9 * ({$default.page-width} - {$default.right-margin} - {$default.left-margin})"
                />
            </fo:block>
            <xsl:call-template name="outputline">
                <xsl:with-param name="line" select="$line + 1"/>
                <xsl:with-param name="totallines" select="$totallines"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!-- Set optional keeps on sections, categories -->
    <xsl:template name="evalbreak">
        <xsl:if test="@nobreak='true'">
            <xsl:attribute name="keep-together.within-page">always</xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- Catch all -->
    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>
</xsl:stylesheet>
