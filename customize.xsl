<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <!-- General variables, should not change -->
    <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <!-- Page dimensions -->
    <xsl:variable name="default.page-height">11in</xsl:variable>
    <xsl:variable name="default.page-width">8.5in</xsl:variable>
    <xsl:variable name="default.top-margin">1in</xsl:variable>
    <xsl:variable name="default.bottom-margin">1in</xsl:variable>
    <xsl:variable name="default.left-margin">0.75in</xsl:variable>
    <xsl:variable name="default.right-margin">0.75in</xsl:variable>
    <!-- Document font information -->
    <!-- Note: You must keep this variable and the arrtibute-set default font size in sync, the variable is required for some calculations for field size -->
    <xsl:variable name="default.font-size">11pt</xsl:variable>
    <xsl:attribute-set name="default">
        <xsl:attribute name="font-size">11pt</xsl:attribute>
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="hyphenate">false</xsl:attribute>
        <xsl:attribute name="margin-top">3pt</xsl:attribute>
        <xsl:attribute name="margin-bottom">3pt</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="basic-link">
        <xsl:attribute name="color">blue</xsl:attribute>
        <xsl:attribute name="text-decoration">underline</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="header">
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="footer">
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="font-size">9pt</xsl:attribute>
        <xsl:attribute name="font-style">italic</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
    </xsl:attribute-set>
    <!-- Document layout information -->
    <xsl:variable name="default.header-start">0.5in</xsl:variable>
    <xsl:variable name="default.footer-start">6pt</xsl:variable>
    <xsl:variable name="default.space-between-item">6pt</xsl:variable>
    <!-- Section, Category formatting information -->
    <xsl:attribute-set name="document_title">
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="font-size">16pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="text-decoration">none</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
        <xsl:attribute name="padding-top">0pt</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="section_title">
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="font-size">14pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="text-decoration">underline</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
        <xsl:attribute name="padding-top">12pt</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="category_title">
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-style">italic</xsl:attribute>
        <xsl:attribute name="text-decoration">none</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
        <xsl:attribute name="padding-top">6pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">6pt</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="group_title">
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="font-size">11pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="text-decoration">none</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
        <xsl:attribute name="padding-top">0pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">3pt</xsl:attribute>
    </xsl:attribute-set>
    <!-- Form checklist description -->
    <xsl:attribute-set name="description">
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="font-size">11pt</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
    </xsl:attribute-set>
    <!-- Form element defaults -->
    <xsl:attribute-set name="standard_text">
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="font-size">11pt</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="checkbox_appearance">
        <xsl:attribute name="border-width">1pt</xsl:attribute>
        <xsl:attribute name="border-style">solid</xsl:attribute>
        <xsl:attribute name="border-color">silver</xsl:attribute>
        <xsl:attribute name="background-color">lavender</xsl:attribute>
        <xsl:attribute name="font-family">ZapfDingbats</xsl:attribute>
        <xsl:attribute name="color">maroon</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="checklist_appearance">
        <xsl:attribute name="border-width">1pt</xsl:attribute>
        <xsl:attribute name="border-style">solid</xsl:attribute>
        <xsl:attribute name="border-color">silver</xsl:attribute>
        <xsl:attribute name="background-color">white</xsl:attribute>
        <xsl:attribute name="font-family">ZapfDingbats</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="textbox_appearance">
        <xsl:attribute name="border-width">1pt</xsl:attribute>
        <xsl:attribute name="border-style">solid</xsl:attribute>
        <xsl:attribute name="border-color">silver</xsl:attribute>
        <xsl:attribute name="background-color">lavender</xsl:attribute>
        <xsl:attribute name="color">maroon</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="teacher_textbox_appearance">
        <xsl:attribute name="border-width">1pt</xsl:attribute>
        <xsl:attribute name="border-style">solid</xsl:attribute>
        <xsl:attribute name="border-color">silver</xsl:attribute>
        <xsl:attribute name="background-color">lightyellow</xsl:attribute>
        <xsl:attribute name="color">red</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="combobox_appearance">
        <xsl:attribute name="border-width">1pt</xsl:attribute>
        <xsl:attribute name="border-style">solid</xsl:attribute>
        <xsl:attribute name="border-color">silver</xsl:attribute>
        <xsl:attribute name="background-color">lavender</xsl:attribute>
        <xsl:attribute name="color">maroon</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="button_appearance">
        <xsl:attribute name="background-color">cornflowerblue</xsl:attribute>
        <xsl:attribute name="border-color">blue</xsl:attribute>
        <xsl:attribute name="border-style">outset</xsl:attribute>
        <xsl:attribute name="border-width">0.5pt</xsl:attribute>
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="color">lightyellow</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="optiontext_appearance">
        <xsl:attribute name="color">maroon</xsl:attribute>
        <xsl:attribute name="padding-left">3pt</xsl:attribute>
    </xsl:attribute-set>
    <xsl:variable name="default.cb-select">✓</xsl:variable>
    <xsl:variable name="default.cb-noselect">&#x274f;</xsl:variable>
    <xsl:variable name="default.ob-select">✓</xsl:variable>
    <xsl:variable name="default.ob-incorrect">✖</xsl:variable>
    <xsl:variable name="default.ob-noselect">&#x274f;</xsl:variable>
    <xsl:variable name="default.og-arrangement">vertical</xsl:variable>
    <xsl:variable name="default.button_position">inline</xsl:variable>
    <xsl:variable name="default.button_align">center</xsl:variable>
    <xsl:variable name="default.button_width">1in</xsl:variable>
    <xsl:variable name="default.button_height">18pt</xsl:variable>
    <xsl:variable name="default.button_submit-format">XFDF</xsl:variable>
</xsl:stylesheet>
