/*
 * (c) 2010, World Health Organization
 *
 * $Id$
 * $HeadURL$
 */

package org.who.minerva.servlet;

import java.io.Writer;
import java.io.BufferedWriter;
import java.io.OutputStreamWriter;
import java.io.FileWriter;
import java.io.FileOutputStream;
import java.io.File;
import java.util.Calendar;
import java.text.SimpleDateFormat;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.who.minerva.Utility;


public class CLFLog {

  private String logFile = null;
  private File myFile = null;
  private BufferedWriter writer = null;
  private static String EXTENSION = ".log";

  /** 
   * Creates a new CLFLog object with the specified filename.
   */

  public CLFLog ( String f ) 
  throws Exception
  {
    logFile = f + EXTENSION;
    myFile = new File(logFile);

    /*
     *  If this file already exists,  try to preserve it.
     */

    if (myFile.exists()) {
      try {
        myFile.renameTo(new File(f + "." + Utility.nowFilename() + EXTENSION));
      } catch (Exception e) {
        System.out.println(e.getMessage());
      }
      myFile = new File(logFile);
    }

    writer = new BufferedWriter(new FileWriter(logFile));
    writer.flush();
  }

  /** 
   * Flushes and closes the log file when the object is destroyed.
   */

  protected void finalize ()
  throws Throwable
  {
    if (writer != null) {
      try { 
        writer.flush();
      } catch (Exception e) {
      }
      writer.close();
      writer = null;
    }
  }

  /* 
   * Creates a current timestamp in the default CLF format
   */

  private String timestamp() 
  {
    Calendar cal = Calendar.getInstance();
    SimpleDateFormat df = new SimpleDateFormat("[d/MMM/yyyy:HH:mm:ssZ]");
    return df.format(cal.getTime());
  }

  /** 
   * Make an entry in the CLF log file.  For any parameter that cannot be provided,
   * simply substitute a null.
   * 
   * @param request The HTTP request object that you wish to log  
   */

  public void record ( HttpServletRequest request,
                       Integer status,
                       Integer bytes,
                       String apikey )
  {
    String forwarded_for = request.getHeader("X-Forwarded-For");
    String ipaddr = null;
    if (forwarded_for != null) {
      ipaddr = forwarded_for.split(",")[0];
    } else {
      ipaddr = request.getRemoteAddr();
    }
    record(ipaddr,
           apikey,
           request.getRemoteUser(),
           request.getPathInfo() +
           ((request.getQueryString() != null) ? ("?" + request.getQueryString()) : ""),
           status,
           bytes);
  }

  /** 
   * Make an entry in the CLF log file.  For any parameter that cannot be provided,
   * simply substitute a null.  Nulls will be output as a '-' character in the log file
   * If the log file has dissappeared (deleted, moved). it will automatically be 
   * regenerated.
   * 
   * @param remoteHost IP address of the remote (client) host
   * @param ident Identity of remote user as reported by IDENT protocol (RFC 1413)
   * @param authUser Authenticated user id
   * @param request The request
   * @param status The returned HTTP status code
   * @param bytes The number of bytes returned
   */

  public void record ( String remoteHost , 
                       String ident ,
                       String authUser ,
                       String request ,
                       Integer status , 
                       Integer bytes )
  {
    /*
     * If the original file is no longer present, close the writer and null it
     */
 
    if (!myFile.exists()) {
      try {
        writer.close();
      } catch (Exception e) {
        System.out.println(e.getMessage());
      } finally {
        writer = null;
      }
    }

    /*
     * If we dont have a writer anymore, try to regenerate the log file
     */

    if (writer == null ) {
      try {
        writer = new BufferedWriter(new FileWriter(logFile));
        writer.flush();
      } catch (Exception e) {
        System.out.println(e.getMessage());
      }
    }

    /*
     * put the entry in the log file
     */

    if (writer != null) {
      try {
        writer.write(((remoteHost != null) ? remoteHost : "-") + " " + 
                       ((ident != null) ? ident : "-") + " " +
                       ((authUser != null) ? authUser : "-") + " " +
                       this.timestamp() + " " +
                       ((request != null) ? ("\"" + request + "\""): "-") + " " +
                       ((status != null) ? status : "-") + " " +
                       ((bytes != null) ? bytes : "-") + 
                       "\n");
        writer.flush();
      } catch (Exception e) {
        System.out.println(e.getMessage());
      }
    }
  }  
}
