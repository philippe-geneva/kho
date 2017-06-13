<%@page 
    contentType="text/html" 
    pageEncoding="UTF-8"
    import="java.net.*, 
            java.io.*" %><%

  String node = request.getParameter("node");
  if ((node == null) || node.equals("")) 
  { 
    node = "default";
  }
%>
<html>
  <head>
    <link rel="stylesheet" type="text/css" href="drawer.css">
    <script src="https://code.jquery.com/jquery-2.2.4.min.js"></script>
    <script type="text/javascript" src="drawer.json"></script>
  </head>
  <body>
    <script type="text/javascript">
      $(document).ready(function(){
        $('#b_map').click(function(){
          $('#b_map').addClass("selected");
          $('#b_viz').removeClass("selected");
          $('#b_data').removeClass("selected");
          $("#content").attr("src",drawer.<%=node%>.map);
        });
        $('#b_viz').click(function(){
          $('#b_viz').addClass("selected");
          $('#b_data').removeClass("selected");
          $('#b_map').removeClass("selected");
          $("#content").attr("src",drawer.<%=node%>.viz);
        });
/*
        $('#b_data').click(function(){
          $('#b_data').addClass("selected");
          $('#b_viz').removeClass("selected");
          $('#b_map').removeClass("selected");
          $("#content").attr("src",drawer.<%=node%>.data);
        });
*/
        // Hide buttons for which we dont have an available link
        
        if (drawer.<%=node%>.map == "") 
        {
          $('#b_map').hide();
        } 
        if (drawer.<%=node%>.viz == "") 
        {
          $('#b_viz').hide();
        } 
/*
        if (drawer.<%=node%>.data == "") 
        {
          $('#b_data').hide();
        } 
*/
        // Pick the first thing to show

        if (drawer.<%=node%>.map != "") 
        {
          $("#content").attr("src",drawer.<%=node%>.map);
          $("#b_map").addClass("selected");
        }
        else if (drawer.<%=node%>.viz != "") 
        {
          $("#content").attr("src",drawer.<%=node%>.viz);
          $("#b_viz").addClass("selected");
        }
/*
        else if (drawer.<%=node%>.data != "") 
        {
          $("#content").attr("src",drawer.<%=node%>.data);
          $("#b_data").addClass("selected");
        }
*/        
   
      });
    </script>
    <div>
      <div id="controls">
        <div class="button" id="b_map">Map</div>
        <div class="button" id="b_viz">Graph</div>
<!--
        <div class="button" id="b_data">Data</div>
-->
      </div>
      <div id="canvas">
        <iframe id="content">
        </iframe> 
      </div>
    </div>
  </body>
<html>
