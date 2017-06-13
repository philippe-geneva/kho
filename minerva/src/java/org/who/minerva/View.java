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
import org.who.minerva.Utility;
import org.who.minerva.Menu;


public class View {

  public String id;
  public String[] label;
  public String[] label_upper; // for searching
  public boolean hidden;
  public String[] description;
  public String URL;
  public int type;
  public int display_mode;   // Default display mode for the menu when showing the
                             // corresponding View.

  public static int UNKNOWN = 0;
  public static int EMBEDDED = 1;
  public static int BUTTON = 2;
  public static int EXTERNAL = 3;
  public static int DIRECT = 4;

  public static String STR_EMBEDDED = "embedded";
  public static String STR_BUTTON = "button";
  public static String STR_EXTERNAL = "external";
  public static String STR_DIRECT = "direct";

  /*
   *
   */

  public View ( String id,
                String type,
                String URL,
                int display_mode,
                boolean hidden )
  {
    this(id,parseViewType(type),null,URL,null,display_mode,hidden);
  }

  /*
   *
   */

  public View ( String id,
                int type,
                String label,
                String URL,
                String description, 
                int display_mode,
                boolean hidden )
  {
    this.id = id;
    this.hidden = hidden;
    this.display_mode = display_mode; // when set to true, the menu will be initially
                                      // collapsed when it is displayed (the user can
                                      // uncollapse it using a UI control.
    String newURL = URL;

/*
 * This code stub is used to add an API key to the URL - This is a work in 
 * progress, I dont know when it will get completed (or if it will actually be
 * used) so it is left here commented out rather than deleted.
 */
/*
    if ((URL != null) && 
        (URL.indexOf("athena") > -1)) {
      int ndx = URL.indexOf("?");
      if (ndx > -1) {
        newURL = URL.substring(0,ndx) + "?apikey=abcdefg";
        if (ndx < (URL.length() - 1)) {
          // Dont use the ampersand XML entity or character code here, the string will
          // be re-encoded when it is rendered back to XML.
          newURL += "&" + URL.substring(ndx + 1);
        }
      } else {
        newURL = URL + "?apikey=abcdefg";
      }
    }
    this.URL = newURL;
*/

    this.URL = URL;
    this.label = new String[Menu.LANGUAGES];
    this.label_upper = new String[Menu.LANGUAGES];
    this.description = new String[Menu.LANGUAGES];
    for (int n = 0; n < Menu.LANGUAGES; n++) {
      this.label[n] = label;
      if (label != null) {
        this.label_upper[n] = label.toUpperCase();
      }
      this.description[n] = description;
    }
    this.type = type;
  } 


  /*
   * 
   */
  public static int parseViewType ( String s )
  {
    int viewType = View.EMBEDDED;
    if (s != null) {
      if (s.equals(View.STR_EMBEDDED)) {
        viewType = View.EMBEDDED;
      } else if (s.equals(View.STR_BUTTON)) {
        viewType = View.BUTTON;
      } else if (s.equals(View.STR_EXTERNAL)) {
        viewType = View.EXTERNAL;
      } else if (s.equals(View.STR_DIRECT)) {
        viewType = View.DIRECT;
      }
    }
    return viewType;
  }

  /*
   *
   */

  public String renderToXML ( boolean selected, int lang ) 
  { 
    return renderToXML(selected,lang,null);
  }

  public String renderToXML ( boolean selected, int lang , String passthroughParameters) 
  {
    StringBuffer sb = new StringBuffer();

    sb.append("<View id=\"" + this.id + "\"");
    if (this.URL != null) {
      sb.append(" URL=\"" + Utility.makeWebSafe(this.URL));
      if (passthroughParameters != null) {
        sb.append(this.URL.contains("?")?"&amp;":"?");
        sb.append(passthroughParameters);
      }
      sb.append("\"");
    }
    sb.append(" type=\"");
    if (this.type == View.EMBEDDED) {
      sb.append(View.STR_EMBEDDED);
    } else if (this.type == View.BUTTON) {
      sb.append(View.STR_BUTTON);
    } else if (this.type == View.DIRECT) {
      sb.append(View.STR_DIRECT);
    } else {
      sb.append(View.STR_EXTERNAL);
    }
    sb.append("\"");
    if (this.display_mode == Menu.DISPLAY_MODE_HIDE) {
      sb.append(" menu=\"hide\"");
    }
    if (this.hidden) {
      sb.append(" hide=\"1\"");
    }
    if (selected) {
      sb.append(" selected=\"1\"");
    }
    sb.append(">\n");
    if (this.description != null) {

      /*
       * Find which description string to use.  Note that if we _dont_ have
       * the specified language and a default string is not available, we will not
       * show the usual "text not available" message because the description is
       * optional.
       */

      String lbl = this.description[lang];
      int lbl_lang = lang;
      if (lbl == null) {
        lbl = this.description[Menu.DEFAULT_LANGUAGE];
        lbl_lang = Menu.DEFAULT_LANGUAGE;
      } 
    
      sb.append("<Description><Display lang=\"" + Menu.languageCode(lbl_lang) + "\">" + Utility.makeWebSafe(lbl) + "</Display></Description>\n");
    }
    if (this.label != null) {
     
      /* 
       * Find which display label to use, if we dont have the specified language or
       * the default language we will output "text not available". (The view Display
       * string is not optional)
       */

      String lbl = this.label[lang];
      int lbl_lang = lang;
      if (lbl == null) {
        lbl = this.label[Menu.DEFAULT_LANGUAGE];
        lbl_lang = Menu.DEFAULT_LANGUAGE;
      } 
      if (lbl == null) {
        lbl = "text not available";
        lbl_lang = Menu.ENGLISH;
      }
      sb.append("<Display lang=\"" + Menu.languageCode(lbl_lang) + "\">" + Utility.makeWebSafe(lbl) + "</Display>\n");
    }
    sb.append("</View>\n");
    return sb.toString();
  }

}
