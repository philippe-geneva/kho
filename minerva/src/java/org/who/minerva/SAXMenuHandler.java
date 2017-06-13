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
import java.util.HashSet;
import org.who.minerva.View;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

public class SAXMenuHandler extends DefaultHandler {
  
  public static int MAX_DEPTH = 100;
  public static int MAX_VIEWS = 500;
 
  public Menu root;
  public Menu[] menu;
  public int menuNdx;
  public View[] view;
  public int viewNdx; 
  public int[] elementType;
  public int[] elementLanguage;
  public int depth;
  public StringBuffer currentText;
  public int defaultDisplayMode;

  /*
   * These are used to keep track of the set of View Ids and Node Ids.  Each has
   * to be unique for it's particular element type across the menu file.  Ie
   * Every view ID must be unique, and every Node ID must be unique, however, a Node
   * could have the same ID as a View without cause a problem.
   */

  public HashSet<String> node_ids = new HashSet<String>();
  public HashSet<String> view_ids = new HashSet<String>();


  /*
   * Names of valid elements
   */

  public static String MENU_NAME = "Menu";
  public static String NODE_NAME = "Node";
  public static String VIEW_NAME = "View";
  public static String DISPLAY_NAME = "Display";
  public static String DESCRIPTION_NAME = "Description";

  /*
   * Numeric codes for the elements
   */

  public static int UNKNOWN_ELEMENT = 0;
  public static int MENU_ELEMENT = 1;
  public static int NODE_ELEMENT = 2;
  public static int VIEW_ELEMENT = 3;
  public static int DISPLAY_ELEMENT = 4;
  public static int DESCRIPTION_ELEMENT = 5;

  /*
   * Names of relevant attributes
   */

  public static String ID_ATTR = "id";
  public static String URL_ATTR = "URL";
  public static String HIDE_ATTR = "hide";
  public static String MENUMODE_ATTR = "menu";
  public static String TYPE_ATTR = "type";
  public static String LANG_ATTR = "lang";
  public static String REDIRECTTO_ATTR = "redirectto";
  public static String SEARCH_VIEWS_ATTR = "searchviews";
  public static String SEARCH_THEMES_ATTR = "searchthemes";
  

  /*
   * Used for debug outputs to stdout.
   */

  private boolean debugMode = false;
  private static String handlerName = "SAXMenuHandler";

  /*
   * Error messages
   */

  public static String ERRMSG_UNRECOGNIZED_START_ELEMENT = "Unrecognized element:  ";
  public static String ERRMSG_UNRECOGNIZED_END_ELEMENT = "Unrecognized close element:  ";

  /*
   * Constructor
   */

  public SAXMenuHandler() 
  {
    super();
    this.root = null; 
    this.menu = new Menu[MAX_DEPTH];
    this.view = new View[MAX_VIEWS];
    this.menuNdx = 0;
    this.viewNdx = 0;
    this.currentText = null;
    this.depth = 0;
    this.elementType = new int[MAX_DEPTH];
    this.elementLanguage = new int[MAX_DEPTH];
    this.defaultDisplayMode = Menu.DISPLAY_MODE_SHOW;
  }

  public void startDocument () throws SAXException
  {
    if (debugMode) {
      System.out.println(handlerName + ": Starting document.");
    }
  }


  public void endDocument() throws SAXException
  {
    if (debugMode) {
      System.out.println(handlerName + ": Ending document.");
    }
  }

  public void setDebugMode ( boolean f )
  {
    debugMode = f;
  }


  /*
   * Process a new element from the XML text
   *
   * We keep track of the stack of current elements using the elementType array.  For we 
   * add each new one as it comes.
   */
  
