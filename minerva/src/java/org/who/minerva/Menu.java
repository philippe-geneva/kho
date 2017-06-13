/*
 * (c) 2010, World Health Organization
 *
 * $Id$
 * $HeadURL$
 */

package org.who.minerva;

import java.util.Vector;
import java.lang.Integer;
import java.lang.StringBuffer;
import java.util.ArrayList;
import java.util.HashSet;

import org.apache.log4j.Logger;


import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import org.who.minerva.View;
import org.who.minerva.SAXMenuHandler;

public class Menu {

  private static Logger logger = Logger.getLogger(Menu.class);

  //
  // This is a bit sloppy, since we only expect to ever deal with at most
  // 6 languages, they're coded here, with the 2 letter iso code also 
  // set here.  If you wish to add a language, use the next available 
  // integer for it, and increase the value of the LANGUAGES constant by
  // 1.  You must also edit the functions languageCode and languageId.
  //

  public static int LANGUAGES = 4;

  public static int ENGLISH = 0;
  public static int FRENCH = 1;
  public static int ARABIC = 3;
  public static int SPANISH = 2;

  public static int DEFAULT_LANGUAGE = ENGLISH;

  public static String ENGLISH_CODE = "en";
  public static String FRENCH_CODE = "fr";
  public static String SPANISH_CODE = "es";
  public static String ARABIC_CODE = "ar";

  // attribute to inform the user interface template if it should start by 
  // showing the menu, or start with the menu hidden.  The default mode is
  // to show it.

  public static int DISPLAY_MODE_SHOW = 0;
  public static int DISPLAY_MODE_HIDE = 1;

  public String id;
  public String[] label;
  public String[] label_upper; // This is for searching
  public String[] description;
  public boolean hidden;	// Set to true if the menu should be completely hidden,
				// When true it cannot be navigated to.  Note that this
      				// is different from the from the display_mode which can
 				// be toggled by the user.
  public String[] searchThemes;	// The list of themes that can be search from this theme
				// If this is null, use only the current theme.
  public String URL;
  public String redirectTo;
  public Vector<Menu> menu;
  public Vector<View> view;
  public boolean searchViews; // set to false if you dont want to the View Display
                              // strings to be searched

  /*
   * Stores the list of alternate themes you can access from this menu
   */

  public ArrayList<AltTheme> altTheme;

  /*
   * Maximum limit for menu configuration redirects
   */

  public static int MAX_REDIRECT = 10;


  /*
   * Maximum score for a search result
   */

  public static int BASE_SCORE = 1000;

  /*
   * Stores the list of alternate themes you can access from this menu
   */

  public class AltTheme {
    public String id;
    public String[] label;
  }

  /*
   */
  
  public Menu () 
  {
    this.id = "ROOT";
    this.label = new String[LANGUAGES];
    this.label_upper = new String[LANGUAGES];
    this.description = new String[LANGUAGES];
    for (int n = 0; n < LANGUAGES; n++) {
      this.label[n] = null;
      this.label_upper[n] = null;
      this.description[n] = null;
    }
    this.label[ENGLISH] = "root";
    this.label_upper[ENGLISH] = "ROOT";
    this.hidden = false;
    this.URL = "";
    this.redirectTo = null;
    this.menu = new Vector<Menu>();
    this.view = new Vector<View>();
    this.altTheme = null; // only initialized if it is needed
    this.searchViews = true;
    this.searchThemes = null;
  } 

  /*
   * Add a new entry to the list of alternate themes that could be accessed
   * from this menu.
   */

  public void addAlternateTheme ( String id,
                                  String label,
                                  int lang )
  {
    if (altTheme == null) {
      altTheme = new ArrayList<AltTheme>();
    }
    AltTheme at = null;

    /*
     * See if we already have an entry for the theme in some language
     */

    if (!this.altTheme.isEmpty()) {
      for (AltTheme xx : this.altTheme) {
        if (xx.id.equals(id)) {
          at = xx;
          break;
        }
      }
    }

    /*
     * If we didnt find an entry make a new one 
     */

    if (at == null) {
      at = new AltTheme();
      at.label = new String[LANGUAGES];
      at.id = id;
      altTheme.add(at);
    }
    
    if ((lang >=0) && ( lang < LANGUAGES)) {
      at.label[lang] = label;
    }
    
  }

