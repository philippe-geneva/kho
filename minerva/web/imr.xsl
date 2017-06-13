<?xml version="1.0" 
      encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:addthis="http://www.addthis.com/">

<xsl:output method="html" indent="yes" encoding="iso-8859-1"/>

<!--
  -->

<xsl:template match="/">
  <html>
    <head>
      <link rel="stylesheet" type="text/css" href="css/imr.css"></link>
    </head>
    <body>
      <xsl:apply-templates select="Indicators"/>
    </body>
  </html>
</xsl:template>

<xsl:template match="Indicators">
  <xsl:apply-templates select="Indicator"/>
</xsl:template>

<xsl:template match="Indicator">
  <div class="metadata">
    <xsl:for-each select="*[@name]" >
      <xsl:if test="name(.) != 'ShortName'">
      <xsl:if test="string-length(translate(.,' ','')) &gt; 1">
        <xsl:if test="not(@name = preceding-sibling::*/@name)">
          <div class="field">
            <xsl:value-of select="@name"/>
          </div>
        </xsl:if>
        <div class="value">
          <xsl:choose>
            <xsl:when test="@url">
              <a target="_blank">
                <xsl:attribute name="href">
                  <xsl:value-of select="@url"/>
                </xsl:attribute>
                <xsl:value-of select="."/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </div>
      </xsl:if>
      </xsl:if>
    </xsl:for-each>
  </div>
  <!--spacer-->
  <div style="width:100%;height:40px"></div>
</xsl:template>


</xsl:stylesheet>
