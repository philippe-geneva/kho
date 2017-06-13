<% String vid = request.getParameter("vid"); %>
<% String region = request.getParameter("region"); %> 
<% String node = request.getParameter("node"); %>
<% String showonly = request.getParameter("showonly"); %>
<%@include file="common/themes.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <%@include file="common/whohead.jsp"%>
    <!-- minerva specific style and WHO site overides -->
    <link rel="stylesheet" type="text/css" href="./css/minerva.css"/>
    <title>WHO | <%=titleName%></title>
  </head>
  <body class="fluid">
    <script type="text/javascript">
      // Convert some of the variable available through JSP to Javascript variables
      var theme="<%=theme%>";
      var publicURL="<%=publicURL%>";
    </script>
    <div id="page" class="template_sidebar">
      <!-- begin: wrapper -->
      <div id="wrapper">
      <%@include file="common/header.jsp"%>
        <!-- begin: main -->
        <div id="main">
<%if (theme == "downloads") { %>
          <%@include file="common/navigation-downloads.jsp"%>
<% } else { %>
          <%@include file="common/navigation.jsp"%>
<% } %>
              <div id="menuControl">
              </div> <!-- menuControl -->
          <div id="sidebar">
            <div id="subnavigation">
                <h3>Subnavigation</h3>
            </div>
          </div> <!--sidebar-->

          <!-- begin: content -->
          <div id="content">
              <div id="zone_1">
              </div> <!-- zone_1 -->
              <div id="zone_2">
              </div> <!-- zone_2 -->
              <div id="zone_3">
              </div> <!-- zone_3 -->
              <div id="zone_4">
              </div> <!-- zone_4 -->
            <!--
              These iframes are used to retrieve the content from the server 
              in order to pass them on to the divs that are rendered on the
              browser
              -->
<!--
            <iframe id="menu_iframe"
                    frameborder="0"
                    height="0"
                    width="0"
                    src="<%=fileMenu%>"
<% if (vid != null) { %>
                    onload="divUpdate('subnavigation',this); showViewByVid('<%=vid%>')">
<% } else { %>
                    onload="divUpdate('subnavigation',this)">
<% } %>
            </iframe>
-->
            <iframe id="content_iframe"
                    frameborder="0"
                    width="750px"
                    height="390px"
                    src="<%=fileMotd%>"
            >
            </iframe>
            <div> 
              Please click the <b>Continue</b> button to proceed to your data.<br /><br />
              <form class="form" action="minerva.jsp" method="GET">            
              <fieldset class="buttonbar">
                <ul>
                  <li>
                    <input class="submit primary" type="submit" title="Primary Button" value="Continue" />
                    <input type="hidden" name="theme" value="<%=theme%>"/>    
                    <input type="hidden" name="vid" value="<%=vid%>"/>    
                  </li>
                </ul>
              </fieldset>
              </form>
            </div>
          </div> <!-- content -->
          <!--[if !IE]>-->
            <div class="clear"><!-- all clear --></div>
          <!--<![endif]-->
          <!--[if gt IE 7]>
            <div class="clear"><!-- all clear --></div>
          <![endif]-->
        </div> <!--end: main -->
        <%@include file="common/footer.jsp"%>
      </div><!-- end: wrapper -->
    </div> <!-- end: page -->
  </body>
</html>