  /* 
   * Create the menu object from an XML file
   */ 

  public Menu ( String filename )
  {
    this.id = "ROOT";
    this.label = new String[LANGUAGES];
    this.label_upper = new String[LANGUAGES];
    this.description = new String[LANGUAGES];
    for (int n = 0; n < LANGUAGES; n++) {
      this.label[n] = null;
      this.label_upper[n] = null;
      this.description[n] = null;
    }
    this.hidden = false;
    this.URL = null;
    this.menu = new Vector<Menu>();
    this.view = new Vector<View>();
    this.altTheme = null; // only initialized if it is needed
    try {
      SAXParserFactory factory = SAXParserFactory.newInstance();
      SAXParser saxParser = factory.newSAXParser();
      SAXMenuHandler handler = new SAXMenuHandler();
//      handler.setDebugMode(true);
      saxParser.parse(filename,handler);
      Menu root = handler.getMenu();
      this.id = root.id;
      for (int n = 0; n < LANGUAGES; n++) {
        this.label[n] = root.label[n];
        this.label_upper[n] = root.label[n];
      }
      this.searchThemes = root.searchThemes;
      this.hidden = root.hidden;
      this.URL = root.URL;
      this.menu = root.menu;
      this.view = root.view;
    } catch (Exception e) {
      logger.error(e.getMessage()); 
      for (int n = 0; n < LANGUAGES; n++) {
        this.menu.get(0).label[n] = "ERROR " + e.getMessage();
        this.menu.get(0).label_upper[n] = "ERROR " + e.getMessage();
      }
      //e.printStackTrace();
    }
  }

  /*
   *
   */
  public Menu ( String id,
                String URL,
                boolean hidden )
  {
    this();
    this.id = id;
    this.URL = URL;
    this.hidden = hidden;
    this.altTheme = null;
  }

  /*
   * Explore the menu structure to find the desired node.  If it is located,
   * we pop out of the recursion, setting the appropriate node index for every 
   * level of the menu.  We return the target name of the node - if the node has
   * a redirection ID, we return that instead so that the caller can look for the
   * redirected node instead.
   * 
   * If we dont find anything, return a null.
   */

  private String _locateNode (Vector<Integer> v,
                               String id )
  {
    String found = null;
    for (int n = 0; n < this.menu.size(); n++) {
      if (this.menu.get(n).id.equals(id)) {

        /*
         * If we have a redirection node ID specified,  we look for the alternate node instead
         */
         
        if (this.menu.get(n).redirectTo != null) {
          found = this.menu.get(n).redirectTo;
        } else {
          found = this.menu.get(n).id;
        }
      } else if (this.menu.get(n).menu.size() > 0) {
        found = this.menu.get(n)._locateNode(v,id);
      }
      if (found != null) {
        v.insertElementAt(new Integer(n),0);
        break;
      }
    }
    return found;
  }

  /*
   * Locate the specified view.  In this case, we will also need the ID of the parent
   * node, so instead of returning a boolean we return a String pointer.  If it is null,
   * the view was not found. 
   */

  private String _locateView (Vector<Integer> v,
                               String vid )
  {
    String nodeid = null;

    for (int m = 0; m < this.view.size(); m++) {
      if (this.view.get(m).id.equals(vid)) {
        nodeid = this.id;
        break;
      }
    }
    if (nodeid == null) {
      for (int n = 0; n < this.menu.size(); n++) {
        nodeid = this.menu.get(n)._locateView(v,vid);
        if (nodeid != null) {
          v.insertElementAt(new Integer(n),0);
          break;
        }
      }
    } 
    return nodeid;
  }

  /**
   * Locate the specified VID in the menu and return the View object
   */

  public View getView ( String vid ) 
  {
    View v = null;
    for (int n = 0; n < this.view.size(); n++) {
      View v_tmp = this.view.get(n);
      if (v_tmp.id.equals(vid)) {
        v = v_tmp;
        break;
      }
    }
    if (v == null) {
      for (int n = 0; n < this.menu.size(); n++) {
        v = this.menu.get(n).getView(vid);
        if (v != null) {
          break;
        }
      }
    }
    return v;
  }


