/*
 * minerva.js
 */

/*
 * trim(str)
 *
 * Removes leading and trailing whitespaces from the specified string
 */



var currentViewTitle = "";

function trim(s) {
  return s.replace(/^[\s\r\n]*/g,'').replace(/[\s\r\n]*$/g,'');
}

/*
 *
 */

function divUpdate(aDivId,iframe) {
  var aDiv = document.getElementById(aDivId);
  aDiv.innerHTML = iframe.contentWindow.document.body.innerHTML;
}

/*
 * Used to set HTML text in the specified "zone" div (the user interface
 * has a preset number of zones to inject data into for display.
 */

function setZoneHTML(zone,html) 
{
  var e = document.getElementById("zone_" + zone);
  e.innerHTML = html;
}

/*
 * Used to explicitly set some HTML in the iframe used to display content for a data view
 */

function setContentIFrameHTML( s ) 
{
  var e = document.getElementById("zone_5");
  var i = document.getElementById("content_iframe");
  setZoneHTML(5,s);
  e.style.display = "block";
  i.src = "about:blank";
  try {
    i.contentWindow.document.body.innerHTML = "";
  } catch (err) {
    // do nothing
  }
//  i.contentWindow.document.body.innerHTML = s;
}

/*
 * Used to explicitly set the src URL in the iframe used to display content for a data view
 */

function setContentIFrameSrc ( s ) 
{
  var i = document.getElementById("content_iframe");
  i.src = s;
}


/*
 * this is used to dynamically resize the iframe holding the GHO data content
 * It avoids having extra scrollbars appear.  If we're holding something from another 
 * domain in the iFrame, then trying to access the document object will cause an 
 * Exception, in this case we simply hardwire the size to 650.
 */

function resizeMe ( i ) 
{
  var h = 0;
  try {
    h = i.contentWindow.document.body.scrollHeight;
  } catch (err) {
    h = 650;
  }
  i.style.height = h + "px";
  if (i.src != "about:blank") {
    var e = document.getElementById("zone_5");
    e.style.display = "none";
  }
}

/*
 * This function is used to display the content associated with 
 * a view (indexed position n) in the views array.
 */

function showViewByIndex(n) {
  setContentIFrameHTML("<br/><b>Loading content...</b><br /><br />");
  if ((n >= 0) && (n < views.length)) {
    if (views[n].type == "external") {
      setContentIFrameHTML("<h2>External content</h2>\
This content is provided from a WHO source other than the Global Health Observatory system. \
The link below will open a new window containing the requested resource.\
<ul class=\"list_dash\">\
<li><a class=\"link_external\" target=\"_new\" href=\"" + views[n].URL + "\">External content</a></li>\
</ul>");
    } else if (views[n].type == "embedded") {

      /*
       * Legacy support for the old region parameter.  If the parameter has been specified
       * and we are doing a query against the Athena web service, we add the region code
       * to the filter when we are looking up data for all countries.  Because we're also
       * using the WHO Region code to identify our member states in a quick and easy way, we
       * replace any of the preset REGION filters with the region specific one
       *
       * The EU region code is a special case that is used to support the GISAH European Union
       * system
       */
 
      if ((regionCode != null) && (views[n].URL.search("COUNTRY:*") >= 0)) {
        var newUrl = views[n].URL;
        newUrl = newUrl.replace(/REGION:[A-Z]*[;]*/g,"");
        if (regionCode == "EU") {
          newUrl = newUrl.replace(/COUNTRY:\*[;]*/g,"");
          newUrl = newUrl.replace("filter=","filter=COUNTRY:AUT;COUNTRY:BEL;COUNTRY:BGR;COUNTRY:CYP;COUNTRY:CZE;COUNTRY:DEU;COUNTRY:DNK;COUNTRY:EST;COUNTRY:ESP;COUNTRY:FIN;COUNTRY:FRA;COUNTRY:GBR;COUNTRY:GRC;COUNTRY:HUN;COUNTRY:IRL;COUNTRY:ITA;COUNTRY:LUX;COUNTRY:LTU;COUNTRY:LVA;COUNTRY:MLT;COUNTRY:NLD;COUNTRY:POL;COUNTRY:PRT;COUNTRY:ROU;COUNTRY:SWE;COUNTRY:SVN;COUNTRY:SVK;");
        } else {
          newUrl = newUrl.replace("filter=","filter=REGION:" + regionCode + ";"); 
        }
        setContentIFrameSrc(newUrl);
      } else {
        setContentIFrameSrc(views[n].URL);
      }
    } else {
      alert("Unrecognized view type \"" + views[n].type + "\" for VID " + views[n].vid);
    } 

    /*
     * Set the information links for the view
     */
    updateInfoZone(theme,n); 
    var infoLinks = "";

    if ('citation' in views[n]) {
      infoLinks = infoLinks + "<a href=\"#\" onclick=\"showInfoZone('infoCitation');return false\">Citation</a> | ";
    }
    /*
     * Note the wikiURL is set to the STRING  "null" when the parameter has not been set
     */
    if (wikiURL != "null") {
      infoLinks = infoLinks + "<a href=\"#\" onclick=\"showInfoZone('infoWiki');return false\">Notes and discussion</a> | ";
    }
    if (tracURL != "null") {
      infoLinks = infoLinks + "<a href=\"#\" onclick=\"showInfoZone('infoTickets');return false\">Tickets</a> | ";
    }
    infoLinks = infoLinks + "<a href=\"#\" onclick=\"showInfoZone('infoFeedback');return false\">Feedback</a> | ";
    infoLinks = infoLinks + "<a href=\"#\" onclick=\"showInfoZone('infoShare');return false\">Share this view</a>";
    infoLinks +=  "";
    setZoneHTML(3,infoLinks);
  }
  return false;
}

