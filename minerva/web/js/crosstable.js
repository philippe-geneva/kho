
/*
 *
 */

/*
 * Disactivate the crosstable and restore it back to the original DIV containing HTML
 */

function disactivateCrossTable (divId)
{
  var e = document.getElementById("gho_client");
  e.innerHTML = "";
}

/*
 * divId is the name of the div that will contain the crosstable, and xtab is the
 * data structure with the crosstable information
 */

function activateCrossTable (divId, xtab)
{
  var gho_client = document.getElementById(divId);
  if (gho_client == null) {
    throw "Crosstable container \"" + divId + "\" div not found.";
  }

  var crosstable = document.getElementById("crosstable");
  if (crosstable == null) {
    throw "Source crosstable not found.";
  }

  /*
   * calculate the size of the bounding box that encompasses the pivot cells
  * The width and height are initially set to 1 and increased by 1 additional
  * pixel at every step to account for a one pixel border around the cell.
   */

  var pivotcell_width = 1;
  var pivotcell_height = 1;
  var pivotcell = document.getElementById("pivotcell");
  if (pivotcell != null) {
    pivotcell_height += pivotcell.clientHeight + 1;
  }
  for (var q = 0; q < 10; q++) {
    var pc = document.getElementById("pivotcell_" + q);
    if (pc != null) {
      pivotcell_width += pc.clientWidth + 1;
      if (q == 0) {
        pivotcell_height += pc.clientHeight + 1;
      }
    } else {
      break;
    }
  }

  crosstable.style.position = "absolute";
  crosstable.style.top = "0px";
  crosstable.style.backgroundColor = "#FFFFFF";
  crosstable.style.width = gho_client.clientWidth + "px"; 
  crosstable.firstChild.style.width = gho_client.clientWidth + "px"; 

  var controls = document.createElement("DIV");
  controls.id = "crosstable_controls";
  controls.className = "controls";
  controls.style.overflow = "hidden";
  controls.style.position = "absolute";
  controls.style.top = "0px";

  //var ctrl_html = "<a href=\"javascript:filterShow();\">filter table</a> | <a href=\"javascript:filterClear();filterApply();\">reset table</a> | <a href=\"javascript:mxtb_activate('" + divId + "')\">Mobile view</a>";
 // var ctrl_html = "<a href=\"javascript:filterShow();\">filter table</a> | <a href=\"javascript:filterClear();filterApply();\">reset table</a> | ";
  var ctrl_html = "<fieldset class=\"buttonbar\"><ul>";
  ctrl_html += "<li><a href=\"#\" onclick=\"filterShow()\">Filter table</a></li>";
  ctrl_html += "<li> | <li>";
  ctrl_html += "<li><a href=\"#\" onclick=\"filterClear();filterApply()\">Reset table</a></li>";
  ctrl_html += "<li> | <li>";

  ctrl_html += "<li>" + mkCompleteDownloadDropdown(xtab) + "</li>";
  ctrl_html += "<li> | <li>";
  if (BlobCheck()) {
    ctrl_html += "<li><select onchange=\"downloadData(this.value);this.selectedIndex=0;\">";
    ctrl_html += "<option selected=\"selected\" disabled=\"disabled\" value=\"\">Download this table</option>";
    ctrl_html += "<option value=\"csv\">CSV Crosstable</option>";
    ctrl_html += "<option value=\"xml\">Simplified XML</option>";
    ctrl_html += "<option value=\"json\">Simplified JSON</option>";
    ctrl_html += "</select></li>";

//    ctrl_html += " | <a class=\"control\" href=\"javascript:downloadData('csv')\">CSV table</a> | <a href=\"javascript:downloadData('xml')\">XML (simple)</a> | <a href=\"javascript:downloadData('json')\">JSON (simple)</a>";
  } else {
    ctrl_html += "Update your browser to the latest version to download filtered table data";
  }
  ctrl_html += "</ul></fieldset>";
  controls.innerHTML = ctrl_html;
  gho_client.appendChild(controls);

  crosstable.style.top = controls.clientHeight + "px";
  
  var crosstable_horizontal_axis = crosstable.cloneNode(true);
  crosstable_horizontal_axis.style.zIndex = 900;
  crosstable_horizontal_axis.id = "crosstable_horizontal_axis";
  crosstable_horizontal_axis.style.overflow = "hidden";
  crosstable_horizontal_axis.style.top = controls.clientHeight + "px";
  gho_client.appendChild(crosstable_horizontal_axis);

  var crosstable_vertical_axis = crosstable.cloneNode(true);
  crosstable_vertical_axis.style.zIndex = 900;
  crosstable_vertical_axis.id = "crosstable_vertical_axis";
  crosstable_vertical_axis.style.overflow = "hidden";
  crosstable_vertical_axis.style.top = controls.clientHeight + "px";
  gho_client.appendChild(crosstable_vertical_axis);

// Create the pivot cell for the table - this will be the top left
// corner - it doesnt move when the axes/table are scrolled
//
  var crosstable_pivotcell = crosstable.cloneNode(true);
  crosstable_pivotcell.id = "crosstable_pivotcell"
  crosstable_pivotcell.style.position = "absolute";
  crosstable_pivotcell.style.overflow = "hidden";
  crosstable_pivotcell.style.top = controls.clientHeight + "px";
  crosstable_pivotcell.style.zIndex = 1000;
  crosstable_pivotcell.style.width = pivotcell_width + "px";
  crosstable_pivotcell.style.height = pivotcell_height  + "px"; 
  gho_client.appendChild(crosstable_pivotcell);



  var viewHeight = gho_client.clientHeight;


// Construct the details box to show footnotes and additional
// metadata for a given fact. Height is fixed, but the width
// is variable based on available space.

  var detail = document.createElement("div");
  detail.style.height =  "200px";
  detail.style.width = (gho_client.clientWidth * 4 / 5) + "px";
  detail.id = "crosstable_detail";
  detail.style.overflowY = "hidden";
  detail.style.overflowX = "hidden";
  detail.style.position = "fixed";
  detail.style.zIndex = "3500";
  detail.style.display = "none";
  gho_client.appendChild(detail);

  /*
   * The width and height of the headers are increased by 2 pixels to also include
   * the borders
   */

  //crosstable.style.height = (gho_client.clientHeight - controls.clientHeight) + "px";
  crosstable.style.width = gho_client.clientWidth + "px";
  crosstable_pivotcell.style.height = pivotcell_height + "px";
  crosstable_pivotcell.style.width = pivotcell_width + "px";
  crosstable_horizontal_axis.style.height = pivotcell_height  + "px";
  crosstable_horizontal_axis.style.width = gho_client.clientWidth + "px";
  crosstable_vertical_axis.style.width = pivotcell_width + "px";
//  crosstable_vertical_axis.style.height = (gho_client.clientHeight - controls.clientHeight) + "px";

  // Create the navigation arrows that will allow the user to slide the table left 
  // and right.  The arrows will only appear when the mouse cursor is inside the 
  // crosstable.

  var right_arrow = document.createElement("DIV");
  right_arrow.id = "arrow_right";
  right_arrow.className = "scroll right";
  right_arrow.style.float = "right";
  right_arrow.style.left = (gho_client.clientWidth - 49) + "px";

  var left_arrow = document.createElement("DIV");
  left_arrow.id = "arrow_left";
  left_arrow.className = "scroll left";
  left_arrow.style.float = "left";
  //left_arrow.style.left = "inherit";

/*
  var arrows = document.createElement("DIV");
  arrows.id = "arrows";
  arrows.style.top = "300px";
  arrows.style.width = gho_client.clientWidth + "px";
  arrows.className = "scroll arrows";
  arrows.appendChild(left_arrow);
  arrows.appendChild(right_arrow);
  gho_client.appendChild(arrows);
*/
  gho_client.appendChild(left_arrow);
  gho_client.appendChild(right_arrow);

  // Position the horizontal scroll arrows so that they appear centered between 
  // the bottom of the horizontal axis, and the bottom edge of the table, if
  // visible, or the bottom of the viewport if the table extends beyond it.

  var h =  window.innerHeight ||
           document.documentElement.clientHeight ||
           document.body.clientHeight;
  var r_xt = crosstable.getBoundingClientRect(); 
  var r_cha = crosstable_horizontal_axis.getBoundingClientRect();
  var bottom = Math.min((r_xt.bottom),h);
//  var bottom = Math.min((r_xt.top + r_xt.y),h);
//  arrows.style.top = (top + Math.max((bottom - top - arrows.clientHeight)/2,0) ) + "px";
  left_arrow.style.top = (r_cha.top + Math.max((bottom - left_arrow.clientHeight)/2,0) ) + "px";
//  left_arrow.style.left = r_xt.x + "px";
  left_arrow.style.left = r_xt.left + "px";
  right_arrow.style.top = (r_cha.top + Math.max((bottom - right_arrow.clientHeight)/2,0) ) + "px";
  //right_arrow.style.left = (r_xt.x + r_xt.width - 49) + "px";
  right_arrow.style.left = (r_xt.right - 49) + "px";

  // Show the arrows when the mouse cursor is in the crosstable

  gho_client.onmouseover = function() {
    left_arrow.style.display = "block";
    right_arrow.style.display = "block";
  };

  gho_client.onmouseout = function() {
    left_arrow.style.display = "none";
    right_arrow.style.display = "none";
  };

  // Slide the cross table to the left when the user clicks and holds down
  // the mouse over the left arrow

  left_arrow.onmousedown = function() {
    var pid = setInterval(function() {
      var p = Math.max(0,crosstable.scrollLeft - 10);
      crosstable.scrollLeft = p;
      crosstable_horizontal_axis.scrollLeft = p;
     },25);
     left_arrow.onmouseup = function() {
       clearInterval(pid);
     }
  };

  // Slide the cross table to the right when the user clicks and holds down
  // the mouse over the right arrow

  right_arrow.onmousedown = function() {
    var pid = setInterval(function() {
      var p = Math.min(gho_client.clientWidth,crosstable.scrollLeft + 10);
      crosstable.scrollLeft = p;
      crosstable_horizontal_axis.scrollLeft = p;
    },25);
    right_arrow.onmouseup = function() {
      clearInterval(pid);
    }
  };

}