  /**
   * Given a node ID, locate the first view that is associated to that node
   */

  public View getViewByNodeID ( String nid )
  {
    View v = null;
    if (this.id.equals(nid)) {
      if ((this.view != null) && (this.view.size() > 0)) {
        v = this.view.get(0);
      }
    } else {
      for (int n = 0; n < this.menu.size(); n++) {
        v = this.menu.get(n).getViewByNodeID(nid);
        if (v != null) {
          break;
        }
      } 
    }
    return v;

  }

  /*
   * Create an XML text that contains the id and display labels for alternate
   * themes that are avaiable from this menu
   */

  public String listAlternateThemes(int lang) 
  {
    StringBuffer sb = new StringBuffer();

    if (altTheme != null) {
      for (AltTheme at: altTheme) {
        sb.append("  <Theme id=\"" + at.id + "\">\n");
        String lbl = at.label[lang];
        int lbl_lang = lang;
        if (lbl == null) {
          lbl = at.label[DEFAULT_LANGUAGE];
          lbl_lang = DEFAULT_LANGUAGE;
        }
        if (lbl == null) {
          lbl = "text not available";
          lbl_lang = ENGLISH;
        }
        sb.append("    <Display lang=\"" + 
                  languageCode(lbl_lang) + "\">" + 
                  Utility.makeWebSafe(lbl) + 
                  "</Display>\n");
        sb.append("  </Theme>\n");
      }
    }
    return sb.toString();
  }


  /*
   * Render the menu or portion thereof to XML.  This method will generate the
   * complete sub tree from (and including) the specified node.  It is used to support
   * tools that look at complete subtrees of the menu structure to do things like 
   * pre-generating content
   *
   */
  public String renderToXML( String theme , String id , String lang )
  {
     return renderToXML(theme,id,lang,null);
  }

  public String renderToXML( String theme , String id , String lang, String passthroughParameters )
  {
    HashSet<String> visited = new HashSet<String>();
    int lang_id = languageId(lang);
    StringBuffer sb = new StringBuffer();
    sb.append("<Menu");
    if (theme != null) {
      sb.append(" theme=\"" +  theme + "\"");
    }

    // If this menu has search themes, output them

    if (this.searchThemes != null) {
      sb.append(" searchthemes=\"");
      for (int i = 0; i < this.searchThemes.length; i++) {
        if (i != 0) {
          sb.append(";");
        }
        sb.append(this.searchThemes[i]);
      }
      sb.append("\"");
    }
    sb.append(" mode=\"show\">");
    if ((this.label != null) && (!(this.label.equals("")))) {
      sb.append("  <Display");
      sb.append(" lang=\"" + languageCode(lang_id) + "\"");
      sb.append(">" + Utility.makeWebSafe(this.label[lang_id]) + "</Display>\n");
    }
    sb.append(listAlternateThemes(lang_id));
    sb.append(renderToXML(this,id,lang_id,visited,passthroughParameters));
    sb.append("</Menu>\n");
    return sb.toString();
  }

  /*
   * The method will follow redirectTo links.  In order to prevent cycles, it keeps track
   * of the nodes that it has already output by storing node ids in the visited HashSet.
   */

  public String renderToXML( Menu root , String id , int lang , HashSet<String> visited )
  {
    return renderToXML(root,id,lang,visited,null);
  }

