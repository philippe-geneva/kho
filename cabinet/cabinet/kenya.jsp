<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="/common/page_prefix.jsp" %>

<%
  String themeName = "kenya";
%>

<!-- main banner -->

<%@ include file="/themes/kenya/banner.jsp" %>

<!-- spacer -->

<div class="uhc_spacer">&nbsp;</div>

<!-- DPT3 banners -->

<div style="width:100%;display:table;">

<%@ include file="/themes/kenya/teaser-wide.jsp" %>

</div>

<!-- spacer -->

<div class="uhc_spacer">&nbsp;</div>

<!-- County profiles -->

<%@ include file="/themes/kenya/county_profiles.jsp" %>

<!-- spacer -->

<div class="uhc_spacer">&nbsp;</div>

<!-- visualization cabinet -->

<jsp:include page="/cabinet-widget.jsp">
  <jsp:param name="id" value="21"/>
</jsp:include>

<!-- spacer -->

<div class="uhc_spacer">&nbsp;</div>

<!-- Load the extra cabinet drawers -->
<script type="text/javascript">
  _cabinet_url[100] = "themes/kenya/county_profiles.html";
</script>




<div style="display:table;height:100%;background-color:#ffc20e;width:100%;min-height:96px;color:black;text-align:center;vertical-align:middle;padding-top:10px;padding-bottom:10px;">
<br />
  <span>
    <a href="http://www.who.int/gho/en" 
       style="color:black;font-size:14px;"
       target="_blank">
      More data and analyses from the Global Health Observatory (GHO)
    </a>
  </span>
<br /><br />
<%@ include file="/common/page_suffix.jsp" %>
