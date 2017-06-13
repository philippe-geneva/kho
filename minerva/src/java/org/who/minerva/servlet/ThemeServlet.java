/*
 * (c) 2013, World Health Organization
 *
 * $Id$
 * $HeadURL$
 */

package org.who.minerva.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.HashSet;
import java.util.Enumeration;
import org.apache.log4j.Logger;
import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.PropertyConfigurator;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import net.sf.saxon.s9api.*;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.ErrorListener;
import javax.xml.transform.TransformerException;


import org.who.minerva.Menu;
import org.who.minerva.View;
import org.who.minerva.servlet.Cache;
import org.who.minerva.servlet.CLFLog;


public class ThemeServlet extends HttpServlet {

  private static Logger logger = Logger.getLogger(ThemeServlet.class);

  /*
   * Force the output stream to be in UTF-8
   */

  private static String _DEFAULT_CHARSET = "UTF-8";

  /*
   * Servlet init-param name for the configuration file, and the default value of the 
   * configuration file if it is not specied in web.xml.  Regardless of its name, the 
   * configuration file must reside in the webapp's WEB-INF directory.
   */

  private static String _INIT_PARAM_CONFIG_FILE = "configFile";
  private static String _INIT_PARAM_CACHE_DIR = "cacheDir";
  private static String _INIT_PARAM_LOG4JCONF = "log4jconfig";
  private static String _INIT_PARAM_LOG_FILE_NAME = "logFileName";

  private String myConfigFile = "themes.xml";
  private String myCacheDir = "cache";

  private CLFLog clfLog = null;

  /*
   * The servlet's response cache (stores the results of XSLT transforms in order to
   * improve the performance)
   */

  private Cache myCache = null;

  Processor xsltProcessor = null;
  XsltCompiler xsltCompiler = null;

  /*
   * Structures to hold the theme names, locations, and menu structures.
   */

  public static int MAX_THEMES = 100;
  public class Theme {
    public String name;
    public String filename;
    public String xsltTransform;
    public XsltExecutable xsltExe;
    public boolean ready;
    public Menu menu;
    public String[] title;
    public String motd;

    public Theme () 
    {
      title = new String[Menu.LANGUAGES];
    }
  }

  public int themes;
  public Theme[] theme;  

  /*
   * SAXHandler class to parse the Servlet's configuration file.  This basically does nothing
   * other than read the individual "theme" elements. All other elements are ignored.
   */

  public class ConfigFileHandler extends DefaultHandler {
   
    StringBuffer currentString = null;
    int currentLanguage = 0;
    ThemeServlet servlet = null;

    public ConfigFileHandler ( ThemeServlet s ) 
    {
       super();
       servlet = s;
    }

    public void startElement ( String uri,
                               String localName,
                               String qname,
                               Attributes attr ) throws SAXException
    {
      if (qname.equals("theme")) {
        servlet.theme[servlet.themes] = new Theme();
        servlet.theme[servlet.themes].name = attr.getValue("name");
        servlet.theme[servlet.themes].filename = attr.getValue("file");
        servlet.theme[servlet.themes].xsltTransform = attr.getValue("transform");
        servlet.theme[servlet.themes].xsltExe = null;
        servlet.theme[servlet.themes].ready = false;
        servlet.theme[servlet.themes].menu = null;
        servlet.theme[servlet.themes].motd = attr.getValue("motd");
      } else if (qname.equals("Display")) {
        currentLanguage = Menu.languageId(attr.getValue("lang"));
        currentString = new StringBuffer();
      }
    }

    public void endElement  ( String uri,
                              String localName,
                              String qname ) throws SAXException
    {
      if (qname.equals("theme")) {
        servlet.themes += 1;   
      } else if (qname.equals("Display")) {
        servlet.theme[servlet.themes].title[currentLanguage] = currentString.toString();
        currentString = null;
      }
    }

    /*
    * Keep track of the current Element's text.  Note that text is only allowed in the
     * Display element.
     */