/*
 * Used to keep track of the last cell that was selected 
 */

var __last_cell = null;
var __last_code_ndx = null;


function showDetails ( v_ndx , h_ndx , code_ndx )
{
  var show_details = false;
  var cell = null;
  if (code_ndx == null) {
    cell = document.getElementById("_dc_" + v_ndx + "_" + h_ndx);
  }
  if ((cell != null) && (cell != __last_cell)) {
    show_details = true;
  }

  /*
   * First get the element object for the details pane. This should
   * always succeed so throw an exception if we dont find it.
   */

  var detail = document.getElementById("crosstable_detail");
  if (detail == null) {
    throw "Crosstable detail div not found";
  }

  /*
   * Add the class "selected" to the chosen data cell, if we have
   * a previously selected cell, we remove the "selected" class
   * name from it.
   */

  if (__last_cell != null) {
    var cn = __last_cell.className;
    if (cn != null) {
      __last_cell.className = cn.replace(/[ ]selected/g,"");
    }
    __last_cell = null;
  }
  
  /*
   * the variable str will hold the final HTML that will be displayed in the 
   * details div shown to the user for the selected data or header cell.  The
   * variable cell_name holds a name constructed for the selected cell based on its
   * context within the table's data matrix or header.  cell_name is ultimately
   * inserted into str.
   */

  var cell_content = "";
  var cell_name = "";

  if (code_ndx != null) {
    if (__last_code_ndx != code_ndx) {
      var code = crosstable.Crosstable.code[code_ndx];
      cell_name = code.disp;
      cell_content += "<table>" + 
                      "<tr><th>Definition</th><td>" + code.comment + "</td></tr>" + 
                      "</table>";
      __last_cell = null;
      __last_code_ndx = code_ndx;
      show_details = true;
    } else {
      show_details = false;
      __last_code_ndx = null;
    }
  }
 
  if ((code_ndx == null) && show_details) {

  /*
   * find the specified cell to highlight it
   */

    cell = document.getElementById("_dc_" + v_ndx + "_" + h_ndx);
    if (cell.className != null) {
      cell.className += " selected";
    } else {
      cell.className = "selected";
    }
    __last_cell = cell;
    __last_code_ndx = null;

  /*
   * Put the comment from the selected cell into the
   * details pane.
   */

  /*
   * This sequence generates a human readable name for the cell by 
   * identifying the display labels that correspond to the cell's horizontal
   * and vertial header locations.
   */

    for (var n = 0; n < crosstable.Crosstable.Vertical.layer.length; n++) {
      var codendx = crosstable.Crosstable.Vertical.header[v_ndx][n+1].codendx;
      if (codendx != 0) {
        if (cell_name != "") {
          cell_name += ", ";
        }
        cell_name += crosstable.Crosstable.code[codendx].disp;
      }
    }
    for (var n = 0; n < crosstable.Crosstable.Horizontal.layer.length; n++) {
      var codendx = crosstable.Crosstable.Horizontal.header[h_ndx][n+1].codendx;
      if (codendx != 0) {
        if (cell_name != "") {
          cell_name += ", ";
        }
        cell_name += crosstable.Crosstable.code[codendx].disp;
      }
    }
    cell_content += "<table>";
  
    /*
     * Now we make a series of table entries for each available value in the cell
     */

    var data_cell = crosstable.Crosstable.Matrix[v_ndx][h_ndx];
    for (var n = 0; n < data_cell.length; n++) { 
      if (data_cell.length > 1) {
        if (n == 0) {
          cell_content += "<tr><td colspan=\"3\">Please note that this cell contains " + data_cell.length + " distinct entries.</td></tr>";
        }
        cell_content += "<tr><th colspan=\"3\">Entry " + (n+1) + "</th></tr>";
      } 
      if (data_cell[n].comment != "") {
        cell_content += "<tr><th>&nbsp;</th><th>Comment:</th><td>" +  data_cell[n].comment + "</td></tr>";
      }
      if (data_cell[n].disp != "") {
        cell_content += "<tr><th>&nbsp;</th><th>Value:</th><td>" + data_cell[n].disp + "</td></tr>";
      }
      if (data_cell[n].detail != "") {
        cell_content += "<tr><th>&nbsp;</th><th>Details:</th><td>" + data_cell[n].detail + "</td></tr>";
      } 
      if (data_cell[n].effective != "") { 
        cell_content += "<tr><th>&nbsp;</th><th>Effective date:</th><td>" +  data_cell[n].effective + "</td></tr>";
      }
    }
    cell_content += "</table>"
  }

  /*
   * Calculate a new position for the details div, based on which cell was clicked by 
   * the user, and that cell's position (we dont want the div to cover up the cell
   */

  if (show_details) {
    var gho_client = document.getElementById("crosstable");
    var top_pos;
    if (cell == null) {
      top_pos = gho_client.clientHeight * 6 / 10;
    } else {
      top_pos = ((cell.offsetTop - gho_client.scrollTop) < (gho_client.clientHeight/2))?(gho_client.clientHeight * 6 / 10):(gho_client.clientHeight / 10);
    }
    // Display the content to the user

    detail.innerHTML = "<div style=\"height:20%\" class=\"popup_title\">" + cell_name + "</div>" + 
                       "<div style=\"overflow-y:auto;height:70%\">" + cell_content + "</div>"+ 
                       "<div style=\"position:absolute;bottom:0px;height:10%\" class=\"controls\"><a href=\"javascript:crosstableDetailHide()\">Close</a></div>";

    detail.style.display = "";

    //  Position the detail box in the middle of the browser window

    detail.style.left = (((window.innerWidth ||
                           document.documentElement.clientWidth ||
                           document.body.clientWidth) - detail.clientWidth)/2) + "px";
    detail.style.top = (((window.innerHeight ||
                          document.documentElement.clientHeight ||
                          document.body.clientHeight) - detail.clientHeight)/2) + "px";

  } else {
    detail.style.display = "none";
  }
}