  public String renderToXML( Menu root , String id , int lang , HashSet<String> visited , String passthroughParameters)
  {
    StringBuffer xml = new StringBuffer();

    /*
     * If we havent output this node yet, and we're in a subtree that we have to output or
     * we've just found the node we're looking for, output the node and it's subtree.
     */

    if (!visited.contains(this.id) && ((id == null) || this.id.equals(id))) {
      visited.add(this.id);

      /*
       * Decide on which language to use for the node 
       */

      String lbl = this.label[lang];
      int lbl_lang = lang;
      if (lbl == null) {
        lbl = this.label[DEFAULT_LANGUAGE];
        lbl_lang = DEFAULT_LANGUAGE;
      }
      if (lbl == null) {
        lbl = "text not available";
        lbl_lang = ENGLISH;
      }

      xml.append("<Node id=\"" + this.id + "\"");

      if (this.hidden) {
        xml.append(" hide=\"1\"");
      }

      if (this.menu.size() == 0) {
        xml.append(" leaf=\"1\"");
      }

      if (this.URL != null) {
        xml.append(" URL=\"" + Utility.makeWebSafe(this.URL) + "\"");
      }

      xml.append(">\n");

      xml.append("<Display");
      xml.append(" lang=\"" + languageCode(lbl_lang) + "\"");
      xml.append(">" + Utility.makeWebSafe(lbl) + "</Display>\n");
 
      /* 
       * If this node is a redirect, then the correct subtree will be located 
       * elsewhere in the menu structure - we try to find it here.
       * A node should either contain 0 or more Views and sub nodes OR be a 
       * redirect but it cannot have both Views and/or sub Nodes and have
       * a redirectTo code as well.
       */

      if (this.redirectTo != null) {
        xml.append(root.renderToXML(root,this.redirectTo,lang,visited,passthroughParameters));
      } else {
        for (int m = 0; m < this.view.size(); m++ ) {
          xml.append(this.view.get(m).renderToXML(false,lang,passthroughParameters));
        }
        for (int m = 0; m < this.menu.size(); m++) {
          xml.append(this.menu.get(m).renderToXML(root,null,lang,visited,passthroughParameters));
        }
      }
     
      xml.append("</Node>\n");
    } else {
      for ( int m = 0; m < this.menu.size(); m++) {
        xml.append(this.menu.get(m).renderToXML(root,id,lang,visited,passthroughParameters));
      }
    }
    return xml.toString();
  }



  /*
   *
   */
  private static char[] _delim = { ' ', ':', ';', ',' };

