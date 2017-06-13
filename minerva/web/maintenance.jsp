<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <%@include file="common/whohead.jsp"%>
    <!-- minerva specific style and WHO site overides -->
    <link rel="stylesheet" type="text/css" href="./css/minerva.css"/>
    <title>WHO | <%=titleName%></title>
  </head>
  <body class="fluid">
    <div id="page" class="template_sidebar">
      <!-- begin: wrapper -->
      <div id="wrapper">
      <%@include file="common/header.jsp"%>
        <!-- begin: main -->
        <div id="main">
          <%@include file="common/navigation.jsp"%>
          <div id="menuControl">
          </div> <!-- menuControl -->
          <div id="sidebar">
            <div id="subnavigation">
                <h3>Subnavigation</h3>
            </div>
          </div> <!--sidebar-->

          <!-- begin: content -->
          <div id="content">
            <h1>System unavailable</h1>
            The Observatory is undergoing maintenance operations and is currently unavailable at this time. Please check again later. 
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
