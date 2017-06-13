<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>

<%@ page import="javax.servlet.*"%>
<%@ page import="javax.servlet.http.*"%>
<%@ page import="javax.naming.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="java.sql.*"%>
<html>
  <head>
    <title>
      GHO/Trac tickets interface
    </title>
    <link href="./sysmedia/media/style/who.css" rel="stylesheet" type="text/css"/>
  </head>
  <body style="background-color:#FFFFFF;">
<%
  String vid = request.getParameter("vid");
  String theme = request.getParameter("theme");

  String tracPfx = application.getInitParameter("tracURL");
  String publicURL= application.getInitParameter("publicURL");

  /*
   * Setup the HTTP authentication token to access Trac's web services.  
   */

  String username = application.getInitParameter("tracUsername");
  String password = application.getInitParameter("tracPassword");
  String userpass = username + ":" + password;
  String encoding=new sun.misc.BASE64Encoder().encode(userpass.getBytes());
  
  String jsonResponse = null;

  if ((vid != null) && (!vid.equals("")) && (theme != null) && (!theme.equals(""))) { 
  
    /*
     * Set up the JSON query string that will be POSTed to the web service.  The content of the
     * first element in the "params" array is the actual query.  For this particular case, it
     * uses custom fields that have been defined in the GHODATA Trac ticket system, vid and 
     * theme.
     */

      String postStr = "{\"params\": [\"vid=" + vid + "&theme=" + theme + "&status!=closed\"], \"method\":\"ticket.query\",\"id\":999}";

    /*
     *  Create the POST request, and write the query string to the request's output stream.
     */

    URL url = new URL(tracPfx + "/login/rpc");
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("POST");
    conn.setDoOutput(true);
    conn.setRequestProperty("Content-Type","application/json");
    conn.setRequestProperty("Authorization","Basic " + encoding);
    PrintWriter pw = new PrintWriter(conn.getOutputStream());
    pw.println(postStr);
    pw.close();

    /* 
     * Read the response from Trac through the request's input stream.  Note that the 
     * response is in JSON format
     */

    BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    jsonResponse = in.readLine();
    in.close();
  } else {

  /*
   * If no VID or theme were specified, we simply spit out an error message.
   */

    jsonResponse = "{\"id\":999, \"result\":[],\"error\":\"No VID or theme specified\"}";
  }
%>
  <div id="tracTicketList"></div>
  <script type="text/javascript">
    var tickets = <%=jsonResponse%>;
    var s = "<b>Current tickets:</b> ";
    if (tickets.error == null) {
      var newTicketUrl = "<%=tracPfx%>/newticket?vid=<%=vid%>&theme=<%=theme%>&component=DataView&type=issue&description=<%=publicURL%>%3Fvid=<%=vid%>%26theme=<%=theme%>";
      var viewAllTicketsUrl = "<%=tracPfx%>/query?status=!closed&theme=!&vid=!&order=priority&component=DataView";
      if (tickets.result.length < 1) {
        s += "none";
      } else {
        for (n = 0; n < tickets.result.length; n++) {
          if (n > 0) {
            s += " <b>|</b> ";
          }
          s += "<a target=\"_blank\" href=\"<%=tracPfx%>/ticket/" + tickets.result[n] + "\">#" + tickets.result[n] + "</a>"
        } 
      }
      s += " <b>|</b> <a target=\"_blank\" href=\"" + newTicketUrl + "\">New ticket</a>"
      s += " <b>|</b> <a target=\"_blank\" href=\"" + viewAllTicketsUrl + "\">View <b>All</b> VID tickets</a>";
 //     s += "<br /><br />When creating a <a target=\"_blank\" href=\"" + newTicketUrl + "\">new ticket</a> you only need to fill in the <b>Summary</b>, the <b>Description</b>, and if you are not logged into the ticket tracking system, your <b>email address</b> or <b>username</b>. ";
    } else {
      s += tickets.error;
    }
    document.getElementById("tracTicketList").innerHTML = s;
  </script>
  </body>
</html>