  private String _openToNodeXML( String theme,
                                 String id,
                                 String vid,
                                 String showonly, 
                                 int lang,
                                 int depth, 
                                 Vector<Integer> v,
                                 StringBuffer description,
                                 int[] display_mode,
                                 String passthroughParameters )
  {
    StringBuffer sb = new StringBuffer();
    for (int n = 0; n < this.menu.size(); n++) {
      Menu node = this.menu.get(n);

      boolean showNode = true;

      if ((showonly != null) &&  (!node.id.equals(showonly))) {
        showNode = false;
      }
     
      /*
       * If the node is marked as hidden and it is not part of the overall seuquence of 
       * nodes leading to the selected node or view, hide it from the XML output
       */

      if (node.hidden) {
        showNode = false;
      }
   

      /*
       * Decide on which language string to use for the node
       */

      String lbl = node.label[lang];
      int lbl_lang = lang;
      if (lbl == null) {
        lbl = node.label[DEFAULT_LANGUAGE];
        lbl_lang = DEFAULT_LANGUAGE;
      }
      if (lbl == null) {
        lbl = "text not available";
        lbl_lang = ENGLISH;
      }

      if (showNode) {
        sb.append("<Node id=\"" + node.id + "\"");
        if (node.hidden) {
          sb.append(" hide=\"1\"");
        }
        if (node.menu.size() == 0) {
          sb.append(" leaf=\"1\"");
        }
        if (node.id.equals(id)) {
          sb.append(" selected=\"1\"");
        }
        if (node.URL != null) {
          sb.append(" URL=\"" + Utility.makeWebSafe(node.URL) + "\"");
        }
        sb.append(">\n");
        sb.append("<Display");
        sb.append(" lang=\"" + languageCode(lbl_lang) + "\"");
        sb.append(">" + Utility.makeWebSafe(lbl) + "</Display>\n");
      }
      if ((v != null) && (depth < v.size()) && (v.get(depth).compareTo(n) == 0)) {
        String recurShowonly = showonly;
        if (showNode && (showonly != null)) {
          recurShowonly = null; 
        } 
        if (depth < _delim.length) {
          description.append(_delim[depth]);
        } else {
          description.append(_delim[_delim.length - 1]);
        }
        description.append(" ");
        description.append(Utility.makeWebSafe(lbl));
        sb.append(node._openToNodeXML(theme,id,vid,recurShowonly,lang,depth + 1, v, description,display_mode,passthroughParameters));
      }
      if (showNode) {
        if (node.id.equals(id)) {
          for (int m = 0; m < node.view.size(); m++ ) {
            boolean viewSelected = false;
 
            /*
             * If we're showing a View, and it is marked to collapse or hide the
             * menu (ie, the menu="hide" attribute has been set in the View element's
             * XML), then we overide the display_mode control that may or may not have 
             * been specified by the user.
             */
            if (vid != null) {
              if (node.view.get(m).id.equals(vid)) {
                viewSelected = true;
                if (node.view.get(m).display_mode == Menu.DISPLAY_MODE_HIDE) {
                  display_mode[0] = Menu.DISPLAY_MODE_HIDE;
                }
              } 
            } else if (m == 0) {
              viewSelected = true;
              if (node.view.get(m).display_mode == Menu.DISPLAY_MODE_HIDE) {
                display_mode[0] = Menu.DISPLAY_MODE_HIDE;
              }
            }
            if (viewSelected) {
              description.append(" ");
              description.append(Utility.makeWebSafe(node.view.get(m).label[lang]));
            }
            if (!(node.view.get(m).hidden) || viewSelected) {
              sb.append(node.view.get(m).renderToXML(viewSelected,lang,passthroughParameters));
            }
          }
        }
        sb.append("</Node>\n");
      }
    }
    if (depth == 0) {

      /*
       * Generate the XML and Menu object prefix and defintion.  We do this
       * at the end rather than the beginning because we need to find out
       * from the target View (if there is one) if the we should initially show
       * the navigation menu in collapsed form or opened (opened is the default)
       */

      StringBuffer pfx = new StringBuffer();
      pfx.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
      pfx.append("<Menu theme=\"" +  theme + "\"");
      if (display_mode[0] == DISPLAY_MODE_HIDE) {
        pfx.append(" mode=\"hide\"");
      } else {
        pfx.append(" mode=\"show\"");
      }

      // Output the list of search themes for this menu

      if (this.searchThemes != null) {
        pfx.append(" searchthemes=\"");
        for (int i = 0; i < this.searchThemes.length; i++) {
          if (i != 0) {
            pfx.append(";");
          }
          pfx.append(this.searchThemes[i]);
        }
        pfx.append("\"");
      }

      if (this.URL != null) {
        pfx.append(" URL=\"" + this.URL + "\"");
      }
      if ((showonly != null) && (!showonly.equals(""))) {
        pfx.append(" showonly=\"" + showonly + "\"");
      }
      pfx.append(" lang=\"" + languageCode(lang) + "\"");
      pfx.append(">\n");
      if ((this.label != null) && (!(this.label.equals("")))) {
        pfx.append("  <Display");
        pfx.append(" lang=\"" + languageCode(lang) + "\"");
        pfx.append(">" + Utility.makeWebSafe(this.label[lang]) + "</Display>\n");
      }
      pfx.append(listAlternateThemes(lang));

      sb.insert(0,pfx);
      sb.append("  <Description><Display>");
      sb.append(description);
      sb.append("  </Display></Description>");
      sb.append("</Menu>\n");
    }
    return sb.toString();
  }

  /*
   * The search method build's an XML resonse that points to appropriate nodes 
   * within the theme. It is a recursive function.
   */

  public String search ( String theme, 
                         String showonly, 
                         String q, 
                         String lang)
  {
     if ((theme != null) && theme.equals("")) {
       theme = null;
     }
     String[] tokens = null;
     if ((q != null) && q.equals("")) {
       tokens = null; 
     } else { 
       tokens = q.trim().toUpperCase().split("\\s");
     }
     return _search(theme,showonly,tokens,languageId(lang),null,null,0);
  }


  /*
   * Wraps the list of search results into a proper XML menu response
   */

