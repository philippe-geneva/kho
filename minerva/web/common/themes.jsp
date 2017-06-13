<%  String publicURL = application.getInitParameter("publicURL");
    String wikiURL = application.getInitParameter("wikiURL");
    String tracURL = application.getInitParameter("tracURL");
    String theme = request.getParameter("theme");
    String maintenanceMode = application.getInitParameter("maintenanceMode"); 
    String fileMenu = "themes/main/menu.html";
    String fileViews = "themes/main/menu.js";
    String clientName = "Global Health Observatory Data Repository";
    String titleName = "Global Health Observatory Data Repository";
    String fileMotd = "motd.html";
    boolean maintenance = false;
    boolean showNavigation = true;
    boolean showSearch = true;
    if ((maintenanceMode != null) && (maintenanceMode.equals("1"))) {
      maintenance = true;
    }
    
    if (theme == null) {
      theme = "main";
    }
    if (theme.equals("country")) {
      fileMenu = "themes/country/menu.html";
      fileViews = "themes/country/menu.js";
    } else if (theme.equals("metadata")) {
      fileMenu = "themes/metadata/menu.html";
      fileViews = "themes/metadata/menu.js";
    } else if (theme.equals("fluid")) {
      clientName = "FluMart Browser";
      titleName = "FluMart Browser";
      fileMenu = "themes/fluid/menu.html";
      fileViews = "themes/fluid/menu.js";
      fileMotd="motd-fluid.html";
    } else if (theme.equals("demo")) {
      fileMenu = "themes/demo/menu.html";
      fileViews = "themes/demo/menu.js";
      clientName += " Demonstrations";
      titleName += " Demonstrations";
    } else if (theme.equals("wrapper")) {
      fileMenu = "themes/wrapper/menu.html";
      fileViews = "themes/wrapper/menu.js";
      clientName = "Global Health Observatory Data Visualization";
      titleName = "Global Health Observatory Data Visualization";
    } else if (theme.equals("who-reform")) {
      fileMenu = "themes/who-reform/menu.html";
      fileViews = "themes/who-reform/menu.js";
      clientName = "WHO Reform Implementation Plan";
      titleName = "WHO Reform Implementation Plan";
      fileMotd = "who-reform.html";
      showNavigation = false;
      showSearch = false;
    } else { 
      fileMenu = "themes/main/menu.html";
      fileViews = "themes/main/menu.js";
    } 

    String regionCode = null;
    if (region != null) {
      if (region.equals("searo")) {
        regionCode = "SEAR";
        titleName += " - WHO South-East Asia Region";
        clientName = titleName;
      } else if (region.equals("afro")) {
        regionCode = "AFR";
        titleName += " - WHO African Region";
        clientName = titleName;
      } else if (region.equals("wpro")) {
        regionCode = "WPR";
        titleName += " - WHO Western Pacific Region";
        clientName = titleName;
      } else if (region.equals("euro")) {
        regionCode = "EUR";
        titleName += " - WHO European Region";
        clientName = titleName;
      } else if (region.equals("amro")) {
        regionCode = "AMR";
        titleName += " - WHO Region of the Americas";
        clientName = titleName;
      } else if (region.equals("emro")) {
        regionCode = "EMR";
        titleName += " - WHO Eastern Mediterranean Region";
        clientName = titleName;
      } else if (region.equals("eu")) {
        regionCode = "EU";
        titleName += " - European Union";
        clientName = titleName;
      } else {
        region = null;
      }
    }

%>