    public void characters ( char ch[],
                             int start,
                             int length ) throws SAXException
    {
      if (currentString != null) {
        currentString.append(ch,start,length);
      }
    }
  }

  public void init ( ServletConfig config )
    throws ServletException
  {
    super.init(config);

    /*
     * Initialize the log4j system
     */

    BasicConfigurator.configure();
    String log4jconfig = getServletContext().getInitParameter(_INIT_PARAM_LOG4JCONF);
    if (log4jconfig != null) {
      String fullPath = getServletContext().getRealPath(log4jconfig);
      if (fullPath != null) {
        PropertyConfigurator.configure(fullPath);
      }
    } else {
      logger.debug("No Log4J configuration file found, using defaults");
    }

    /*
     * Initialize the storage array for the theme names, locations, and menu structures
     */

    theme = new Theme[MAX_THEMES];
    themes = 0;

    /*
     * Figure out which configuration file to use
     */

    String configFileName = config.getInitParameter(_INIT_PARAM_CONFIG_FILE);
    if (configFileName == null) {
      configFileName = myConfigFile;
    }

    String logFileName = config.getInitParameter(_INIT_PARAM_LOG_FILE_NAME);
    if (logFileName != null) {
      try {
        String s = getServletContext().getRealPath("/") + "../../logs/" + logFileName; 
        clfLog = new CLFLog(s);
      } catch (Exception fnf) {
        logger.error(fnf.getMessage());
      }
    }

    /*
     * Figure out where to put the result cache
     */

    String cacheDirName = config.getInitParameter(_INIT_PARAM_CACHE_DIR);
    if (cacheDirName == null) {
      cacheDirName = myCacheDir;
    }

    /*
     * Create the cache directory - since we only reload menu definitions when we restart
     * the webapp.  The cache is cleared everytime we restart and the caching duration is 
     * set to a really long time.
     */
   
    try {
      String cacheDir = getServletContext().getRealPath(cacheDirName + "/");
      myCache = new Cache(cacheDir,3600*24*365);
      myCache.clear();
    } catch (Exception e) {
      e.printStackTrace();
    }

    /*
     *  Create an XSLT processor and compiler for the servlet
     */

    try {
      xsltProcessor = new Processor(false); 
      xsltCompiler = xsltProcessor.newXsltCompiler();
    } catch (Exception e) {
      e.printStackTrace();
    }

    /*
     * Load the contents of the configuration file.
     */

    try {
      String configFile = getServletContext().getRealPath("WEB-INF/" + configFileName);
      logger.debug("Loading config file:  " + configFile);
      SAXParserFactory factory = SAXParserFactory.newInstance();
      SAXParser parser = factory.newSAXParser();
      ConfigFileHandler handler = new ConfigFileHandler(this);
      parser.parse(configFile,handler);
    } catch (Exception e) {
      e.printStackTrace();
    }

    /*
     * Initialize the menus
     */

    for ( int n = 0; n < this.themes; n++ ) {
      if (theme[n].filename != null) {
        theme[n].filename = getServletContext().getRealPath(theme[n].filename);
      } else {
        logger.error("No menu file found for theme: " +  theme[n].name);
      }
      if (theme[n].xsltTransform != null) {
        theme[n].xsltTransform = getServletContext().getRealPath(theme[n].xsltTransform);
      } else {
        logger.error("No transform file found for theme: " + theme[n].name);
      }
      try {
        logger.debug("Theme[" + Integer.toString(n) + "].name = \"" + theme[n].name + "\"");
        logger.debug("Theme[" + Integer.toString(n) + "].filename = \"" + theme[n].filename + "\"");
        logger.debug("Theme[" + Integer.toString(n) + "].xsltTransform = \"" + theme[n].xsltTransform + "\"");
         
        /*
         * Load the XML menu definition file
         */
 
        theme[n].menu = new Menu(theme[n].filename);
        if (theme[n].menu != null) {
          theme[n].ready = true; 
          for (int m = 0; m < Menu.LANGUAGES; m++) {
            if (theme[n].title[m] != null) {
              theme[n].menu.label[m] = theme[n].title[m];
            }
          }
          if (theme[n].motd != null) {
            theme[n].menu.URL = theme[n].motd;
          }
        } else {
          logger.error("Empty menu generated for \"" + theme[n].name + "\".");
        }
        

        /*
         * Load the theme's XSL transformation file and convert it to an executable.
         */

        if (theme[n].xsltTransform != null) { 
          theme[n].xsltExe = xsltCompiler.compile(new StreamSource(new File(theme[n].xsltTransform)));
        }
      } catch ( Exception e )  {
        logger.error("Exception while initializing theme \"" + theme[n].name + "\".");
        //e.printStackTrace();
        //logger.error("Theme " + Integer.toString(n) + " name:  " + theme[n].name + " file: "  + theme[n].filename);
      }
    }

    /*
     * Specify the alternate menus that are available from each menu
     */

    for (int n = 0; n < this.themes; n++) {
      if (theme[n].menu != null) {
        for (int m = 0; m < this.themes; m++) {
          if (theme[m].menu != null) {
            for (int p = 0; p < Menu.LANGUAGES; p++) {
              theme[n].menu.addAlternateTheme(theme[m].name,theme[m].title[p],p);
            }
          }
        }
      }
    }
  }


