package org.who.minerva;

import java.io.*;
import java.lang.Integer;
import java.lang.String;
import java.lang.StringBuffer;
import java.util.Calendar;
import java.util.Date;
import java.text.SimpleDateFormat;
import org.apache.log4j.Logger;

public class Utility {

  private static Logger logger = Logger.getLogger(Utility.class); 
  
  /**
   *
   * A simple utility function that will create a string that can
   * be safely put into an XML document without fear of causing a 
   * parsing error
   */

  public static String makeWebSafe ( String s )
  {
    StringBuffer html = new StringBuffer("");
    if (s != null) {
      String sub;
      int cVal;
      for (int n = 0; n < s.length(); n++) {
        sub = s.substring(n,n+1);
        if (sub.matches("[a-zA-Z0-9 ]")) {
          html.append(sub);
        } else if (sub.matches("[\r\n\f]")) {
          html.append(" ");
        } else {
          html.append("&#");
          html.append(Integer.toString((int)sub.charAt(0)));
          html.append(";");
        }
      }
    }
    return html.toString();
  }

  /**
   *
   * Returns a current time stamp as a string representation, for
   * use in addeding a "time of generation" timestamp in an XML
   * representation
   */

  public static String now8601 () 
  {
    Calendar cal = Calendar.getInstance();
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    return df.format(cal.getTime());
  }

  /*
   * Return the current time stamp in datetime format so that it
   * can be dircetly used by MSSQL server or MySQL.
   */

  public static String nowDatetime ()
  {
    Calendar cal = Calendar.getInstance();
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd' 'HH:mm:ss'.0'");
    return df.format(cal.getTime());
  }

  /*
   * Return the current time stamp in a format that is suitable for
   * inclusion in a filename
   */

  public static String nowFilename ()
  {
    Calendar cal = Calendar.getInstance();
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd.HHmmss.SSSS");
    return df.format(cal.getTime());
  }

  /*
   *
   */

  public static boolean isDateOk( String s , boolean noFuture) 
  {
    boolean r = false;
    try {
      SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
      Date d = (Date) df.parse(s);
      if (noFuture) {
        Calendar cal = Calendar.getInstance();
        if (!d.after(cal.getTime())) {
          r = true;
        }
      } else {
        r = true;
      }
    } catch (Exception e) {
      /* Dont need to do anything, cant use the date */
    }
    return r; 
  }

}