/*
 * This is used to hide the div that holds the feedback, share, and citation information
 */

function hideInfoZone () 
{
  var e = document.getElementById("infoBox");
  e.style.display = "none";
}

/*
 * Used to show the div that holds the feedback, share, and citation information
 * All of the internal divs are hidden first, then only the specified one is
 * enabled prior to show the overall div. 
 */

function showInfoZone ( fld )
{
  var e = document.getElementById("infoFeedback");
  e.style.display = "none";
  e = document.getElementById("infoCitation");
  e.style.display = "none";
  e = document.getElementById("infoShare");
  e.style.display = "none";
  e = document.getElementById("infoWiki");
  e.style.display = "none";
  e = document.getElementById("infoTickets");
  e.style.display = "none";
  e = document.getElementById(fld);
  e.style.display = "block";
   e = document.getElementById("infoBox");
  e.style.display = "block";
}  

/*
 * Used to update the content for feedback, sharing, and citation.  This is 
 * called whenever the data view is changed
 */

function updateInfoZone ( t , ndx )
{
  /*
   * Update the share buttons
   */

  var permalink = publicURL + "?theme=" + t + "&vid=" + views[ndx].vid;
  if (region != null) {
    permalink += "&region=" + region;
  }
  var e = document.getElementById("infoSharePermaLink");
  e.innerHTML = "<b>Permalink:  </b>" + permalink.replace(/&/g,"&amp;");
  addthis.update('share','url', permalink);
  addthis.update('share','title',currentViewTitle + " (" + trim(views[ndx].display) + ")");

  /*
   * Update the feedback mailto
   */

  e = document.getElementById("infoFeedback");
  e.innerHTML = "Please use the link below to send us comments concerning this view:<br /><br /><a href=\"mailto:gho_info" + String.fromCharCode(64) + "who.int?subject=Comment%20on%20theme%20" + t + ",%20vid%20" + views[ndx].vid + "&body=" + publicURL + "%3Ftheme=" + t + "%26vid=" + views[ndx].vid + "%0D%0A%0D%0AComments:\">Send feedback</a>";

  /*
   * update the citation component
   */
  if ('citation' in views[ndx]) {
    e = document.getElementById("infoCitation");
    e.innerHTML = views[ndx].citation;
  }
 
  /*
   * update the wiki link,   Note that the way that Dokuwiki works, to ensure we're not
   * creating randomn namespaces because of embedded colons, we convert them to hyphens for
   * the page titles.  The javascritp version of wikiURL will always be set to the string
   * "null" when the parameter has not been defined in web.xml, a URL otherwise.
   */ 
  if (wikiURL != "null") {
    // var wikiLinkTitle = "VID " + views[ndx].vid + " - " + currentViewTitle;
    var wikiLinkTitle = "VID " + views[ndx].vid;
    wikiLinkTitle = wikiLinkTitle.replace(/ /g,"+").replace(/\:/g," -").replace(/\;/g,"%3B").replace(/&/g,"%26");
    var wikilink = wikiURL + "?id=gho:data:" + t + ":" + wikiLinkTitle;
    e = document.getElementById("infoWiki");
    e.innerHTML = "<b>wikilink:  </b><a href=\"" + wikilink + "\" target=\"_blank\">" + wikilink.replace(/&/g,"&amp;");
  }


  if (tracURL != "null") {
    e = document.getElementById("infoTickets");
    e.innerHTML = "<iframe style=\"width:100%;height:75px;overflow:hidden\" src=\"tickets.jsp?vid=" + views[ndx].vid + "&theme=" + t + "\"/>"
  }

}