  public void startElement ( String uri,
                             String localName,
                             String qname,
                             Attributes attr ) throws SAXException
  {
    if (debugMode) {
      System.out.println(handlerName + ":  Start element \"" + qname + "\".");
    }

    /*
     * Process the hide attribute here since it is common to the View and Node elements and
     * is a straightforward boolean value.
     */

    boolean hidden = false;
    String hidden_attr = attr.getValue(HIDE_ATTR);
    if ((hidden_attr != null) && (hidden_attr.equals("1"))) {
      hidden = true;
    }

    /*
     * When we encounter a Node element, put add it to the stack of nodes being processed
     * with appropriate attributes set. Since only leaf nodes can contain views, we clear
     * out the view list and reset the viewNdx to 0.  This will cause any "illegal" views 
     * to be ignored and eventually dropped by the garbage collector.
     */

    if (qname.equals(NODE_NAME)) {
      String node_id = attr.getValue(ID_ATTR);
      if (node_id != null) {
        if (!node_ids.add(node_id)) {
          throw new SAXException("Duplicate Node id: " + node_id);
        }
      } else {
        throw new SAXException("Missing Node id!");
      }
      Menu newNode = new Menu(node_id,attr.getValue(URL_ATTR),hidden);
      newNode.redirectTo = attr.getValue(REDIRECTTO_ATTR);
      newNode.searchViews = menu[0].searchViews;
      menu[menuNdx - 1].menu.add(newNode);
      menu[menuNdx++] = newNode;
      elementType[depth++] = NODE_ELEMENT;
      for (int n = 0; n < viewNdx; n++) {
        this.view[n] = null;
      }
      this.viewNdx = 0; 

    /*
     * When we encounter a View element,  add it to the list of currently available views.
     * We will add the complete set to the Menu object once we close the containing node.
     */

    } else if (qname.equals(VIEW_NAME)) {
      int display_mode = this.defaultDisplayMode;
      if (attr.getValue(MENUMODE_ATTR) != null)  {
        if (attr.getValue(MENUMODE_ATTR).equals("hide")) {
          display_mode = Menu.DISPLAY_MODE_HIDE;
        } else if (attr.getValue(MENUMODE_ATTR).equals("show")) {
          display_mode = Menu.DISPLAY_MODE_SHOW;
        }   
      }
      String view_id = attr.getValue(ID_ATTR);
      if (view_id != null) {
        if (!view_ids.add(view_id)) {
          throw new SAXException("Duplicate View id: " + view_id);
        }
      } else {
        throw new SAXException("Missing View id!");
      }
      view[viewNdx++] = new View(view_id,
                                 attr.getValue(TYPE_ATTR),
                                 attr.getValue(URL_ATTR),
                                 display_mode,
                                 hidden);
      elementType[depth++] = VIEW_ELEMENT;

    /*
     * We just need to track that we have a Desription element.  Once parsed, the description 
     * is added in as an attribute of a menu entry or a view depending on it's parent.  This
     * is determined when we close the Description element.
     */

    } else if (qname.equals(DESCRIPTION_NAME)) {
      elementType[depth++] = DESCRIPTION_ELEMENT;

    /*
     * We just need to track that we have a Display element.  In this particular XML structure,
     * this is the only element that is allowed to contain text.  When closed it will be added
     * to appropriate menu entry (which can be a menu node text, view label, or a description
     */

    } else if (qname.equals(DISPLAY_NAME)) {
      elementLanguage[depth] = Menu.languageId(attr.getValue(LANG_ATTR));
      elementType[depth++] = DISPLAY_ELEMENT;
      this.currentText = new StringBuffer();

    /*
     * When we encounter the Menu element (which MUST be the first element in a menu file), 
     * initialize the Menu object with a root node.
     */

    } else if (qname.equals(MENU_NAME)) {
      elementType[depth++] = MENU_ELEMENT;
      menuNdx = 1;
      menu[0] = new Menu("ROOT","",false);
      for (int n = 0; n < Menu.LANGUAGES; n++) {
        menu[0].label[n]="Root";
        menu[0].label_upper[n]="ROOT";
      } 

      /*
       * Check to see if we should allow search on Views
       */

      String fl = attr.getValue(SEARCH_VIEWS_ATTR);
      if (fl != null) {
        if (fl.equals("false")) {
          menu[0].searchViews = false;
        } else {
          menu[0].searchViews = true;
        }
      }      

      /*
       * Check to see if we have a search themes attribute set
       */
 
      String st = attr.getValue(SEARCH_THEMES_ATTR);
      if (st != null) {
        menu[0].searchThemes = st.split(";");
      }

      /*
       * See if there is a default display mode specified.
       */

      if (attr.getValue(MENUMODE_ATTR) != null)  {
        if (attr.getValue(MENUMODE_ATTR).equals("hide")) {
          this.defaultDisplayMode = Menu.DISPLAY_MODE_HIDE;
        } else if (attr.getValue(MENUMODE_ATTR).equals("show")) {
          this.defaultDisplayMode = Menu.DISPLAY_MODE_SHOW;
        }   
      }
      

    /*
     * Anything else causes an error
     */

    } else {
      if (debugMode) {
        System.out.println(ERRMSG_UNRECOGNIZED_START_ELEMENT + qname);
      }
      throw new SAXException(ERRMSG_UNRECOGNIZED_START_ELEMENT +  qname); 
    }
  }