  /*
   * Conveniance function that will check the provided parameter value to see if it 
   * should be interpreted as a boolean true or a boolean false.
   */

  private boolean checkRequestFlag ( String f )
  {
    boolean r = false;
    if (( f != null) &&
        ( f.equals("1") || f.equals("true") || f.equals("yes"))) {
      r = true;
    } 
    return r; 
  }
  
  /*
   * Basic handler for the request
   */

  public void requestHandler ( HttpServletRequest request, 
                               HttpServletResponse response ) 
  {
    String pathInfo = request.getPathInfo();
    StringBuffer r = null;
    Integer httpStatusCode = 200;
    String embedURL = null;
    boolean htmlOutput = false;

    String themeName = request.getParameter("theme");
    String nodeName = request.getParameter("node");
    String showOnly = request.getParameter("showonly");
    String vidName = request.getParameter("vid");
    String lang = request.getParameter("lang");
 
    /*
     * See if we need to output just the XML instead of the transformed output
     * Level 1 is the XML required to generate the UI for this page
     * Level 2 is the complete subtree of nodes and views that come below this page (this
     *         is used by tools that analyze the menu tree to perform specific functions
     *         like pre-generating content)
     */

    int xmlOnly = 0;
    String xmlOnlyStr = request.getParameter("xml");
    if (xmlOnlyStr != null) {
      if (xmlOnlyStr.equals("1")) {
        xmlOnly = 1;
      } else if (xmlOnlyStr.equals("2")) {
        xmlOnly = 2;
      }
    }

    boolean embed = checkRequestFlag(request.getParameter("embed"));
    String search = request.getParameter("search");
    String searchThemes = request.getParameter("st");

    /* 
     * Should the menu be shown or hidden for this particular page
     */

    int display_mode = Menu.DISPLAY_MODE_SHOW;
    String dispMode = request.getParameter("menu");
    if ((dispMode != null) && (dispMode.equals("hide"))) {
      display_mode = Menu.DISPLAY_MODE_HIDE;
    }     

    /*
     * If we have any URL parameters prefix with a x- or a X- , these are parameters
     * to pass on to the URL referenced in the menu entry, to be interpreted by the 
     * target, for example cache=refresh when using the GHO web client.
     */

    String passthroughParameters = null;
    Enumeration<String> parms = request.getParameterNames();  
    while (parms.hasMoreElements()) {
      String name = parms.nextElement();
      if (name.startsWith("x-") || name.startsWith("X-")) {
        String value = request.getParameter(name); 
        if (passthroughParameters == null) {
          passthroughParameters = "";
        } else {
          passthroughParameters += "&amp;";
        }
        passthroughParameters += name.substring(2) + "=" + value;
      }
    }

    /*
     * If we are requesting a search , some of the parameters need to be overiden if
     * they have been specified since they dont make sense in a search context
     */

    if (search != null) {
      embed = false;
      vidName = null;
      nodeName = null;
    }

    /*
     * First see if we've already got this page in the result cache.  If we're in xml
     * only mode, we bypass the cache and regenerate the XML from the current menu contents
     */

    if ((xmlOnly == 0) && !embed && (search == null) && (passthroughParameters == null)) {
      r = myCache.get(themeName,nodeName,vidName,showOnly,lang,display_mode);
    }

    /*
     * If we got a result, check to see if we have an XSL transform for the theme,
     * If we do, the content type should be set to text/html
     */

    if (r != null) {
      for ( int n = 0; n < themes; n++ ) {
        if (theme[n].name.equals(themeName)) {
          if (theme[n].xsltExe != null) {
            htmlOutput = true;
          }
          break;
        }
      }
    } else if (embed && ((vidName != null) || (nodeName != null))) {

      /*
       * If we specified embeded mode and we provided a VID, then we're going to send
       * an HTTP location header field with the corresponding View's URL
       */

      for (int n = 0; n < themes; n++) {
        if ((theme[n].ready) && 
            (theme[n].name.equals(themeName))) {
          View v = null;
          if (vidName != null) {
            v = theme[n].menu.getView(vidName);
          } else if (nodeName != null) {
            v = theme[n].menu.getViewByNodeID(nodeName);
          }
          if (v != null) {
            embedURL = v.URL;
          } 
          break;
        }
      } 

    } else if (themeName != null) {

      /*
       * We didn't get a result or a request to embed, we'll process the request and save 
       * the result in the cache if it succeeds.
       */

      for ( int n = 0; n < themes; n++ ) {
        if ((theme[n].ready) && 
            (theme[n].name.equals(themeName))) {
          
          if ((showOnly != null) && (nodeName == null)) {
            nodeName = showOnly;
          }

          String xml = null;

          /*
           * Execute a search if we have a search term in the URL instead of opening the menu
           */

          if (search != null) {

            /* 
             * If there is no specified search themes, then the search executes only 
             * in the current theme.
             */

            if (searchThemes == null) {
              xml = theme[n].menu.search(theme[n].name,showOnly,search,lang);
            } else {
            
              /*
               * If a series of search themes has been specified, we search in the current
               * theme, plus all of the other specified themes in order.  If the current 
               * theme is also in the list, it is only run once
               * 
               * First we split up the list of search themes and remove the current 
               * theme if it is present in the list.
               */

              String[] searchTheme = searchThemes.split(";");
              int searchThemesRemaining = searchTheme.length;
              for (int p = 0; p < searchTheme.length; p++) {
                if ((searchTheme[p] != null) && (searchTheme[p].equals(theme[n].name))) { 
                  searchTheme[p] = null;
                  searchThemesRemaining -= 1;
                  break;
                }
              }
  
              /*
               * Search the current theme first so that it's results show up first
               */

              StringBuffer search_result = new StringBuffer();
              search_result.append(theme[n].menu.search(theme[n].name,showOnly,search,lang));

              /* Now search the other themes in the list, but only if they're flagged as
               * ready.
               */

              for (int m = 0; m < themes; m++) {
                if (theme[m].ready) {
                  for (int p = 0; p < searchTheme.length; p++) {
                    if ((searchTheme[p] != null) && (searchTheme[p].equals(theme[m].name))) { 
                      searchTheme[p] = null;
                      searchThemesRemaining -= 1;
                      search_result.append(theme[m].menu.search(theme[m].name,showOnly,search,lang));
                    }
                  }
                  if (searchThemesRemaining < 1) {
                    break;
                  }
                }
              }
              xml = search_result.toString();
            }
         
            /*
             * Wrap the result with proper XML elements and headers
             */

            xml = theme[n].menu.wrapSearchResults(xml,theme[n].name,search,lang);
          } else if ((xmlOnly == 2) && (vidName == null)) {
            /*
             * Return the menu subtree rooted at the specified node in XML
             */
            xml = theme[n].menu.renderToXML(theme[n].name,nodeName,lang,passthroughParameters);
          } else {
          /*
           * Send back the (transformed) XML / HTML specification to render the UI page. If
           * we tried to embed a view, but failed we wont have an embedURL value.  In this
           * case continue on to see if we can at least provide a UI for the theme.  If we 
           * specified a search parameter, we handle it here.
           */ 
  
            xml = theme[n].menu.openToNodeXML(theme[n].name,
                                              nodeName,
                                              showOnly,
                                              vidName,
                                              lang,
                                              display_mode,
                                              passthroughParameters);
          }       
 
          /*
           * If there is an XSL processor assigned to the theme, apply it now (unless we've
           * specified the xmlOnly flag, in which case, we bypass the transform and output
           * only the XML text).
           */

          if ((theme[n].xsltExe != null) && (xmlOnly == 0)) {
            logger.debug("Running XSLT transform");
            try {
              StringWriter sw = new StringWriter();
              Serializer out = new Serializer();
              out.setOutputWriter(sw);
              XdmNode source = xsltProcessor.newDocumentBuilder()
                                            .build(new StreamSource(new StringReader(xml)));
              XsltTransformer trans = theme[n].xsltExe.load();
              trans.setInitialContextNode(source);
              trans.setDestination(out);
              trans.transform(); 
              r = sw.getBuffer(); 
              htmlOutput = true;
            } catch (Exception e) {
              logger.error(e.getMessage());
            }
          }
          if (r == null) {
            r = new StringBuffer(xml);
          }
       
          /*
           * Only store the result if we're not in XML only mode and if it's not a search 
           * request (otherwise you get stuck after the first time that someone requests 
           * an XML version of a page.  We also dont cache entries with passthroughParameters
           */

          if ((xmlOnly == 0) && (search == null) && (passthroughParameters == null)) {
            myCache.put(themeName,nodeName,vidName,showOnly,lang,display_mode,r);
          }
        } 
      }
    }

    if (r == null) {
      httpStatusCode = 500;
      r = new StringBuffer("<html><body><h1>Could not process request</h1></body></html>");
      htmlOutput = true;
    }

    try {
      response.setCharacterEncoding(_DEFAULT_CHARSET);
      PrintWriter out = response.getWriter();
      if (embedURL != null) {
        response.sendRedirect(embedURL);
      } else {
        if (htmlOutput) {
          response.setContentType("text/html");
          
          /*
           * Suppress compatibility mode in Internet explorer.  This is done here rather than
           * in the XSLT UI transformation file because we run into conflicts with XSLT's
           * automatically generated meta tags for the HTML method.  Specifically, the 
           * XSLT engine is required to put out a meta http-equiv  for the content-type as
           * the first element in the <head> element, which conflicts with putting 
           * http-equiv X-UA-Compatible:IE=edge as the first element
           */
         
          response.setHeader("X-UA-Compatible","IE=edge");
          out.println("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">");
        } else {
          response.setContentType("application/xml");
        }
        out.println(r.toString());
      }
    } catch (Exception e) {
      logger.error(e.getMessage());
      e.printStackTrace();
    }

    /*
     * If we've specified a request log, record the request
     */
    if (clfLog != null) {
      clfLog.record(request,httpStatusCode,null,null);
    }

  }

  public void doGet ( HttpServletRequest request, 
                      HttpServletResponse response ) 
    throws ServletException, IOException 
  {
    requestHandler(request,response);
  }

  public void doPost ( HttpServletRequest request, 
                       HttpServletResponse response ) 
    throws ServletException, IOException 
  {

  }

  public void doPut ( HttpServletRequest request, 
                      HttpServletResponse response ) 
    throws ServletException, IOException 
  {

  }
  
  public void doDelete ( HttpServletRequest request, 
                         HttpServletResponse response ) 
    throws ServletException, IOException 
  {

  }

}