/*
 * If a query paramet vid=XXX has been set, this method will emulate
 * the interaction that is required in order to get to that view and
 * will set the client up as if it had been clicked to. The idea is to
 * use the same code that would have been used if the user had navigated
 * to the requested view.
 */

function showViewByVid(vid) 
{
  var notFound = true; 
  for (n = 0; n < views.length; n++) {
    if (views[n].vid == vid) {
      e = document.getElementById(views[n].node);
      openMenuToNode(e);
      notFound = false;
      showView(e.childNodes[0],vid);  
      break;
    }
  }
  if (notFound) {
    setContentIFrameSrc("notfound.html");
  }
  return false;
}

/*
 * Open menu to the specified node ID.  If the menu is a leaf, also show the data that
 * is associated with it.  This function is specifically used for the case where a menu
 * node parameter has been specified in the Minerva URL.
 */

function openMenuToNodeId ( id )
{
  var n = document.getElementById(id);
  if (n != null) {
    if (n.className.search("leave") >= 0) {
      menuToggle(n.parentNode,null);
    }
    n.childNodes[0].click();
  }
}

/*
 * Expands menu nodes up to the specified node
 */

function openMenuToNode(node) 
{
  while (node.nodeName == "LI") {
    if (node.className == "node closed") {
      node.className = "node open";
    }
    node = node.parentNode.parentNode;
  }
}

/*
 * Used to expand or collapse menu entries when using
 * WHO corporate website CSS classes on li and ul elements
 */


var previousNodeToggled = null;
var previousNodeText = null;

function menuToggle(cobj,texturl) {
  if (previousNodeToggled != null) {
    obj = previousNodeToggled;
    while (obj.nodeName == "LI") {
      obj.className="node closed";
      if (obj.parentNode.className == "subnavigation") {
        break;
      }
      obj = obj.parentNode.parentNode;
    }
  }
 
  obj = cobj.parentNode;
  previousNodeToggled = obj;
  while (obj.nodeName == "LI") {
    obj.className = "node open";
    if (obj.parentNode.className == "subnavigation") {
      break;
    }
    obj = obj.parentNode.parentNode;
  }

  if (texturl != null) {
    showBlurb(texturl);
    previousNodeText = obj;
  } else {
    /*
     * If the node we clicked on is not below any previous text we have displayed,
     * we clear the text
     */

    clearText = true;
    if (previousNodeText != null) {
      while (obj.nodeName == "LI") {
        if (obj == previousNodeText) {
          clearText = false;
          break;
        }
        if (obj.parentNode.className == "subnavigation") {
          break;
        }
        obj = obj.parentNode.parentNode;
      } 

      if (clearText) {
        showBlurb(null);
      }
    }
  }
  return false;
}


function menuResetLeaf ( node ) 
{
  if (node.className == "leave selected") {
    node.className = "leave";
  }
}

/*
 * This function is used to show a text blurb (when one is specified) when a menu node is
 * opened
 */

