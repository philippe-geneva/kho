/*
 * 
 *
 *
 */

 

var GHOClient = function() 
{
  this.container = null;
  console.log("GHOClient object instantiated");
}



/*
 *  
 */

GHOClient.prototype.show = function ( url , div )
{
  console.log("Show \"" + url + "\" in " + div);
  var e = document.getElementById(div);
  if (e != null) {
    e.innerHTML = "Loading...";
  }
}

/*
 *  
 *
 */

GHOClient.prototype.activate = function ( aDiv , type )
{
  this.container = aDiv;
  if ((type == null) || (type == "crosstable")) {
    this.activateCrosstable();
  }
}

/*
 *
 *
 */

GHOClient.prototype.activateCrosstable = function ()
{
  var e = document.getElementById(this.container);
  if (e == null) {
    throw "DIV " + this.container + " not found."
  }
  e.innerHTML = "<div id=\"gho_client\"></div>\n" +
                "<div id=\"crosstable_filter_container\"></div>\n";
  f = document.getElementById("gho_client");

  // Encapsulate the table into a div which we will use to set the width
  // to a fixed value.  This will allow us to overlay clones of the table
  // to form the horizontal and vertical axes without automtically resizing
  // the table as we resize the divs that show these axes

  f.innerHTML = "<div id=\"crosstable\" class=\"noselect\">" +
                generateCrosstableHtml(crosstable.Crosstable) +
                "</div>\n";
  activateCrossTable("gho_client",crosstable);
  activateCrosstableFilter("crosstable_filter_container");

  // Resize the containing div so that the containing page displays correctly.

  var xt = document.getElementById("crosstable");
  var xtc = document.getElementById("crosstable_controls");
  var xgho = document.getElementById(global.container);
  e.parentElement.style.height = ( xt.clientHeight + xtc.clientHeight + xgho.offsetTop) + "px";
}

/*
 * 
 *
 *
 */

function window_onscroll()
{
  var xc = document.getElementById("gho_client");
  // If we dont have the gho_client div yet, then there's nothing to scroll, so skip
  // all of this
  if (xc != null) {
    var cc = document.getElementById("crosstable_controls");
    var cha = document.getElementById("crosstable_horizontal_axis");
    var cpv = document.getElementById("crosstable_pivotcell");
    var ar = document.getElementById("arrow_right");
    var al = document.getElementById("arrow_left");
    var xt = document.getElementById("crosstable");
    var r_xt = xt.getBoundingClientRect();
    var r_xc = xc.getBoundingClientRect();
    var r_cc = cc.getBoundingClientRect();
    var r_cha = cha.getBoundingClientRect();

    // Position the horizontal scroll arrows so that they appear centered between
    // the bottom of the horizontal axis, and the bottom edge of the table, if
    // visible, or the bottom of the viewport if the table extends beyond it.
    // Note that the position attribute of the arrows is always "fixed" (it is set
    // in CSS)
  
    var h =  window.innerHeight ||
             document.documentElement.clientHeight ||
             document.body.clientHeight;
    var bottom = Math.min(r_xt.bottom,(h-r_xt.top),h);

    ar.style.top = (r_cha.top + Math.max((bottom - ar.clientHeight)/2,0)) + "px";
    al.style.top = (r_cha.top + Math.max((bottom - al.clientHeight)/2,0)) + "px";
  

    if (r_cc.top < 0) {
      cha.style.position = "fixed";
      cpv.style.position = "fixed";
      cc.style.position = "fixed";
    } else if (r_cc.top < r_xc.top) {
      cha.style.position = "absolute";
      cpv.style.position = "absolute";
      cc.style.position = "absolute";
    } 
    if (r_xt.bottom < (cc.clientHeight + cha.clientHeight)) {
      var new_top = (r_xt.bottom - cc.clientHeight - cha.clientHeight) + "px";
      cc.style.top = new_top;
      cha.style.top = new_top;
      cpv.style.top = new_top;
    } else {
      cc.style.top = "0px";
      cha.style.top = cc.clientHeight + "px";  
      cpv.style.top = cc.clientHeight + "px";  
    }
  }
}

/*
 *
 *
 *
 */

var global = {
  container: null,
  redraw_pid: null,
  redraw_interval: 1000,
  gho: null
};

/*
 *  
 *
 *
 */


function window_onresize() {
  if (global.redraw_pid == null) {
    console.log("pending resize");
    global.redraw_pid = setInterval(function() {
      console.log ("resizing");
      clearInterval(global.redraw_pid);
      global.gho.activate(global.container);
      global.redraw_pid = null;
    },global.redraw_interval);
  }
}



function ghoclient(aDiv) {
  if (aDiv == null) {
    aDiv = "gho_content";
  }
  global.container = aDiv;
  global.gho = new GHOClient;
  global.gho.activate(global.container);
}



/*
 * Adding the required components to fully render the crosstables (javascript + CSS
 * files) so that they are loaded by the browser
 */

window.addEventListener("scroll",window_onscroll);
window.addEventListener("resize",window_onresize);
window.addEventListener("load",function(){ghoclient("GHOClient")});
var head = document.getElementsByTagName("head")[0];
var link = null;
link = document.createElement('link');
link.rel = "stylesheet";
link.type = "text/css";
link.href = "css/crosstableClient.css";
head.appendChild(link);
link = document.createElement('link');
link.rel = "stylesheet";
link.type = "text/css";
link.href = "css/crosstable.css";
head.appendChild(link);
link = document.createElement("script");
link.type = "text/javascript";
link.src = "js/Blob.js";
head.appendChild(link);
link = document.createElement("script");
link.type = "text/javascript";
link.src = "js/FileSaver.js";
head.appendChild(link);
link = document.createElement("script");
link.type = "text/javascript";
link.src = "js/crosstable.js";
head.appendChild(link);

