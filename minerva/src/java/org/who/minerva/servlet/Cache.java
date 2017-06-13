/*
 * (c) 2010, World Health Organization
 *
 * $Id$
 * $HeadURL$
 */

package org.who.minerva.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.HashMap;
import java.util.Vector;
import java.util.StringTokenizer;
import java.util.Calendar;
import java.util.Set;
import java.util.Enumeration;
import java.security.*;
import org.apache.log4j.Logger;

import net.sf.saxon.s9api.*;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.ErrorListener;
import javax.xml.transform.TransformerException;




public class Cache {

  private static Logger logger = Logger.getLogger(Cache.class);

  /*
   * Location of the cache directory
   */

  private String cacheDir = null;
  
  /*
   * number of milliseconds to store cached data
   */

  private int duration = 0;

  private static final String _MSG_MISSING_KEY_OR_CACHE_DIR = "Missing key or cache directory";
  private static final String _MSG_SUCCESFUL_DELETION = "Successful deletion of cache file ";
  private static final String _MSG_FAILED_DELETION = "Failed deletion of cache file ";
  private static final String _MSG_CACHE_FILE_EXPIRED = "Cache file expired ";
  private static final String _MSG_USING_CACHE_FILE = "Retrieving file from cache ";

  private static final String _MSG_SUCCESSFUL_CACHE_DELETION = "Successful deletion of cache directory ";
  private static final String _MSG_FAILED_CACHE_DELETION = "Failed deletion of cache directory ";

  /*
   * Constructor - you must supply the location of the cache directory,
   * and the duration in seconds for which an XML file can remain in the 
   * cache.
   */

  Cache ( String dir, int dur ) 
  {
    cacheDir = new String(dir);
    duration = dur;
  }

  /*
   * Clear the cache
   */

  private void _deleteCache ( File f ) 
  {
    if (f.isDirectory()) {
      for (File c : f.listFiles()) {
        _deleteCache(c);
      }
    }
    f.delete();
  }
 
  public void clear() 
  {
    File f = new File(cacheDir);
    try {
      _deleteCache(f);
      logger.debug(_MSG_SUCCESSFUL_CACHE_DELETION + cacheDir);
    } catch (Exception e) {
      logger.debug(_MSG_FAILED_CACHE_DELETION + cacheDir);
      logger.error(e.getMessage());
    }
  }

  /*
   *  Write a string to a file.
   */

  public boolean writeFile (String pathName, StringBuffer xml )
  {
    return writeFile(pathName,xml.toString());
  }

  public boolean writeFile (String pathName, String xml )
  {
    boolean res = false;
    try {
      File f = new File(pathName.substring(0,pathName.lastIndexOf("/")));
      f.mkdirs();
      BufferedWriter writer = new BufferedWriter(new FileWriter(pathName));
      writer.write(xml);
      writer.close();
      res = true;
    } catch (Exception e) {
      logger.error(e.getMessage());
    }
    return res;
  } 

  /*
   *  Read a file to a StringBuffer
   */

  public StringBuffer readFile ( String pathName ) 
  {
    int bufSize = 4096;
    StringBuffer data = new StringBuffer();
    try {
      BufferedReader reader = new BufferedReader(new FileReader(pathName));
      char[] buf = new char[bufSize];
      int numRead = 0;
      while ((numRead = reader.read(buf)) != -1) {
        data.append(buf,0,numRead);
      }
      reader.close();
    } catch (Exception e) {
      data = null;
      logger.error(e.getMessage());
    }
    return data;
  }

  /*
   * Generate the cache key for the XML file
   */


  public String mkKey ( String theme,
                        String node,
                        String vid,
                        String showonly,
                        String lang,
                        int display_mode )
  {
    StringBuffer keyStrBuf = new StringBuffer();
    if ((theme != null) && (!theme.equals("")))  {
      keyStrBuf.append("theme=" + theme);
    }
    if ((node != null)  && (!node.equals(""))) {
      keyStrBuf.append("&node=" + node);
    }
    if ((vid != null) && (!vid.equals(""))) {
      keyStrBuf.append("&vid=" + vid);
    }
    if ((showonly != null) && (!showonly.equals(""))) {
      keyStrBuf.append("&showonly=" + showonly);
    }
    if ((lang != null) && (!lang.equals(""))) {
      keyStrBuf.append("&lang=" + lang);
    }
    keyStrBuf.append("&display_mode=" + Integer.toString(display_mode));
    String key = null; 
    String keyStr = keyStrBuf.toString();
    try {
      MessageDigest md = MessageDigest.getInstance("MD5");
      byte[] digest = md.digest(keyStr.getBytes("UTF-8"));
      StringBuffer keyBuf = new StringBuffer(); 
      for (byte b: digest) {
        keyBuf.append(Integer.toHexString((int)(b & 0xff)));
      }
      key = keyBuf.toString();
    } catch (Exception e) {
      logger.error(e.getMessage());
    }
    if (logger.isDebugEnabled()) {
      logger.debug("Generated key for " + keyStr + " = " + key);
    }
    return key;
  }