function showBlurb ( url )
{
  setZoneHTML(3,"");
  setZoneHTML(2,"");
  setZoneHTML(1,"");
  if (url != null) {
    if (region != null) {
      setContentIFrameSrc(url.replace(/blurbs\//,"blurbs/" + region + "_"));
    } else {
      setContentIFrameSrc(url);
    }
  } else {
    setContentIFrameHTML("");
  }
}

/*
 * showView is used to setup up the display panel that is used to embed 
 * views showing GHO data tables and charts
 */

var previouslyClickedLeaf = null;

function showView(cobj,vid) 
{
  setZoneHTML(3,"");
  setZoneHTML(2,"");
  setZoneHTML(1,"");
  leftMenuUpdateControl();

  if (previouslyClickedLeaf != null) {
    menuResetLeaf(previouslyClickedLeaf);
  }
  previouslyClickedLeaf = cobj.parentNode;
  cobj.parentNode.className = "leave selected";
  /*
   * Create the heading string for the request view node, 
   */

  currentViewTitle = "";
  if (cobj.parentNode.parentNode.parentNode.nodeName == "LI") {
    currentViewTitle = trim(cobj.parentNode.parentNode.parentNode.firstChild.innerHTML) + ": ";
  }
  currentViewTitle = currentViewTitle + trim(cobj.innerHTML);
  setZoneHTML(1,"<h1>" + currentViewTitle + "</h1>");

  /*
   * Create the set of dropdown and button links for the view node
   */

  s = "<div class=\"field\"><label class=\"label\" for=\"viewSelect\">Showing </label><select id=\"viewSelect\" class=\"select slarge\" onchange=\"showViewByIndex(this.value)\">";
  buttons = "<fieldset class=\"buttonbar\"><ul>";
  showNdx = -1;
  vCount = 0;
  for (n = 0; n < views.length; n++) {
   if (views[n].node == cobj.parentNode.id) {
     if (vid != null) {
       if (views[n].vid == vid) {
         showNdx = n;
       }
     } else if (showNdx == -1) {
       showNdx = n;
     }
     vCount = vCount + 1;
     if (showNdx == n) {
       s = s + "<option value=\"" + n + "\" selected=\"selected\">" + views[n].display + "</option>\n";
     } else {
       if (!(('hide' in views[n]) && (views[n].hide == "1"))) {
         if (views[n].type == "button") {
           //buttons += "<li><input type=\"button\" class=\"submit\" onclick=\"javascript:window.open('" + views[n].URL + "','foo');\" value=\"" + views[n].display + "\" title=\"" + views[n].display + "\"/></li>";
           buttons += "<li><input type=\"button\" class=\"submit\" onclick=\"javascript:openViewInNewWindow(" + n + ");\" title=\"" + (('descr' in views[n])?views[n].descr:views[n].display) + "\" value=\"" + views[n].display + "\"/></li>";
         } else {
           s += "<option value=\"" + n + "\">" + views[n].display + "</option>\n";
         }
       }
     }
   }
  }
  if (buttons != "") {
    buttons = "<fieldset class=\"buttonbar\"><ul>" + buttons + "</ul></fieldset>";
  }
  s += "</select></field>";
  buttons += "</ul></fieldset>";

  /*
   * Output to the user.
   */

  if (vCount > 1) {
    setZoneHTML(1,"<h1>" + currentViewTitle + "</h1>\n<table width=\"100%\"><tr><td style=\"vertical-align:middle;\">" + s + "</td><td style=\"float:right;\">" + buttons + "</td><tr><td colspan=\"2\">&nbsp</td></tr></table>");
  }

  if (showNdx != -1) {
    showViewByIndex(showNdx);
  } else {
    setContentIFrameHTML("There are no views specified for this menu entry.");
  }

  return true;
}

function openViewInNewWindow ( vid ) 
{
  if ((vid > 0) && (vid < views.length)) {
    var myWin = window.open(views[vid].URL,"vid_" + vid);
    myWin.focus();
  }
}

/*
 * Left menu controls
 */

function leftMenuUpdateControl() 
{
  var e = document.getElementById("sidebar");
  var c = document.getElementById("menuControl");
  if (e.style.display == "block") {
    c.innerHTML = "<a href=\"#\" onclick=\"return leftMenuHide()\">Hide menu</a>";
  } else if (e.style.display == "none") {
    c.innerHTML = "<a href=\"#\" onclick=\"return leftMenuShow(1)\">Show menu</a>";
  } else if (e.style.display == "") {
    leftMenuShow(1);
  }
  return false;
}

function leftMenuClearControl()
{
  var e = document.getElementById("menuControl");
  e.innerHTML = "";
  return false;
}

function leftMenuShow(flag) 
{
  var e = document.getElementById("sidebar");
  var cntnt_frm = document.getElementById("content_iframe");
  var cntnt = document.getElementById("content");
  e.style.display = "block";
  if (flag == 1) {
    leftMenuUpdateControl();
    cntnt_frm.style.width = "750px";
    cntnt.style.width = "750px";
  } else {
    leftMenuClearControl();
  }
  return false;
}

function leftMenuHide()
{
  var cntnt_frm = document.getElementById("content_iframe");
  var cntnt = document.getElementById("content");
  var e = document.getElementById("sidebar");
  e.style.display = "none";
  leftMenuUpdateControl();
  cntnt_frm.style.width = "950px";
  cntnt.style.width = "950px";
  return false;
}


/*
 * This function is used to implement a legacy requirement from the old GHO to allow it
 * to show a single top level entry from the base menu to support programme specific 
 * "themes"
 *
 */

function menuShowOnly( nodeid ) 
{
  if ((nodeid != null) && (nodeid != "_mn_null")) {
    var yy = document.getElementById("subnavigation");
 //   var e = document.getElementById("subnavigation").getElementsByClassName("subnavigation");
    var e = document.getElementById("subnavigation").childNodes[1];
    if (e != null) {
      for (n = 0; n < e.childNodes.length; n++) {
        if ('id' in e.childNodes[n]) {
          if (e.childNodes[n].id != nodeid) {
            if ('style' in e.childNodes[n]) {
              e.childNodes[n].style.display = "none";
            } 
          } else {
            e.childNodes[n].childNodes[0].click();
          }
        } 
      }
    }
  }
}
