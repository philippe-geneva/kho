<%@ page contentType="text/html" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.sqlite.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%
  int id = Integer.parseInt(request.getParameter("id")); 

  String dbPath = "/WEB-INF/tpc.db";

  String tpid = null;
  String title = null;
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
      tpid = rs.getString("name");
      title = rs.getString("title"); 
      height = rs.getInt("height");
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
<html>
  <head>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <link rel="stylesheet" href="css/tpc-lightbox.css" type="text/css"></link>
  </head>
  <body>
    <script type="text/javascript" 
            src="https://public.tableau.com/javascripts/api/viz_v1.js">
    </script>
    <div class="tableauPlaceholder">
      <noscript>
        <a href="#">
          <img style="border: none" s
    	   rc="https://public.tableau.com/static/images/x/<%=tpid%>1_rss.png">
        </a>
      </noscript>
      <object class="tableauViz" 
              width="982" 
              style="display:none;" 
              height="<%=height%>">
        <param name="host_url" value="https://public.tableau.com/">
        <param name="site_root" value="">
        <param name="name" value="<%=tpid%>">
        <param name="tabs" value="no">
        <param name="toolbar" value="no">
        <param name="animate_transition" value="yes">
        <param name="display_static_image" value="no">
        <param name="display_spinner" value="no">
        <param name="display_overlay" value="no">
        <param name="display_count" value="no">
        <param name="showTabs" value="no">
      </object>
    </div>
  </body>
</html>