  public String wrapSearchResults(String xml,
                                  String theme,
                                  String q,
                                  String lang_str)
  {
    int lang = languageId(lang_str);
    StringBuffer sb = new StringBuffer();
    sb.append("<Menu theme=\"" +  theme + "\" mode=\"show\"");

// output the list of searchthemes for this menu if there are any

    if (this.searchThemes != null) {
      sb.append(" searchthemes=\"");
      for (int i = 0; i < this.searchThemes.length; i++) {
        if (i != 0) {
          sb.append(";");
        }
        sb.append(this.searchThemes[i]);
      }
      sb.append("\"");
    }
    sb.append(">");

    if ((this.label != null) && (!(this.label.equals("")))) {
      sb.append("  <Display");
      sb.append(" lang=\"" + languageCode(lang) + "\"");
      sb.append(">" + Utility.makeWebSafe(this.label[lang]) + "</Display>\n");
    }
    sb.append(listAlternateThemes(lang));
    sb.append("<SearchQuery><Display>");
    if (q != null) {
      sb.append(Utility.makeWebSafe(q));
    }
    sb.append("</Display></SearchQuery>\n");
    sb.append("<SearchResults>\n");
    sb.append(xml);
    sb.append("  </SearchResults>\n");
    sb.append("</Menu>\n");
    return sb.toString();
  }

  public String _search (String theme, 
                         String showonly, 
                         String[] q, 
                         int lang, 
                         String pfx, 
                         String pfx_upper, 
                         int d)
  {
    StringBuffer sb = new StringBuffer();

    if ((q != null) && (theme != null)) {
      for (int n = 0; n < this.menu.size(); n++) {
        Menu node = this.menu.get(n);

        boolean showNode = true;

        if ((showonly != null) &&  (!node.id.equals(showonly))) {
          showNode = false;
        }
     
        /*
         * If the node is marked as hidden and it is not part of the overall seuquence of 
         * nodes leading to the selected node or view, hide it from the XML output
         */

        if (node.hidden) {
 //         showNode = false;
        }
   

        /*
         * Decide on which language string to use for the node
         */

        String lbl = node.label[lang];
        int lbl_lang = lang;
        if (lbl == null) {
          lbl = node.label[DEFAULT_LANGUAGE];
          lbl_lang = DEFAULT_LANGUAGE;
        }
        if (lbl == null) {
          lbl = "text not available";
          lbl_lang = ENGLISH;
        }
  
        if (showNode) {
          String disp_lbl = lbl;
          if ((pfx != null) && !pfx.equals("")) {
            disp_lbl = pfx + " > " + lbl;
          }
          String match_str = node.label_upper[lbl_lang];
          if (pfx_upper != null) {
            match_str = pfx_upper + match_str;
          }

          /*
           * Using a fairly simple scoring mechanism, divide the BASE_SCORE value
           * by the product of the depth of the node and the number of tokens being
           * searched, multiply by the total number of hits on the complete string
           * name of the node.  This makes things like indicator entries come out near
           * the top, and views that may contain a search token in its path but not in the 
           * view name come out nearer to the bottom of the list
           *
           * 1 is added to the depth (d) in order to avoid a division by zero 
           */

          int score = 0;
          int hit_cnt = 0;
          boolean nodeMatches = true;
          for (int y = 0; y < q.length; y++) {
            int ndx = 0;
            int cnt = 0;
            while ((ndx = match_str.indexOf(q[y],ndx)) > -1) {
              cnt++;
              ndx += 1;
            }
            if (cnt == 0) {
              nodeMatches = false;
              break;
            } else {
              hit_cnt += cnt;
            }
          }
          if (nodeMatches) {
            score = (BASE_SCORE / (q.length * (d + 1))) * hit_cnt;
            sb.append("<SearchResult ");
            sb.append("theme=\"" + theme + "\" ");
            sb.append("node=\"" + node.id + "\" ");
            sb.append("score=\"" + score + "\" ");
            sb.append(">\n");
            sb.append("<Display");
            sb.append(" lang=\"" + languageCode(lbl_lang) + "\"");
            sb.append(">" + Utility.makeWebSafe(disp_lbl) + "</Display>\n");
            sb.append("</SearchResult>\n");
          }

          /*
           * Also scan the node's views if it has any
           */

          if (searchViews) {
 
            /*
             * Same scoring algorithm as for the nodes, +1 is added to the depth to 
             * reflect the fact that the View entry is one layer deeped than the node
             * and another +1 is added to avoid division by zero, hence +2
             */

            for (int z = 0; z < node.view.size(); z++) {
              String complete_title = match_str + node.view.get(z).label_upper[lbl_lang];
              score = 0;
              hit_cnt = 0;
              boolean viewMatches = true;
              for (int y = 0; y < q.length; y++) {
                int cnt = 0;
                int ndx = 0;
                while ((ndx = complete_title.indexOf(q[y],ndx)) > -1) {
                  cnt++;
                  ndx += 1;
                }
                if (cnt == 0) {
                  viewMatches = false;
                  break;
                } else {
                  hit_cnt += cnt;
                }
              }
              if (viewMatches) {
                score = (BASE_SCORE / (q.length * (d + 2))) * hit_cnt;
                sb.append("<SearchResult ");
                sb.append("theme=\"" + theme + "\" ");
                sb.append("view=\"" + node.view.get(z).id + "\" ");
                sb.append("score=\"" + (score + score) + "\" ");
                sb.append(">\n");
                sb.append("<Display");
                sb.append(" lang=\"" + languageCode(lbl_lang) + "\"");
                sb.append(">" + Utility.makeWebSafe(disp_lbl + " " + node.view.get(z).label[lbl_lang]) + "</Display>\n");
                sb.append("</SearchResult>\n");
              }
            }
          }

          sb.append(node._search(theme,showonly,q,lang,disp_lbl,match_str,d+1));
        }
      }
    }
    return sb.toString();
  }