  /*
   * Create the filename for the specified key
   */

  private String mkPathName ( String key ) 
  {
    String pathName = null;
    if ((key != null) && (cacheDir != null)) {
      StringBuffer pathNameBuf = new StringBuffer();
      pathNameBuf.append(cacheDir);
      pathNameBuf.append("/");
      pathNameBuf.append(key.substring(0,2));
      pathNameBuf.append("/");
      pathNameBuf.append(key.substring(2,4));
      pathNameBuf.append("/");
      pathNameBuf.append(key.substring(4));
      pathName = pathNameBuf.toString();
      if (logger.isDebugEnabled()) {
        logger.debug("Generated pathname for key " + key + " = " + pathName);
      }
    } else {
      logger.error(_MSG_MISSING_KEY_OR_CACHE_DIR);
    }
    return pathName;
  }
  
  /*
   * The get functions are used to retreive a file from the cache.
   * They've been split up so that a calling process can have full
   * control of the caching behaviour by pulling out the cache key
   * and the filename associate with the cache key
   */
 
  
  /*
   * This is the basic call for retreiving files that are
   * potentially the result of an XSLT transformation
   */

  public StringBuffer get ( String theme,
                            String node,
                            String vid,
                            String showonly,
                            String lang ,
                            int display_mode)
  {
    String key = mkKey(theme,node,vid,showonly,lang,display_mode);
    return getByKey(key);
  }

  public StringBuffer getByKey ( String key ) 
  {
    String pathName = mkPathName(key);
    return getByPathName(pathName);
  }

  public StringBuffer getByPathName ( String pathName )
  {
    StringBuffer xml = null;
    if (pathName != null) {
      File f = new File(pathName);
      long lastModified = f.lastModified();
      if (lastModified > 0) {
        Calendar cal = Calendar.getInstance();
        long now = cal.getTimeInMillis();
        if ((now - lastModified) < (duration * 1000)) {
          logger.debug(_MSG_USING_CACHE_FILE + pathName);
          xml = readFile(pathName);
        } else {
          logger.debug(_MSG_CACHE_FILE_EXPIRED + pathName);
          if (f.delete()) {
            logger.debug(_MSG_SUCCESFUL_DELETION + pathName);
          } else {
            logger.error(_MSG_FAILED_DELETION + pathName);
          } 
        }
      } 
    }
    return xml;
  }

  /* 
   * Returns number of milliseconds since corresponding file was last modified.
   * if the file does not exists, or there is some sort of error, a value of 0L
   * is returned.
   */

  public long getKeyLastModified ( String key ) 
  {
    String pathName = mkPathName(key);
    File f = new File(pathName); 
    return f.lastModified();
  }


  /*
   * Returns true if there is an entry in the cache and it has not yet expired,
   * false otherwise.
   */

  public boolean isKeyValid ( String key )
  {
    boolean res = false;
    long lm = getKeyLastModified(key);
    if (lm > 0) {
      Calendar cal = Calendar.getInstance();
      long now = cal.getTimeInMillis();
      if ((now - lm) < (duration * 1000)) {
        res = true;
      }
    } 
    return res;
  }


  public boolean put ( String theme,
                       String node,
                       String vid,
                       String showonly,
                       String lang,
                       int display_mode,
                       StringBuffer txt )
  {
    String key = mkKey(theme,node,vid,showonly,lang,display_mode);
    return putByKey(key,txt);
  }

  public boolean putByKey ( String key, StringBuffer xml )
  {
    String pathName = mkPathName(key);
    return putByPathName(pathName,xml);
  }

  public boolean putByPathName ( String pathName, StringBuffer xml )
  {
    boolean res = false;
    if ((pathName != null) && (xml != null)) {
      res = writeFile(pathName,xml); 
    }
    return res;
  }

}
