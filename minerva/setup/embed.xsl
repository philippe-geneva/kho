<?xml version="1.0"
      encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:addthis="http://www.addthis.com/">

<xsl:output method="html"
            indent="yes"
            encoding="UTF-8"/>

<xsl:variable name="lang" select="'en'"/>

<xsl:template name="renderNodeTab">
  <div class="tab">
    <xsl:attribute name="onclick">
      <xsl:text>location.href='</xsl:text>
      <xsl:text>node.</xsl:text>
      <xsl:value-of select="/Menu/@theme"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>'</xsl:text>
    </xsl:attribute>
    <span>
      <xsl:value-of select="Display[@lang = $lang]"/>
    </span>
  </div>
</xsl:template>

<!--
     Render menu nodes
-->

<xsl:template name="renderNodes">  
  <div class="wrapper">
  <div class="tabs">
    <xsl:choose>
      <xsl:when test="count(//Node[@selected = 1]) = 1">
        <xsl:for-each select="//Node[@selected = 1]/Node">
          <xsl:call-template name="renderNodeTab"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="/Menu/Node">
          <xsl:call-template name="renderNodeTab"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </div>
  </div>
</xsl:template>


<!--
  Render the structure for the content tabs
-->

<xsl:template name="renderContentTabs">
  <div class="tabs">
    <xsl:for-each select="//View">
      <xsl:choose>
        <xsl:when test="@selected = 1"> 
          <div class="tab selected">
            <span>
              <xsl:value-of select="Display[@lang = $lang]"/>
            </span>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <div class="tab">
            <xsl:attribute name="onclick">
              <xsl:text>location.href='</xsl:text>
              <xsl:text>view.</xsl:text>
              <xsl:value-of select="/Menu/@theme"/>
              <xsl:text>.</xsl:text>
              <xsl:value-of select="@id"/>
              <xsl:text>'</xsl:text>
            </xsl:attribute>
            <span>
              <xsl:value-of select="Display[@lang = $lang]"/>
            </span>
          </div>
        </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
  </div>
</xsl:template>

<!--
     Default content renderer, uses an iFrame.  This renderer is used to handle
     anything that is provided vi http or https.
-->

<xsl:template name="renderDefaultContent">
  <iframe id="content_iframe" 
          scrolling="no"
          width="100%" 
          frameborder="0" 
          onload="resizeMe(this)" 
          style="overflow:hidden">
    <xsl:attribute name="src">
      <xsl:value-of select="//View[@selected='1']/@URL"/>
    </xsl:attribute>
  </iframe>
</xsl:template>

<!--
     This template is used to render Tableau Public content.  It contains a 
     modified version of the official Tableau embedding script that allows
     us to place the content in a GHO frame instead.
-->

<xsl:template name="renderTableauPublicContent">
  <xsl:variable name="url_t"
               select="substring-after(//View[@selected='1']/@URL,'tableaupublic://')"/>
  <xsl:variable name="tableauParams"
                select="substring-after(concat($url_t,'?'),'?')"/>
  <xsl:variable name="tableauHeight"
                select="substring-before(concat(substring-after($tableauParams,'height='),'&amp;'),'&amp;')"/>
               
  <xsl:variable name="tableauCode"
                select="substring-before(concat($url_t,'?'),'?')"/>
  <script type='text/javascript'
          src='https://public.tableau.com/javascripts/api/viz_v1.js'>
  </script>
  <div class='tableauPlaceholder'> 
    <noscript>
      <a href='#'>
        <img 
             style='border: none'>
          <xsl:attribute name="src">
            <xsl:text>https://public.tableau.com/static/images/SD/</xsl:text>
            <xsl:value-of select="$tableauCode"/>
            <xsl:text>/1_rss.png</xsl:text> 
          </xsl:attribute>
        </img>
      </a>
    </noscript>
    <object class='tableauViz' 
            width='982' 
            style='display:none;'>
      <xsl:attribute name="height">
        <xsl:choose>
          <xsl:when test="$tableauHeight != ''">
            <xsl:value-of select="$tableauHeight"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>745</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <param name='host_url' 
             value='https://public.tableau.com/' /> 
      <param name='site_root' 
             value='' />
      <param name='name'>
        <xsl:attribute name="value"
                       select="$tableauCode"/>
      </param>
      <param name='tabs' 
             value='no' />
      <param name='toolbar' 
             value='no' />
      <param name='static_image'>
        <xsl:attribute name="value">
          <xsl:text>https://public.tableau.com/static/images/SD/</xsl:text>
          <xsl:value-of select="$tableauCode"/>
          <xsl:text>1.png</xsl:text>
        </xsl:attribute>
      </param>
      <param name='animate_transition' 
             value='yes' />
      <param name='display_static_image' 
             value='yes' />
      <param name='display_spinner' 
             value='yes' />
      <param name='display_overlay' 
             value='yes' />
      <param name='display_count' 
             value='no' />
      <param name='showTabs' 
             value='n' />
    </object>
  </div>
</xsl:template>



<!--
  Render the content for the selected View element.
-->


<xsl:template name="renderSelectedViewContent">
  <xsl:choose>
    <xsl:when test="//View[@selected='1']/@type = 'embedded'">
      <xsl:choose>
        <xsl:when test="starts-with(//View[@selected='1']/@URL,'tableaupublic://')">
          <xsl:call-template name="renderTableauPublicContent"/>
        </xsl:when>
        <xsl:when test="starts-with(//View[@selected='1']/@URL,'ghoclient://')">
          GHO client not yet supported
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="renderDefaultContent"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="//View[@selected='1']/@type = 'external'">
    </xsl:when>
    <xsl:otherwise>
      Only embedded views are supported
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--


-->

<xsl:template name="renderTitle">
  <div class="main_title">
    <xsl:choose>
      <xsl:when test="count(//Node[@selected = 1]) = 1">
        <xsl:value-of select="//Node[@selected = 1]/Display[@lang=$lang]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="/Menu/Display[@lang = $lang]"/>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<!--

-->

<xsl:template name="renderDescription">
  <div class="description">
    <xsl:value-of select="//View[@selected='1']/Description/Display[@lang=$lang]"/>
  </div>
</xsl:template>

<!--

-->

<xsl:template match="/">
<html>
  <head>
    <link rel="stylesheet" 
          type="text/css" 
          href="css/embed.css">
    </link>
    <script type="text/javascript">
    function resizeMe (i)
    {
      var h = 0;
      try {
        h = i.contentWindow.document.body.scrollHeight;
      } catch (err) {
        h = 800;
      }
      i.style.height = h + "px";
    }
    </script>
  </head>
  <body>
    <xsl:call-template name="renderTitle"/>
    <xsl:choose>
      <xsl:when test="count(//View) &gt; 0">
        <xsl:call-template name="renderDescription"/>
 <!--
      if there is only one view, we dont render the tab structure since it would be pointless
-->
        <xsl:if test="count(//View) &gt; 1">
          <xsl:call-template name="renderContentTabs"/>
        </xsl:if>
        <xsl:call-template name="renderSelectedViewContent"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="renderNodes"/>
      </xsl:otherwise>
    </xsl:choose>
  </body>
</html>
</xsl:template>

</xsl:stylesheet>

