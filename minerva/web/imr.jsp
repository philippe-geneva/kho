<%@page 
    contentType="text/xml" 
    pageEncoding="UTF-8"
    import="java.net.*, 
            java.io.*" %><%

  String s_iid = request.getParameter("id");
  int iid = 1;
  if ((s_iid != null) && !s_iid.equals("")) 
  { 
    iid = Integer.parseInt(s_iid);
  }
  String proto = "http";
  String host = "apps.who.int";
  String port = "80";
  String path = "gho/indicatorregistryservice/publicapiservice.asmx/IndicatorGetAsXml";
//  String query = "profileCode=WHO&applicationCode=System&languageAlpha2=en&indicatorId=" + "65";
  String query = "profileCode=WHO&applicationCode=System&languageAlpha2=en&indicatorId=" + Integer.toString(iid);

  URL url = new URL(proto + "://" + host + ":" + port + "/" + path + "?" + query);

  URLConnection c = url.openConnection();
  BufferedReader in = new BufferedReader(new InputStreamReader(c.getInputStream()));
  StringBuffer xml_buf = new StringBuffer();
  String line = null;
  int count = 0;
  while ((line = in.readLine()) != null) 
  {
    if (count == 1) 
    {
      xml_buf.append("<?xml-stylesheet type=\"text/xsl\" href=\"imr.xsl\"?>\n");
    }
    xml_buf.append(line);
    xml_buf.append("\n");
    count++;
  }
  in.close();

  
%><%=xml_buf.toString()%>
