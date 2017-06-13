<%
  String homeUrl = "../data";
  String extra = "";
  if ((region != null) && (!region.equals(""))) {
    if (!extra.equals("")) {
      extra += "&";
    } 
    extra += "region=" + region;
  }
  if ((theme != null) && (!theme.equals(""))) {
    if (!extra.equals("")) {
      extra += "&";
    } 
    extra += "theme=" + theme;
  } 
  if ((showonly != null) && (!showonly.equals(""))) {
    if (!extra.equals("")) {
      extra += "&";
    } 
    extra += "showonly=" + showonly;
  } 
  if (!extra.equals("")) {
    homeUrl += "?" + extra;
  }
%>
<div id="navigation">
  <h3>Navigation</h3>
  <ul>
    <li id="navigation_home">
      <a title="Home" href="<%=homeUrl%>"><span>Home</span></a>
    </li>
<%
  // If showNavigation is set to false, we will still show at least the "Home" icon
  // in order to allow the user to return to the welcome text of the application
 
  if (showNavigation) { %>
    <li id="navigation_themes">
      <a title="Themes" href="http://www.who.int/gho"><span>Themes</span></a>
    </li>
<% if (theme.equals("main")) { %>
    <li id="navigation_datasets" class="selected">
<% } else { %>
    <li id="navigation_datasets">
<% } %>
      <a title="Dataset" href="../data"><span>Data Repository</span></a>
    </li>
<% if (theme.equals("country")) { %>
    <li id="navigation_countries" class="selected">
<% } else { %>
    <li id="navigation_countries">
<% } %>
      <a title="Country" href="../data?theme=country"><span>Countries</span></a>
    </li>
<% if (theme.equals("metadata")) { %>
    <li id="navigation_metadata" class="selected">
<% } else { %>
    <li id="navigation_metadata">
<% } %>
      <a title="Metadata" href="../data?theme=metadata"><span>Metadata</span></a>
    </li>
<% } %>
  </ul>
</div> <!-- navigation -->
