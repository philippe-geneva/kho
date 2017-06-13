<%@ page contentType="text/html" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.sqlite.*" %>

<%
  String type = request.getParameter("type");
  String type_code = "tp";
  if (type != null) 
  {
    if (type.equals("tp")) 
    {
      type_code = "tp";
    } 
    else if (type.equals("ia"))
    {
      type_code = "ia";
    }
  }
  %>
  %
<html>
  <head>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <link href="css/tpc.css" rel="stylesheet" type="text/css"></link>
  </head>
  <body>
    In order to suppress the right column in a Webit page, paste the following into
    an HTMLSnipped element.  The element must be the first one on the page.
    <pre>
    &lt;script type="text/javascript" src="http://localhost:8080/tableau-public/js/muncher.js"&gt;&lt;/script&gt;
    </pre>

   See also: 
<% if (!type_code.equals("tp")) {%>
   <a href="./?type=tp">Tableau Public Visualizations</a>
<% } %>
<% if (!type_code.equals("ia")) {%>
   <a href="./?type=ia">Instant Atlas Maps</a>
<% } %>
   <br/>
   <br/>
    <table>
<% 
//  String baseURL = "http://hqsudevlin.who.int:8086/tableau-public/";
  String baseURL = "http://localhost:8080/tableau-public/";
  String baseURL_ia = "http://gamapserver.who.int/gho/interactive_charts";
  String dbPath = "/WEB-INF/tpc.db";

  String name = null;
  String title = null;
  int height = 675;
  int id = 0;
  Statement statement = null;
  ResultSet rs = null;

  Connection conn = null;

  try 
  {
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:"+getServletContext().getRealPath(dbPath)); 
    statement = conn.createStatement();
    statement.setQueryTimeout(10);
    rs = statement.executeQuery("select * from viz where type='" + type_code + "'");
    while (rs.next()) {
      id = rs.getInt("id");
      name = rs.getString("name");
      title = rs.getString("title"); 
      height = rs.getInt("height");

      if (type_code.equals("tp"))
      {
%> 
    <tr>
      <td rowspan="9">
	<a href="<%=baseURL%>tpc-frame.jsp?id=<%=id%>">
        <img style="max-width:200px" src="https://public.tableau.com/static/images/x/<%=name%>/1.jpg"></img>
	</a>
      </td>
      <td>
	<a href="<%=baseURL%>tpc-frame.jsp?id=<%=id%>">
	<h3><%=title%></h3>
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <span class="header">
        Embed visualization directly into a webit page (HTMLSnippet):
        </span>
      </td>
    </tr>
    <tr>
      <td>
        <span class="htmlcode">
&lt;div id="__tpc_<%=id%>"&gt;&lt;/div&gt;&lt;script type="text/javascript" src="<%=baseURL%>tpc.jsp?id=<%=id%>&amp;embed=true"&gt;&lt;/script&gt; 
        </span>
      </td>
    </tr>
    <tr>
      <td>
        <span class="header">
        Show complete visualization in a WHO branded page (HTMLSnippet):
        </span>
      </td>
    </tr>
    <tr>
      <td>
        <span class="htmlcode">
&lt;div id="__tpc_<%=id%>"&gt;&lt;/div&gt;&lt;script type="text/javascript" src="<%=baseURL%>tpc.jsp?id=<%=id%>&amp;embed=false"&gt;&lt;/script&gt; 
        </span>
      </td>
    </tr>
    <tr>
      <td>
        <span class="header">
        Direct link to visualization in a WHO branded page (External URL):
        </span>
      </td>
    </tr>
    <tr>
      <td>
        <span class="htmlcode">
<%=baseURL%>tpc-frame.jsp?id=<%=id%>
        </span>
      </td>
    </tr>
    <tr>
      <td>
        <span class="header">
        Direct link to visualization (External URL):
        </span>
      </td>
    </tr>
    <tr>
      <td>
        <span class="htmlcode">
<%=baseURL%>tpc-embedded.jsp?id=<%=id%>
        </span>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><b>Add the parameter <tt>&toolbar=no</tt> to the URL in order to suppress the UNDO/REDO/RESET options on the visualization footer</b></td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
<%
    }
    else if (type_code.equals("ia"))
    {
%>
    <tr>
      <td>
        <a href="<%=baseURL_ia%>/<%=name%>">
	  <h3><%=title%></h3>
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <span class="header">
        Embed map directly into a webit page (HTMLSnippet):
        </span>
      </td>
    </tr>
    <tr>
      <td>
        <span class="htmlcode">
&lt;div id="__tpc_<%=id%>"&gt;&lt;/div&gt;&lt;script type="text/javascript" src="<%=baseURL%>tpc.jsp?id=<%=id%>&amp;embed=true"&gt;&lt;/script&gt; 
        </span>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
<%
      }
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
    </table>
  </body>
</html>
