<%@ page contentType="text/javascript" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.sqlite.*" %>
<% 
  Boolean embed = Boolean.parseBoolean(request.getParameter("embed"));
  String container = request.getParameter("container");
  String toolbar = request.getParameter("toolbar");
  int id = Integer.parseInt(request.getParameter("id")); 

  String toolbar_param = null;
  if ((toolbar != null) && (!toolbar.equals(""))) 
  {
    toolbar_param = "&toolbar=" + toolbar;
  } 
  else 
  {
    toolbar_param = "";
  }    

  String dbPath = "/WEB-INF/tpc.db";

  String name = null;
  String title = null;
  String type = null;
  int height = 675;
  Statement statement = null;
  ResultSet rs = null;

  Connection conn = null;

  try 
  {
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:"+getServletContext().getRealPath(dbPath)); 
    statement = conn.createStatement();
    statement.setQueryTimeout(10);
    rs = statement.executeQuery("select * from viz where id=" + id);
    if (rs.next()) {
      name = rs.getString("name");
      title = rs.getString("title"); 
      height = rs.getInt("height");
      type = rs.getString("type");
    } 
  } 
  catch (Exception e) 
  {
    System.err.println(e.getMessage());
  }
  finally 
  {
    try
    {
      if (rs != null) {
        rs.close();
      }
      if (statement != null) {
	statement.close();
      }
      if (conn != null) {
        conn.close();
      }
    }
    catch (Exception e) 
    {
      System.err.println(e.getMessage());
    }
  }
%>

$(document).ready(function() {
  var title = encodeURIComponent("<%=title%>");
	
<% 
  if (embed) { 
%>

    var iframe = document.createElement('iframe');
    iframe.id = "__tpcf_<%=id%>";
    $(iframe).css('width','100%');
    $(iframe).css('height','<%=height%>px');
    $(iframe).css('overflow','hidden');
    iframe.scrolling = "no";

<% if (type.equals("ia")) { %>
    var div = document.createElement('div');
    $(div).css('width','95%');
    $(div).css('padding','10px');
    $(div).text("<%=title%>");
    $(div).css('color','white');
    $(div).css('text-align','center');
    $(div).css('background-color','rgb(0, 141, 201)');
    $(div).css('font-family','"Trebuchet MS", Helvetica, sans-serif');
    $(div).css('font-size','18px');
    $(div).css('margin','10px');
    iframe.src = "http://gamapserver.who.int/gho/interactive_charts/<%=name%>";
<% } else if (type.equals("tp")) { %>
    iframe.src = "http://localhost:8080/tableau-public/tpc-embedded.jsp" +
                 "?id=<%=id%><%=toolbar_param%>";
<% } %>
    $('#__tpc_<%=id%>').empty();
<% if (type.equals("ia")) { %>
    $('#__tpc_<%=id%>').append(div);
<% } %>
    $('#__tpc_<%=id%>').append(iframe);
<%
  } else if (type.equals("tp")) {
%>

    var imgl = "https://public.tableau.com/static/images/x/<%=name%>/1.gif";
    var tl = "http://localhost:8080/tableau-public/tpc-embedded.jsp?id=<%=id%><%=toolbar_param%>"; 

    var css = document.createElement("link");
    css.rel = "stylesheet";
    css.href = "http://localhost:8080/tableau-public/css/embed.css";
    css.type = "text/css";

    $('head').append(css);

    $('#__tpc_<%=id%>').empty();

    // Load the thumbnail for the tableau visualization

    $('#__tpc_<%=id%>').append('<div class="lightbox">' +
	                       '<a class="lightbox_media" rel="shadowbox" href="' + 
			       tl + 
			       '">' +
			       '<span style="float:right">Enlarge the dashboard</span><br>' + 
			       '</a>' +
	                       '<a class="lightbox_media" rel="shadowbox" href="' +
			       tl +
			       '">' +
			       '<img src="' +
			       imgl +
			       '" style="' +
                                        'display:block;' + 
  	                                'max-width:100%;' + 
  	                                'max-height:100%;' + 
                                        'margin-left:auto;' + 
  	                                'margin-right:auto;' +
			       '">' +
			       '</a>' + 
                               '</div>');
<%
  }
%>
});
