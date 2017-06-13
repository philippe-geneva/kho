<%
    String theme = request.getParameter("theme");

    if ((theme == null) || (theme.equals(""))) {
      response.setStatus(response.SC_MOVED_PERMANENTLY);
      response.setHeader("Location","node.home");
    } else {
      pageContext.include("theme"); 
    }
%>