  /*
   * Process the end of an element
   *
   * We pop off the the element in the elementType stack to keep track of where we are.
   */

  public void endElement ( String uri,
                           String localName,
                           String qname ) throws SAXException
  {
    if (debugMode) {
      System.out.println(handlerName + ":  End element \"" + qname + "\".");
    }

    /*
     * When we close a Node element, we take all of the current Views that are defined for
     * it and insert them to the appropriate menu entry.  We then clear out the view array. so
     * that we dont have stray views later and to help out the garbage collector.
     */

    if (qname.equals(NODE_NAME)) {
      depth--;
      menuNdx--;
      for (int n = 0; n < viewNdx; n++) {
        menu[menuNdx].view.add(view[n]); 
        this.view[n] = null;
      }
      viewNdx = 0; 

    /* 
     * When we encounter the end of a View element, all nescessary work has already been done.
     */
  
    } else if (qname.equals(VIEW_NAME)) {
      depth--;

    /*
     * When we encounter the end of a Description element, all nescessary work has already
     * been done.
     */

    } else if (qname.equals(DESCRIPTION_NAME)) {
      depth--;

    /*
     * When we encounter the end of a Display element, we need to move the string to the
     * appropriate component so that it is capture in the menu.  This component is the parent
     * of the Display element and is allowed to be a Node, View, or an Element.
     */

    } else if (qname.equals(DISPLAY_NAME)) {
      depth--;
      String curtxt = this.currentText.toString();
      if (elementType[depth - 1] == NODE_ELEMENT) {
        this.menu[menuNdx - 1].label[elementLanguage[depth]] = curtxt;
        this.menu[menuNdx - 1].label_upper[elementLanguage[depth]] = curtxt.toUpperCase();
      } else if (elementType[depth - 1] == VIEW_ELEMENT) {
        this.view[viewNdx - 1].label[elementLanguage[depth]] = curtxt;
        this.view[viewNdx - 1].label_upper[elementLanguage[depth]] = curtxt.toUpperCase();
      } else if (elementType[depth - 1] == DESCRIPTION_ELEMENT) {
        this.view[viewNdx - 1].description[elementLanguage[depth]] = curtxt;
      }
      this.currentText = null;

    /*
     * Nothing to be done here since we build up the overall Menu object as we acounter
     * elements in the configuration file.
     */

    } else if (qname.equals(MENU_NAME)) {
      depth--;

    } else {
      if (debugMode) {
        System.out.println(ERRMSG_UNRECOGNIZED_END_ELEMENT + qname);
      }
      throw new SAXException(ERRMSG_UNRECOGNIZED_END_ELEMENT +  qname); 
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
    if (this.currentText != null) {
      this.currentText.append(ch,start,length);
    }
  }

  /*
   * Simply return the Menu object we have build up from the XML text.
   */

  public Menu getMenu()
  {
    return menu[0];
  }
}


 
  
