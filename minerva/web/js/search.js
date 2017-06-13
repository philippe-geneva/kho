/*
 * Temporary search function 
 * 
 * This search method greatly improves upon the search capability of the original GHO, but is
 * still limited to the menu structure.  It is intended as a stop gap measure to be used until
 * we integrate with WHO's corporate search infrastructure.
 */

function search ()
{
  var q = document.getElementById("q");
  var e = document.getElementById("subnavigation").getElementsByTagName("LI");
  var result = "";
  var hits = 0;
  var word = q.value.split(" ");
  var puburl = publicURL.replace("/beta.jsp","");


  /* 
   * Split the search value into multiple patterns that will be effectively
   * ANDed together to match against fully qualified menu entries (all super levels
   * are concatenated together to give a complete name for a particular menu entry
   */

  var pattern = new Array();
  for (n = 0; n < word.length; n++) {
    pattern[pattern.length] = RegExp(word[n],"i");
  }

  /*
   * Look at all the menu entries
   */

  for (n = 0; n < e.length; n++) {

    /* 
     * The search should only return results for nodes that are NOT hidden
     */

    if (e[n].className.indexOf("hidden") == -1) {
      var a = e[n].getElementsByTagName("A");
      if (a != null) {

        /*
         * Assemble the full link name to get a better search result
         */
  
        var linkname = a[0].innerHTML;
        var x = a[0];
        while (x.parentNode.parentNode.className != "subnavigation") {
          x = x.parentNode.parentNode;
          linkname = x.parentNode.childNodes[0].innerHTML + " &gt; " + linkname;
        }
      
        /* 
         * Count the number of matching patterns against the fully qualified menu entry name
         */
  
        var matches = 0;
        for (m = 0; m < pattern.length; m++) {
          if (linkname.search(pattern[m]) >= 0) {
            matches++;
          }
        }
  
        /* 
         * If all patterns matched, add the fully qualified name and the generated URL
         * to the result list
         */
  
        if (matches == pattern.length) {
          hits++;
          var resurl = puburl + "?theme=" + theme + "&node=" + e[n].id.replace("_mn_",""); 
          result += "<li>";
          if (e[n].className.search("leave") >= 0) {
            result += "<b>[Data view] </b>";
          } else {
            result += "<b>[Menu entry] </b>";
          }
          result += "<a target=\"node" + e[n].id + "\" href=\"" + resurl + "\">" + linkname + "</a><br />\n";
          result += resurl + "<br />\n";
          result += "<br /><br /></li>\n";
        }
      }
    }    
  }

  /* 
   * Finalize the result text then display it to the user and clear the search field.
   */

  result = "<html><head></head><body><h2>Search results</h2><br />" + hits + " hits searching for <b>" + q.value + "</b> (links will open a new tab or window)<br /><br /><ul>" + result + "</ul>\n</body></html>";
  q.value = "";
  hideInfoZone();
  setZoneHTML(3,"");
  setZoneHTML(2,"");
  setZoneHTML(1,"");
  setContentIFrameHTML(result);
}
