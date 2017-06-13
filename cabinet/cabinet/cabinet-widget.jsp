<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.sqlite.*" %>

<%
  int cabinetID = 0;
  String t = request.getParameter("id");
  if ((t != null) && !t.equals("")) {
    cabinetID = Integer.parseInt(t);
  } else {
    cabinetID = 1;;
  }


  Connection conn = null;
  Statement getCabinet =  null;
  Statement getSections =  null;
  Statement getSubSections =  null;
  Statement getSubSectionCount =  null;
  Statement getRelatedLinks = null;
  ResultSet cabinet = null;
  ResultSet section = null;
  String dbPath="WEB-INF/db.db";
  String sectionTitle = null;
  String subSectionTitle = null;
  String subSectionSidenoteTitle = null;
  String subSectionSidenote = null;
  String sectionID = null;
  String subSectionColour = null;
  String subSectionID = null;
  String sectionColor = null;
  String sectionIcon = null;
  String height = null;
  String URL = null;
  int subSectionCounter = 0;
  ArrayList<String> panelURL = new ArrayList<String>();

  try 
  {
    //
    // Setup the connection to the database and prepare statement objects
    //
    
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:"+getServletContext().getRealPath(dbPath)); 
    getCabinet = conn.createStatement();
    getSections = conn.createStatement();
    getSubSections = conn.createStatement();
    getSubSectionCount = conn.createStatement();
    getRelatedLinks = conn.createStatement();
    getCabinet.setQueryTimeout(10);
    getSections.setQueryTimeout(10);
    getSubSections.setQueryTimeout(10);
    getSubSectionCount.setQueryTimeout(10);
    getRelatedLinks.setQueryTimeout(10);
    

    //
    // Pull out the specific cabinet and display its title on the web page
    //

    cabinet = getCabinet.executeQuery(
      "Select * from Cabinet " + 
      "where ID=" + Integer.toString(cabinetID)
    );
    cabinet.next();

    // The containing div for the whole widget is so that we can control if
    // its rendering goes all the way to the edge of the html BODY element or
    // if we want to frame it to something a bit smaller.
    
    String cabinetTitle = cabinet.getString("TitleEN");
    if ((cabinetTitle != null) && !cabinetTitle.equals("") && !cabinetTitle.equals("null")) {
%>

    <div class="cabinet"
	 style="background-color:<%=cabinet.getString("color")%>">
        <%=cabinetTitle.toUpperCase()%>
    </div>

<% 
    }
%>

    <div style="padding:0px;">
<%

    // 
    // Now extract the sections in the cabinet and display each one on
    // the web page.  Each section will have it's subsections displayed
    // immediately below it in a single row.
    //

    section = getSections.executeQuery(
      "select * from CabinetSection " + 
      "where CabinetID=" + Integer.toString(cabinetID) + " " +
      "and Status = \"published\""
    );
    while (section.next()) {
      sectionID = section.getString("ID");
      sectionTitle = section.getString("TitleEN");
      sectionColor = section.getString("color");
      sectionIcon = section.getString("icon");
      boolean useThinSubSections = false;
%>

     <div class="section" >
<%
      if ((sectionTitle != null) && (!sectionTitle.equals(""))) {
        useThinSubSections = false;
%>
      <div class="sectionheading"
	   style="color:<%=sectionColor%>;">
<%    if ((sectionIcon != null) && !sectionIcon.equals("")) { %>
          <img src="<%=sectionIcon%>"></img><br/>
<%    } %>
          <%=sectionTitle.toUpperCase()%>
      </div>
      <% } else { %>
      <div class="sectionheading thin">
	      <!--
	<h2 style="color:<%=sectionColor%>;">
          <%=sectionTitle.toUpperCase()%>
	</h2>
	      -->
      </div>
<%
      }

      //
      //  First get a count of the number of subsections so that we
      //  can calculate the required width for each sub section heading
      //  (they are equally size along a single row).
      //
      
      ResultSet subSectionCount = getSubSectionCount.executeQuery(
        "select count(*) as rowcount " +
	"from CabinetSubSection " + 
	"where CabinetSectionID=\"" + sectionID + "\" " + 
        "and CabinetID=" + Integer.toString(cabinetID)
      );
      subSectionCount.next();
      int subsections = subSectionCount.getInt("rowcount");
      subSectionCount.close();

      //
      // Now build the display panel for each subsection.  These are
      // appended in a string and display after we've output the 
      // subsection panels to the web page - this way we only need
      // to loop through the results from the DB once.
      //

      ResultSet subSection = getSubSections.executeQuery(
        "select * " +
	"from CabinetSubSection " + 
	"where CabinetSectionID=\"" + sectionID + "\" " +
        "and CabinetID=" + Integer.toString(cabinetID)
      );
      String subSectionPanelHtml = "";
      int sscount = 0;
      while (subSection.next()) {
        subSectionCounter++;
        subSectionTitle = subSection.getString("TitleEN");
        subSectionID = subSection.getString("ID");
        subSectionColour = subSection.getString("colour");
        if ((subSectionColour != null) && 
            (subSectionColour.trim().equals("")))
        {
          subSectionColour = null;
        }
        subSectionSidenoteTitle = subSection.getString("SidenoteTitleEN");
        subSectionSidenote = subSection.getString("SidenoteEN");
	height = subSection.getString("height");
	if ((height == null) || height.equals("") || height.equals("null") ) {
	  height = "150";
	}
	URL = subSection.getString("URL");
	panelURL.add(URL);
	subSectionPanelHtml += "<div class=\"cabPanel\" " + 
	                       "id=\"panel_" + Integer.toString(subSectionCounter) + "\" " +
			       "style=\"height:100%;\" " +
			       ">";
	for (int x = 0; x < subsections; x++) {
	  subSectionPanelHtml += "<div class=\"pointer" + 
		                 ((x == sscount)?" selected":"") + "\" "+
		                 "style=\"width:" + Double.toString(100.0/(double)subsections) + "%;" + 
				 ((x == sscount)?"opacity:0.75;background-color:"+((subSectionColour == null) ? sectionColor : subSectionColour) +";":"") +
				 "\">"+
				 "</div>";
        }
	String caption = subSection.getString("CaptionEN");
	if ((caption != null) && !caption.equals("") && !caption.equals("null")) {
	  subSectionPanelHtml += "<div class=\"caption\">" + caption + "</div>";
	}

        // Retrieve any potential extras like the related links and the side text.  If
        // we have any of these we will produce a shortened version of the cabinet
        // panel and position the coponents on the right of the embeded content

        ResultSet relatedLinks = getRelatedLinks.executeQuery(
          "select * " + 
          "from cabinetRelatedLinks " +
          "where CabinetSubSectionID = " +  subSectionID
        );

        boolean shortPanel = false;
        if (relatedLinks.isBeforeFirst() ||
            ((subSectionSidenoteTitle != null) && !subSectionSidenoteTitle.equals("")) ||
            ((subSectionSidenote != null) && !subSectionSidenote.equals("")))
        {
          shortPanel = true;
        }

        subSectionPanelHtml += "<iframe scrolling=\"no\" class=\"ifm_panel" +
                               (shortPanel ? " short" : "") +
                               "\" src=\"\"" +
			       " id=\"ifm_panel_" + Integer.toString(subSectionCounter) + "\"" +
			       ((height == null) ? "" : " style=\"height:" + height + "px;\"") +
			       ">" +
			       "</iframe>";
// If we have any related links, retrieve them from the database and add them to a
// div.
 
        if (shortPanel)
        {
          subSectionPanelHtml += "<div class=\"uhc_links" + 
                                  (shortPanel ? " short" : "") + 
                                  "\">";
          if ((subSectionSidenoteTitle != null) && !subSectionSidenoteTitle.equals(""))
          {
            subSectionPanelHtml += "<span class=\"sidenote title\">" + subSectionSidenoteTitle + "</span><br/><br/>";
          }
          if ((subSectionSidenote != null) && !subSectionSidenote.equals(""))
          {
            subSectionPanelHtml += "<span class=\"sidenote\">" + subSectionSidenote + "</span><br/><br/><hr/>";
          }
          if (relatedLinks.isBeforeFirst()) 
          {
            subSectionPanelHtml += "<span class=\"sidenote title\">Related links</span><br/><br/><ul>";
            while (relatedLinks.next()) 
            {
              subSectionPanelHtml += "<li><a href=\"" + 
                                     relatedLinks.getString("URL") +
                                     "\" target=\"_blank\">" +
                                     relatedLinks.getString("TitleEN") + 
                                     "</a></li>";
            }
            subSectionPanelHtml += "</ul></div>";
          }
        }
        relatedLinks.close();
        subSectionPanelHtml += "</div>";
	sscount++;
%>
      <div class="subsectionwrapper"
  	   style="width:<%=100.0/(float)subsections%>%;">
<%      if (useThinSubSections) {%>
          <div class="subsection thin"
<%      } else { %>
          <div class="subsection"
<%      } %> id="cabinet_<%=subSectionCounter%>"
	     onclick="togglePanel('<%=subSectionCounter%>')"
  	     style="opacity:1.0;background-color:<%=((subSectionColour == null) ? sectionColor : subSectionColour)%>">
	     <%=subSectionTitle%><br/>
	     <span class="goblin">&gt;</span>
        </div>
      </div>
<%
      }
      subSection.close();
%>
    </div>
    <%=subSectionPanelHtml%>
<%
    }
%>
  <script type="text/javascript">
    var _cabinet_url = new Array();
<%
    for (int x = 0; x < panelURL.size(); x++) {
      if (!panelURL.get(x).equals("null")) {
%>
	_cabinet_url[<%=x+1%>] = "<%=panelURL.get(x)%>";
<%
       } else {
%>
	_cabinet_url[<%=x+1%>] = null;
<%
      }
    }
%>
  </script>
  </div>
<%
  }
  catch (Exception e)
  {
    System.err.println(e.getMessage());
  }
  finally 
  {
    try
    {
      if (getCabinet != null) {
        getCabinet.close();
      }
      if (getSections != null) {
        getSections.close();
      }
      if (getSubSections != null) {
        getSubSections.close();
      }
      if (getSubSectionCount != null) {
        getSubSectionCount.close();
      }
      if (getRelatedLinks != null) {
        getRelatedLinks.close();
      }
      if (section != null) {
        section.close();
      }
      if (cabinet != null) {
        cabinet.close();
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