function crosstableDetailHide() 
{
  document.getElementById("crosstable_detail").style.display = "none";
  
  // If the details popup was for a data cell, unselect the cell as well.

  if (__last_cell != null) {
    var cn = __last_cell.className;
    if (cn != null) {
      __last_cell.className = cn.replace(/[ ]selected/g,"");
    }
    __last_cell = null;
  }
}

/*
 *
 */

function X_activateCrosstable( aDiv )
{
  var e = document.getElementById(aDiv);
  if (e == null) {
    throw "DIV " + aDiv + " not found."
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
  activateCrossTable("gho_client");
  activateCrosstableFilter("crosstable_filter_container");

  // Resize the containing div so that the containing page displays correctly.
 
  var xt = document.getElementById("crosstable");
  var xtc = document.getElementById("crosstable_controls");
  e.parentElement.style.height = ( xt.clientHeight + xtc.clientHeight) + "px";

}


/*
 * Generate the HTML for the specified crosstable 
 *
 */

/*
 * For the given crosstable header, create an array of indices of columns/rows
 * that are intened to be shown (ie have not been filtered out)
 */

function getDisplayIndices ( hdr )
{
  var ndx_array = [];
  for (var n = 0; n < hdr.header.length; n++) {
    if (hdr.header[n][0].hide == 0) {
      ndx_array.push(n);
    } 
  }
  return ndx_array;
}


/*
 *
 */

function generateHeaderCellHtml ( xtab , codendx , colspan , rowspan, css_class )
{
  var url = xtab.code[codendx].url;
  var disp = xtab.code[codendx].disp;
  var comment = xtab.code[codendx].comment;
  var html = "<th";
  if (css_class != null) {
    html += " class=\"" + css_class + "\"";
  } 
  if (colspan > 1) {
    html += " colspan=\"" + colspan + "\"";
  }
  if (rowspan > 1) {
    html += " rowspan=\"" + rowspan + "\"";
  }
  html += ">";

  if (url != "") {
    html += "<span class=\"link\" onclick=\"window.open('" + url + "','_top')\">" + 
            disp + 
            "<span class=\"icon\"/>i</span>" +
            "</span>";
  } else if (comment != "") {
    html += "<span onclick=\"showDetails(null,null," + codendx + ")\">" + 
            disp + 
            "<span class=\"icon\"/>i</span>" +
            "</span>";
  } else {
    html += disp;
  }
  html += "</th>";
  return html;
}

/*
 * Generates the HTML for a data cell.
 */

function generateDataCellHtml ( xtab , v_ndx , h_ndx )
{
  var cell = xtab.Matrix[v_ndx][h_ndx];
  var html = "<td id=\"_dc_" + 
             v_ndx + "_" + h_ndx + 
             "\" onclick=\"showDetails(" + v_ndx + "," + h_ndx + ",null)\">";
  for (var n = 0; n < cell.length; n++) {
    if (n > 0) { 
      html += "<br />";
    }
  
    /*
     * If the cell value's state is neither "Published" nor "unspecified", append
     * the state to the value and surround it with a span to make it stand out.  Otherwise
     * simply output the value.
     */

    if ((cell[n].state != "unspecified") && (cell[n].state != "Published")) {
      html += "<span class=\"state\">" + cell[n].disp + " (" + cell[n].state + ")</span>";
    } else {
      html += cell[n].disp;
    }

    /*
     * If a comment is present, we put a visual indicator on the cell value
     */

    if (cell[n].comment != "") {
      html += "<span class=\"icon\">i</span>";
    }
  }

  html += "</td>";
  return html;
}

/*
 * Generate the specific code lists for all layers of the given axis
 *
 */

function generateFilterHtmlForAxis ( xtab , hdr )
{
  var html = "";
  // we intentionally want the counter from 1 to layer.length + 1 
  for (var m = 1; m <= hdr.layer.length; m++) {
    var filter = [];
    html += "<div style=\"display:none;\" class=\"cf_dim_list\" id=\"crosstable_filter_" + hdr.layer[m-1].dimndx + "\">\n";
    html += "<table>\n";
    for (var n = 0; n < hdr.header.length; n++) {
      var codendx = hdr.header[n][m].codendx;
      if (filter[codendx] == null) {
        filter[codendx] = xtab.code[codendx];
        html += "  <tr><td><input type=\"checkbox\" value=\"" + codendx + "\"></td><td>" +
                xtab.code[codendx].disp +
                "</td></tr>\n" ;
      }
    }
    html += "</table>\n";
    html += "</div>\n"
  }
  return html;
}

/*
 * 
 */

var FilterState = {
  "currentDim": null,
  "currentFilter": null
};

/*
 *
 */

function showFilterLayer ( me, ndx )
{
  if (FilterState.currentDim != null) {
    FilterState.currentDim.className = FilterState.currentDim.className.replace(/[ ]selected/g,"");
  } 
  if (FilterState.currentFilter != null) {
     FilterState.currentFilter.style.display = "none";
  }
  var e = document.getElementById("crosstable_filter_" + ndx);
  e.style.display = "";
  me.className += " selected";
  FilterState.currentDim = me;
  FilterState.currentFilter= e;
}

/*
 * Clear the filter settings in the crosstable
 */

function filterClearCrosstable ()
{

  hdr = crosstable.Crosstable.Horizontal.header;
  for (var n = 0; n < hdr.length; n++) {
    hdr[n][0].hide = 0;
  }
  hdr = crosstable.Crosstable.Vertical.header;
  for (var n = 0; n < hdr.length; n++) {
    hdr[n][0].hide = 0;
  }
  return;
}

/*
 * Clear the checkboxes in the user interface
 */

function filterClear ()
{
  filterClearCrosstable();
  var e = document.getElementById("cf_filters");
  if (e != null) {
    var cb = e.getElementsByTagName("input");
    if (cb != null) {
      for (var n = 0; n < cb.length; n++) {
        cb[n].checked = false;
      }
    }
  }
  return;
}

/*
 *
 */

function filterShow ()
{
  var e = document.getElementById("crosstable_filter_container");
  if (e != null) {
    e.style.display = "";
  }
}

/*
 *
 */

function filterHide ()
{
  var e = document.getElementById("crosstable_filter_container");
  if (e != null) {
    e.style.display = "none";
  }
}

/*
 * Apply the filters
 */

function filterApplyAxis ( xtab , axis ) 
{
  var run_filter = false;
  var ndxs = [];
  for (var n = 0; n < axis.layer.length; n++) {
    ndxs[n] = [];
    var e = document.getElementById("crosstable_filter_" + axis.layer[n].dimndx );
    inputs = e.getElementsByTagName("input");
    for (var m = 0; m < inputs.length; m++) {
      if (inputs[m].checked) {
        ndxs[n].push(parseInt(inputs[m].value,10));
        run_filter = true;
      }
    } 
  }
  if (run_filter) {
    var threshold = 0
    for (var n = 0; n < axis.layer.length; n++) {
      if (ndxs[n].length > 0) {
        threshold += 1;
      }
    } 
    for (var m = 0; m < axis.header.length; m++) {
      axis.header[m][0].hide = 1;
    }
    for (var m = 0; m < axis.header.length; m++) {
      var matching_count = 0;
      for (var n = 0; n < axis.layer.length; n++) {
        for (var p = 0; p < ndxs[n].length; p++) {
          if (axis.header[m][n+1].codendx == ndxs[n][p]) {
            matching_count += 1;
            break;
          }
        }
      }
      if (matching_count >= threshold) {
        axis.header[m][0].hide = 0;
      }    
    }  
  }
  filterHide();
  return;
}

/*
 *
 */

function filterApply(xtab) 
{
  /*
   * First we need to clear our the filter settings in the cross table so that
   * a previous run does not mangle this run.
   */
  filterClearCrosstable();
  var e = document.getElementById("gho_client");
  var xtab = crosstable.Crosstable;
  filterApplyAxis(xtab,xtab.Horizontal);
  filterApplyAxis(xtab,xtab.Vertical);
  var html = generateCrosstableHtml(xtab);
  e.innerHTML = "<div id=\"crosstable\" class=\"noselect\">" + html + "</div>";
  activateCrossTable('gho_client',crosstable);
  xt = document.getElementById("crosstable");
  xtc = document.getElementById("crosstable_controls");
  e.parentElement.style.height = ( xt.clientHeight + xtc.clientHeight) + "px";
}


/*
 * Makes the list of available filters for the axis - this is the
 * labels for the individuals layers that make up the axis
 */

function generateFilterHtmlForAxisList ( xtab , hdr )
{
  var html = "";
  
  for (var n = 0; n < hdr.layer.length; n++) {
    html += "<div class=\"cf_dim\" onclick=\"showFilterLayer(this," + hdr.layer[n].dimndx + ")\">";
    html += xtab.dimension[hdr.layer[n].dimndx].disp;
    html += "</div>\n" 
  }
  return html;
}

/*
 *
 */

function generateFilterHtml ( xtab )
{
  var html = "";
  html += "<div id=\"cf_main\" class=\"cf_main\">\n";
  html += "<div class=\"popup_title\">Available dimensions</div>\n";
  html += generateFilterHtmlForAxisList(xtab,xtab.Horizontal);
  html += generateFilterHtmlForAxisList(xtab,xtab.Vertical);
  html += "</div>\n";
  html += "<div id=\"cf_filters\" class=\"cf_filters\">";
  html += "<div class=\"popup_title\">Options</div>\n";
  html += generateFilterHtmlForAxis (xtab,xtab.Horizontal);
  html += generateFilterHtmlForAxis (xtab,xtab.Vertical);
  html += "</div>";
  html += "</div>";
  html += "<div id=\"cf_controls\" class=\"controls\">\n";
  html += "<a href=\"javascript:filterClear()\">Clear all</a> | ";
  html += "<a href=\"javascript:filterApply()\">Apply</a> | ";
  html += "<a href=\"javascript:filterHide()\">Cancel</a>";

  html += "</div>\n";
  return html;
}

/*
 * Activates the filter component of the crosstable.  The HTML text 
 * for the filter is generated from the crosstable javascript object.
 * The containing div is positioned centered on top of the crosstable
 * and set to display: none, with the first available filter dimension
 * already selected so that the user has something to look at when the
 * filter is opened (by clicking on the "filter" link in the crosstable
 * controls.
 */

function activateCrosstableFilter ( aDiv )
{
  /*
   * Get the containing div and insert the filter HTML 
   */

  var e = document.getElementById(aDiv)
  if (e == null) {
    throw "div " + aDiv + " not found"
  }
  e.innerHTML = generateFilterHtml(crosstable.Crosstable);

  /*
   * Position the containing div in the center of the browser window
   */

  e.style.zIndex = 4000;
  var f = document.getElementById("gho_client");
  e.style.position = "fixed";
//  e.style.left = ((window.clientWidth - e.clientWidth)/2) + "px";
//  e.style.top = ((window.clientHeight - e.clientHeight)/2) + "px";
  e.style.left = (((window.innerWidth ||
                    document.documentElement.clientWidth ||
                    document.body.clientWidth) - e.clientWidth)/2) + "px";
  e.style.top = (((window.innerHeight ||
                   document.documentElement.clientHeight ||
                   document.body.clientHeight) - e.clientHeight)/2) + "px";
  e.style.display = "none";

  /*
   * Grab the first dimension in the filter list, select it and show the 
   * corresponding set of codes that the user can select. Note that index is
   * 1 because the five we're interested in is actually the second one (the
   * first contains a title)
   */

  x = document.getElementById("cf_main");
  y = x.getElementsByTagName("DIV");
  showFilterLayer(y[1],crosstable.Crosstable.Horizontal.layer[0].dimndx);
  return;
}

/*
 *  BlobCheck is a function that tests if the browser is able to create a Blob
 *  to hold a file to download to the user's desktop
 */

function BlobCheck ()
{
  var result = true;
  var blob = null;
  try {
    blob = new Blob(["Test String"],{"type":"text/plan"}); 
  }
  catch (err) {
    result = false;
  }
  return result;
}


function downloadData( fmt )
{
  var blob = null;
  var filename = null;
  switch(fmt) {
    case 'json':
      blob = new Blob([generateCrosstableJson(crosstable.Crosstable)],
                      {"type":"application/json;charset=utf-8"});
      filename = "data.xml";
      break;
    case 'xml':
      blob = new Blob([generateCrosstableXml(crosstable.Crosstable)],
                      {"type":"text/xml;charset=utf-8"});
      filename = "data.xml";
      break;
    case 'csv':
      blob = new Blob([generateCrosstableCsv(crosstable.Crosstable)],
                      {"type":"text/csv;charset=utf-8"});
      filename = "data.csv";
      break;
    default:
      alert("Unrecognized download format \"" + fmt + "\"");
      break;
  }
  if (blob != null) {
    saveAs(blob,filename);
  }
}

function generateCrosstableJson ( xtab )
{
  var json = "{\n";
  var h_ndx = getDisplayIndices(xtab.Horizontal);
  var v_ndx = getDisplayIndices(xtab.Vertical);
  var cell = null;
  var show_delim = false;

  json += "  \"dimension\": [\n"
  for (var m = 1; m < xtab.dimension.length; m++) {
    if (m > 1) {
      json += ",\n";
    }
    json += "                 {\n                   \"label\": \""  + 
            xtab.dimension[m].code + 
            "\",\n                   \"display\": \"" + 
            xtab.dimension[m].disp + 
            "\"\n                 }";
  }

  json += "\n               ],\n    \"fact\": [\n";
  for (var m = 0; m < v_ndx.length; m++) {
    for (var n = 0; n < h_ndx.length; n++) {
      cell = xtab.Matrix[v_ndx[m]][h_ndx[n]];
      for (var p = 0; p < cell.length; p++) {
        if (show_delim) {
          json += ",\n";
        } else {
          show_delim = true;
        }
        json += "              {\n";
        json += "                \"dims\": {\n";
        for (var q = 0 ; q < xtab.Vertical.layer.length; q++) {
          if (q > 0) {
            json += ",\n";
          }
          json += "                          \"" +
                  xtab.dimension[xtab.Vertical.layer[q].dimndx].code +
                  "\": \"" + 
                  xtab.code[xtab.Vertical.header[v_ndx[m]][q + 1].codendx].disp  +
                  "\"";
        }
        for (var q = 0 ; q < xtab.Horizontal.layer.length; q++) {
          json += ",\n                          \"" +
                  xtab.dimension[xtab.Horizontal.layer[q].dimndx].code +
                  "\": \"" + 
                 xtab.code[xtab.Horizontal.header[h_ndx[n]][q + 1].codendx].disp + 
                  "\"";
        }
        json += "\n                        },\n"
        if (cell[p].comment != "") {
          json += "                \"Comments\": \"" + 
                  cell[p].comment.replace(/\"/g,"\\\"") + 
                  "\",\n";
        }
        json += "                \"Value\": \"" + 
                cell[p].disp.replace(/\"/g,"\\\"") + 
                "\"\n";
        json += "              }";
      }
    }
  }
  json += "\n      ]\n}\n";

  return json;
}

function generateCrosstableXml ( xtab )
{
  var xml = "<Data>\n";
  var h_ndx = getDisplayIndices(xtab.Horizontal);
  var v_ndx = getDisplayIndices(xtab.Vertical);
  var element = null;
  var cell = null;

  for (var m = 0; m < v_ndx.length; m++) {
    for (var n = 0; n < h_ndx.length; n++) {
      cell = xtab.Matrix[v_ndx[m]][h_ndx[n]];
      for (var p = 0; p < cell.length; p++) {
        xml += "  <Fact>\n";
        for (var q = 0 ; q < xtab.Vertical.layer.length; q++) {
          element = xtab.dimension[xtab.Vertical.layer[q].dimndx].code;
          xml += "    <" + element + ">" + 
                 xtab.code[xtab.Vertical.header[v_ndx[m]][q + 1].codendx].disp  +
                 "</" + element + ">\n";
        }
        for (var q = 0 ; q < xtab.Horizontal.layer.length; q++) {
          element = xtab.dimension[xtab.Horizontal.layer[q].dimndx].code;
          xml += "    <" + element + ">" + 
                 xtab.code[xtab.Horizontal.header[h_ndx[n]][q + 1].codendx].disp + 
                 "</" + element + ">\n";
        }
        xml += "    <Display>" + cell[p].disp + "</Display>\n";
        if (cell[p].comment != "") {
          xml += "    <Note>" + cell[p].comment + "</Note>\n";
        }
        xml += "  </Fact>\n";
      }
    }
  }

  xml += "</Data>\n";

  return xml;
}

function generateCrosstableCsv ( xtab )
{
  /*
   * Make the arrays of indices of rows and columns that need to be 
   * displayed.
   */

  var h_ndx = getDisplayIndices(xtab.Horizontal);
  var v_ndx = getDisplayIndices(xtab.Vertical);

  /*
   * Start the table
   */

  var csv = "";

  /*
   * Rendering the horizontal header
   */

  /*
   * We start at 1 rather than 0 because the first entry in a 
   * row/column header is a set of flags - we dont count it as part of 
   * the header.
   * for this loop, n is the depath in the horizontal header, 1 being
   * the top most layer.
   */

  // we intentionally want the counter from 1 to layer.length + 1 
  for (var n = 1 ; n <= xtab.Horizontal.layer.length; n++) {
    var colspan = 0;
    for (var m = 0; m < h_ndx.length; m++) {
      /*
       * The set of cells where the two axes intersect form the "pivot cell"
       * When the horizontal Header is 2 or more layers, a first cell is 
       * generated to hold up the space.  When we encounter the last layer
       * of the horizontal axis, we output the cells required to provide
       * labels to the vertical header columns.
       */

      // This is the first cell - it is only used when we have more that one
      // Horizontal header layer

      if ((n == 1) && (m == 0) && (xtab.Horizontal.layer.length > 1)) { 
        for (var q = 1; q < xtab.Vertical.layer.length; q++) {
          csv += ",";
        }
      }
   
      //  This is the set of labels for the columns of the vertical header
      // This is always output.

      else if ((n == xtab.Horizontal.layer.length) && (m == 0)) {
        for (var q = 0; q < xtab.Vertical.layer.length; q++) {
          if (q > 0) {
            csv += ",";
          }
          csv += "\"" + 
                 xtab.dimension[xtab.Vertical.layer[q].dimndx].disp +
                 "\"";
        }
      }

      //
      //  This is a row within the header - we just need to space it
      //  appropriately above the data.
      //  
      else if (m == 0) {
        for (var q = 1; q < xtab.Vertical.layer.length; q++) {
          csv += ",";
        }
      }

  /*
   * Get the index to the complete code that needs to be displayed
   */

      var code = xtab.Horizontal.header[h_ndx[m]][n].codendx;
      var disp = xtab.code[code].disp;
      csv += ",\"" + disp + "\"";
    }
    csv += "\n";
  }

  /*
   * Rendering the vertical header and the data cells
   */

  for (var m = 0; m < v_ndx.length; m++) {
  
  /* 
   * Render this row's portion of the vertical header. The array rowspan
   * is used to keep track of which header cells span across several rows. It 
   * is the same approach as above.
   */

  // we intentionally want the counter from 1 to layer.length + 1 
    for (var n = 1; n <= xtab.Vertical.layer.length; n++) {
      var code = xtab.Vertical.header[v_ndx[m]][n].codendx;
      var disp = xtab.code[code].disp;
      if (n > 1) {
        csv += ",";
      }
      csv += "\"" + disp + "\"";

    }
 
    for (var n = 0; n < h_ndx.length; n++) {
      var cell = xtab.Matrix[v_ndx[m]][h_ndx[n]];
      csv += ",\""; 
      for (var p = 0; p < cell.length; p++) {
        if (p > 0) { 
          csv += " ";
        }
        csv += cell[p].disp;
      }
      csv += "\""; 
    }
    csv += "\n"; 
  }
  return csv
}

/*
 * Creates the HTML text to render the Javascript version of the 
 * cross table.
 */

function generateCrosstableHtml ( xtab )
{
  var collapse_row = 999;
  if ('collapserow' in xtab.Horizontal) {
    if ((xtab.Horizontal.collapserow > 0) && 
        (xtab.Horizontal.collapserow < xtab.Horizontal.layer.length)) {
      collapse_row = xtab.Horizontal.collapserow;
    }
  }

  /*
   * Make the arrays of indices of rows and columns that need to be 
   * displayed.
   */

  var h_ndx = getDisplayIndices(xtab.Horizontal);
  var v_ndx = getDisplayIndices(xtab.Vertical);

  /*
   * Start the table
   */

  var html = "<table class=\"crosstable\">";

  /*
   * Rendering the horizontal header
   */

  /*
   * We start at 1 rather than 0 because the first entry in a 
   * row/column header is a set of flags - we dont count it as part of 
   * the header.
   * for this loop, n is the depath in the horizontal header, 1 being
   * the top most layer.
   */

  // we intentionally want the counter from 1 to layer.length + 1 
  for (var n = 1 ; n <= xtab.Horizontal.layer.length; n++) {
    if (n < collapse_row) {
      html += "<tr>"
      var colspan = 0;
      for (var m = 0; m < h_ndx.length; m++) {
      /*
       * The set of cells where the two axes intersect form the "pivot cell"
       * When the horizontal Header is 2 or more layers, a first cell is 
       * generated to hold up the space.  When we encounter the last layer
       * of the horizontal axis, we output the cells required to provide
       * labels to the vertical header columns.
       */

      // This is the first cell - it is only used when we have more that one
      // Horizontal header layer

        if ((n == 1) && (m == 0) && (xtab.Horizontal.layer.length > 1)) { 
          html += "<th id=\"pivotcell\" rowspan=\"" + 
                  ((collapse_row < xtab.Horizontal.layer.length) ? (collapse_row - 1) : (xtab.Horizontal.layer.length - 1)) +
                  "\" colspan=\"" + 
                  (xtab.Vertical.layer.length) +
                  "\">";
        }
   
      //  This is the set of labels for the columns of the vertical header
      // This is always output.

        if ((n == xtab.Horizontal.layer.length) && (m == 0)) {
          for (var q = 0; q < xtab.Vertical.layer.length; q++) {
            html += "<th id=\"pivotcell_" + q + "\">" + 
                    xtab.dimension[xtab.Vertical.layer[q].dimndx].disp +
                    "</th>";
          }
        }

  /*
   * Get the index to the complete code that needs to be displayed
   */

        var code = xtab.Horizontal.header[h_ndx[m]][n].codendx;

/*  If colspan is 0, then we haev to start a new cell.  If this is the case, we look
 *  forward to the subsequent cells of the header to see if they should be 
 *  merged together.  This is only done if the codes for the specific cell and its
 *  parents are the same as the next cell's and it's parents.  Once one of the codes is
 *  different, we stop merging and set the colspan for the cell.
 *
 */

        if (colspan == 0) {
          var continue_merge = true;
          colspan = 1;
          for (var p = (m + 1); p < h_ndx.length; p++) {
            for (var t = 1; t <= n; t++) {
/*
 * As we navigate the header we only look at subsequent non-hiding (ie unfiltered) cells
 */
              if (xtab.Horizontal.header[h_ndx[p - 1]][t].codendx != xtab.Horizontal.header[h_ndx[p]][t].codendx) {
                continue_merge = false;
                break;
              }
            }
            if (continue_merge) {
              colspan += 1
            } else {
              break;
            }
          }
          html += generateHeaderCellHtml(xtab,code,colspan,0,"horizontal");
        }
/* 
 *  We now reduce the running colspan by one to account for the cell we've either just
 *  generated or skpped. 
 */
        colspan -= 1;
      }
      html += "</tr>";
    }
  }


/*
 *  Render the collapsed header row.  output the last row of the horizontal header and
 *  include all the labels from the above rows collapsed into it.  This is the final row 
 *  of the header so everything is colspan 1 and rowspwn 1, no need to merge cells
 *  horizontally.
 */

  if (collapse_row < 999) {
    html += "<tr>";
    //
    //  Special case of the pivot cell when we collapse all the rows in the 
    //  horizontal header together
    //  
    for (var q = 0; q < xtab.Vertical.layer.length; q++) {
      html += "<th id=\"pivotcell_" + q + "\">" + 
              xtab.dimension[xtab.Vertical.layer[q].dimndx].disp +
              "</th>";
    }
//    for (var n = 0 ; n < xtab.Horizontal.header.length; n++) {
    for (var n = 0; n < h_ndx.length; n++) {
      html += "<th class=\"horizontal\">";
      for (var m = collapse_row; m <= xtab.Horizontal.layer.length; m++) {
        var codendx = xtab.Horizontal.header[h_ndx[n]][m].codendx;
        var url = xtab.code[codendx].url;
        var disp = xtab.code[codendx].disp;
        var comment = xtab.code[codendx].comment;
        if (url != "") {
          html += "<span class=\"link\" onclick=\"window.open('" + url + "','_top')\">" +
                  disp +
                  "<span class=\"icon\"/>i</span>" +
                  "</span>";
        } else if (comment != "") {
          html += "<span onclick=\"showDetails(null,null," + codendx + ")\">" +
                  disp +
                  "<span class=\"icon\"/>i</span>" +
                  "</span>";
        } else {
          html += disp;
        }
      }
      html += "</th>";
    }
    html += "</tr>";
  }

  /*
   * Rendering the vertical header and the data cells
   */

  var rowspan = [];
  var continue_merge = [];
  // we intentionally want the counter from 1 to layer.length + 1 
  for (var p = 0; p <= xtab.Vertical.layer.length; p++) {
    rowspan[p] = 0;
    continue_merge[p] = true;
  }

  for (var m = 0; m < v_ndx.length; m++) {
    html += "<tr>";
  
  /* 
   * Render this row's portion of the vertical header. The array rowspan
   * is used to keep track of which header cells span across several rows. It 
   * is the same approach as above.
   */

  // we intentionally want the counter from 1 to layer.length + 1 
    for (var n = 1; n <= xtab.Vertical.layer.length; n++) {
      var code = xtab.Vertical.header[v_ndx[m]][n].codendx;
      if (rowspan[n] == 0) {
        rowspan[n] = 1;
        continue_merge[n] = true;
        for (var p = (m + 1); p < v_ndx.length; p++) {
          for (var t = 1; t <= n; t++) {
/*
 * As we navigate the header we only look at subsequent non-hiding (ie unfiltered) cells
 */
            if (xtab.Vertical.header[v_ndx[p - 1]][t].codendx != xtab.Vertical.header[v_ndx[p]][t].codendx) {
              continue_merge[n] = false;
              break;
            }
          }
          if (continue_merge[n]) {
            rowspan[n] += 1
          } else {
            break;
          }
        }
        html += generateHeaderCellHtml(xtab,code,0,rowspan[n],"vertical");
      }
      rowspan[n] -= 1;      
    }
 
  /*
   * Rendering the data cells for the current table row
   */

    for (var n = 0; n < h_ndx.length; n++) {
      html += generateDataCellHtml(xtab,v_ndx[m],h_ndx[n]);
    }

    html += "</tr>";
  }

  html += "</table>";

  return html;
}

/*
 *
 */

function filterSetAll ( xtab , value )
{
  if ((value != 1) && (value != 0)) {
    throw "value parameter must be either 0 (show) or 1 (hide)"
  }
  for (var n = 0; n < xtab.Horizontal.header.length; n++) {
    xtab.Horizontal.header[n][0].hide = value;
  }
  for (var n = 0; n < xtab.Vertical.header.length; n++) {
    xtab.Vertical.header[n][0].hide = value;
  }
}

/*
 *
 */

function filterSetCode ( xtab , codendx, value )
{
  if ((value != 1) && (value != 0)) {
    throw "value parameter must be either 0 (show) or 1 (hide)"
  }
  for (var n = 0; n < xtab.Horizontal.header.length; n++) {
    for (var m = 1; m < xtab.Horizontal.header[n].length; m++ ){
      if (xtab.Horizontal.header[n][m].codendx == codendx) {
        xtab.Horizontal.header[n][0].hide = value;
      }
    }
  }
  for (var n = 0; n < xtab.Vertical.header.length; n++) {
    for (var m = 1; m < xtab.Vertical.header[n].length; m++ ){
      if (xtab.Vertical.header[n][m].codendx == codendx) {
        xtab.Vertical.header[n][0].hide = value;
      }
    }
  }
}  



/*
 *  Generate the dropdown with donwload options for the complete dataset
 */

function mkCompleteDownloadDropdown( xtab ) 
{
  var html = null;

  //html = "<select id=\"downloads\" onchange=\"window.open(this.options[this.selectedIndex].value)\">";
  html = "<select id=\"downloads\" onchange=\"window.open(this.value);this.selectedIndex=0;\">";
  html += "<option selected=\"selected\" disabled=\"disabled\" value=\"\">Download complete dataset</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&profile=excel-xtab&format=xml\"> - Multipurpose table in Excel format</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&profile=crosstable&format=csv\"> - Multipurpose table in CSV format</option>";
  html += "<option disabled=\"disabled\" value=\"\">CSV</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&profile=crosstable&format=csv\"> - Crosstable</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&profile=crosstable&format=csv&x-collapse=true\">- Crosstable with single header row</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&profile=text&format=csv\"> - Line list with text values</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&format=csv\"> - Line list with coded values</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&profile=verbose&format=csv\"> - Line list with text and code values</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&profile=xmart&format=csv\"> - XMart</option>";
  html += "<option disabled=\"disabled\" value=\"\">Excel</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&profile=excel-xtab&format=xml\"> - Crosstable format</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&profile=excel&format=xml\"> - List format</option>";
  html += "<option disabled=\"disabled\" value=\"\">HTML</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&profile=ztable&format=html\"> - List format</option>";
  html += "<option disabled=\"disabled\" value=\"\">JSON</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&format=json\"> - Complete structure</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&profile=simple&format=json\"> - Simplified structure</option>";
  html += "<option disabled=\"disabled\" value=\"\">XML</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&format=xml\"> - GHO XML</option>";
  html += "<option value=\"" +  xtab.DataUrl + "&profile=simple&format=xml\"> - Simplified XML</option>";

  html += "</select>";
  return html;
}
