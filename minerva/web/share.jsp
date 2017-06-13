<%  String publicURL = application.getInitParameter("publicURL");
    String theme = request.getParameter("theme");
    String vid = request.getParameter("vid");
    String title = request.getParameter("title");

    if (!((title != null) && (!title.equals("")))) {
      title = "Global Health Observatory";
    }

    String link = "";
    if ((theme != null) && (!theme.equals(""))) {
      link = link + "theme=" + theme;
    }
    if ((vid != null) && (!vid.equals(""))) {
      if (!link.equals("")) {
        link = link + "&";
      }
      link = link + "vid=" + vid;
    }
      
    if (!link.equals("")) {
      link = publicURL + "?" + link;
    } else {
      link = publicURL;
    }
%>
<html>
  <head>
    <title><%=link%></title>
  </head>
  <body>
    <div class="addthis_toolbox addthis_default_style"
         addthis:url="<%=link%>"
         addthis:title="<%=title%>"
         addthis:description="Global Health Observatory statistics">
      <a class="addthis_button_preferred_1"></a>
      <a class="addthis_button_preferred_2"></a>
      <a class="addthis_button_preferred_3"></a>
      <a class="addthis_button_preferred_4"></a>
      <a class="addthis_button_preferred_5"></a>
      <a class="addthis_button_preferred_6"></a>
      <a class="addthis_button_preferred_7"></a>
<!--
      <a class="addthis_button_compact"></a>
      <a class="addthis_counter addthis_bubble_style"></a>
-->
    </div>
    <script type="text/javascript" src="http://s7.addthis.com/js/250/addthis_widget.js#pubid=ra-4d89cf940b3beab1">
    </script>
  </body>
</html>