  /*
   *
   */

  public String openToNodeXML (String theme, String id,String passthroughParameters) 
  {
    return this.openToNodeXML(theme,id,null,null,null,DISPLAY_MODE_SHOW,passthroughParameters);
  }

  public String openToNodeXML (String theme, String id, String showonly, String passthroughParameters)
  {
    return this.openToNodeXML(theme,id,showonly,null,null,DISPLAY_MODE_SHOW,passthroughParameters);
  }

  public String openToNodeXML (String theme, 
                               String id, 
                               String showonly, 
                               String vid,
                               String lang,
                               int display_mode,
                               String passthroughParameters)
  {
    String nodeid = null;
    Vector<Integer> v = null;

    /* 
     * See if we can find the VID first if it has been supplied.  If we find the VID
     * we overide any node id that may have been passed with the parent node ID of the 
     * view.  This way we always render a consistent looking menu tree where view ids are
     * more important than node ids.
     */

    if ((vid != null) && (!vid.equals(""))) {
      v = new Vector<Integer>();
      nodeid = _locateView(v,vid);
      if (nodeid != null) {
        id = nodeid;
      } else {
        v = null;
      }
    } 

    /* 
     * If we dont have a vector, look for the node if that has been supplied
     */

    if ((v == null) && (id != null) && (!id.equals(""))) {

      /*
       * Try to locate the node - if we encounter redirects, we'll give up following
       * them once we've tried MAX_REDIRECT times - this prevents potential infinite loops
       * in a badly configured menu.
       */

      int max_redirect = MAX_REDIRECT;
      while (max_redirect-- > 0) {
        v = new Vector<Integer>();
        String target_node =  _locateNode(v,id);

        /*
         * We could not find the node
         */

        if (target_node == null) {
          v = null;
          break;
   
        /*
         * We've found the node but it has a redirection.  We drop the Vector so that the
         * service will show the main page if we hit the maximum redirection limit
         */

        } else if (!target_node.equals(id)) {
          id = target_node;
          v = null;
 
        /*
         * We've found the right node
         */

        } else {
          break;
        }
      }
    }
  
    int[] disp_mode_arr = { display_mode };
    return this._openToNodeXML(theme,
                               id,
                               vid, 
                               showonly,
                               languageId(lang),
                               0,
                               v,
                               new StringBuffer(),
                               disp_mode_arr,
                               passthroughParameters);
  }


  public static String languageCode (int lang) 
  {
    String code = ENGLISH_CODE;
    if (lang == SPANISH) {
      code = SPANISH_CODE;
    } else if (lang == FRENCH) {
      code = FRENCH_CODE;
    } else if (lang == ARABIC) {
      code = ARABIC_CODE;
    }
    return code;
  }

 
  public static int languageId( String lang )
  {
    int id = ENGLISH;

    if (lang != null) {
      if (lang.equals(SPANISH_CODE)) {
        id = SPANISH;
      } else if (lang.equals(FRENCH_CODE)) {
        id = FRENCH;
      } else if (lang.equals(ARABIC_CODE)) {
        id = ARABIC;
      }
    } 
    return id; 
  }
}

