<%@ page contentType="text/html" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.sqlite.*" %>
<%
  int id = Integer.parseInt(request.getParameter("id")); 

  String dbPath = "/WEB-INF/tpc.db";

  String tpid = null;
  String title = null;
  int height = 675;
  Statement statement = null;
  ResultSet rs = null;

  Connection conn = null;

  try 
  {
    Class.forName("org.sqlite.JDBC");
    conn = DriverManager.getConnection("jdbc:sqlite:"+getServletContext().getRealPath(dbPath)); 
    statement = conn.createStatement();
    statement.setQueryTimeout(10);
    rs = statement.executeQuery("select * from viz where id=" + id);
    if (rs.next()) {
      tpid = rs.getString("name");
      title = rs.getString("title"); 
      height = rs.getInt("height");
    } 
  } 
  catch (Exception e) 
  {
    System.err.println(e.getMessage());
  }
  finally 
  {
    try
    {
      if (rs != null) {
        rs.close();
      }
      if (statement != null) {
        statement.close();
      }
      if (conn != null) {
        conn.close();
      }
    }
    catch (Exception e) 
    {
      System.err.println(e.getMessage());
    }
  }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>WHO | <%=title%></title>
<meta name="DC.title" content="WHO | <%=title%>" />
<meta name="DC.publisher" content="World Health Organization" />
<meta name="DC.format" content="text/html" />
<meta name="DC.source" content="WHO" />
<meta name="DC.date.published" content="2016-08-29 15:15:05" />
<meta name="DC.identifier" content="/entity/gho/en/index.html" />
<meta name="description" content="The Global Health Observatory (GHO) is WHO's gateway to health-related statistics for more than 1000 indicators for its 194 Member States. Data are organized to monitor progress towards the Sustainable Development Goals (SDGs), including health status indicators to monitor progress towards for the overall health goal, indicators to track equity in health indicators, and the indicators for the specific health and health-related targets of the SDGs." />
<meta name="webit_document_id" content="211400" />
<meta name="webit_document_name" content="EN GHO: Home page (v2)" />
<meta name="webit_cover_date" content="2016-04-12" />
<meta name="burntime" content="2016-08-29 15:15:32.000000" />
<meta name="fb:app_id" content="1678989475646792"/> 
<meta property="og:site_name" content="World Health Organization"/> 
<meta property="og:url" content="http://www.who.int/gho/en/"/> 
<meta property="og:locale" content="en_GB"/> 
<meta name="article:publisher" content="https://www.facebook.com/WHO"/> 
<meta property="og:title" content="<%=title%>"/> 
<meta property="og:description" content="The Global Health Observatory is WHO's gateway to health-related statistics for more than 1000 indicators for its 194 Member States. Data are organized to monitor progress towards the Sustainable Development Goals (SDGs), including health status indicators to monitor progress towards for the overall health goal, indicators to track equity in health indicators, and the indicators for the specific health and health-related targets of the SDGs."/> 
<meta property="og:type" content="website"/> 
<meta property="og:image" content="http://www.who.int/entity/gho/homepage2/sdg-home.jpg"/> 
<meta property="og:image:width" content="630"/> 
<meta property="og:image:height" content="330"/> 
<meta name="twitter:card" content="summary_large_image"/> 
<meta name="twitter:site" content="@who"/> 
<meta name="twitter:title" content="<%=title%>"/> 
<meta name="twitter:description" content="The Global Health Observatory is WHO's gateway to health-related statistics for more than 1000 indicators for its 194 Member States. Data are organized to monitor progress towards the Sustainable Development Goals (SDGs), including health status indicators to monitor progress towards for the overall health goal, indicators to track equity in health indicators, and the indicators for the specific health and health-related targets of the SDGs."/> 
<meta name="twitter:image" content="http://www.who.int/entity/gho/homepage2/sdg-home.jpg"/> 
<meta name="twitter:image:height" content="330"/> 
<meta name="twitter:image:width" content="630"/> 




<script type="text/javascript">
    var lang = "en";
</script>
<link rel="shortcut icon" href="http://www.who.int/sysmedia/media/resources/favicon.ico" />
<link rel="apple-touch-icon" href="http://www.who.int/sysmedia/media/resources/apple-touch-icon.png"/>		
<script type="text/javascript" src="http://www.who.int/sysmedia/media/js/lib/jquery.js"></script>
<script type="text/javascript" src="http://www.who.int/sysmedia/media/js/lib/jquery.plugins_r.js"></script>

<!--[if gte IE 9]>
<script type="text/javascript" src="http://www.who.int/sysmedia/media/js/lib/matchMedia.js"></script>
<script type="text/javascript" src="http://www.who.int/sysmedia/media/js/lib/matchMedia.addListener.js"></script>
<script type="text/javascript" src="http://www.who.int/sysmedia/media/js/lib/enquire.min.js"></script>
<![endif]-->
<![if !IE]>
<script type="text/javascript" src="http://www.who.int/sysmedia/media/js/lib/enquire.min.js"></script>
<![endif]>

<script type="text/javascript" src="http://www.who.int/sysmedia/media/js/lib/owl.carousel.js"></script>
<script type="text/javascript" src="http://www.who.int/sysmedia/media/js/who.js"></script>
<script type="text/javascript" src="http://www.who.int/sysmedia/media/js/responsive.js"></script>
 
 
 





<link href="http://www.who.int/sysmedia/media/style/who_responsive.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" src="http://www.who.int/sysmedia/media/js/captify.js"></script>
<!--[if IE]><link href="http://www.who.int/sysmedia/media/style/css/patches/patch_ie_r.css" rel="stylesheet" type="text/css" /><![endif]-->
<!--[if IE 7]><link href="http://www.who.int/sysmedia/media/style/css/patches/patch_ie_7_r.css" rel="stylesheet" type="text/css" /><![endif]-->
<!--[if IE 6]><link href="http://www.who.int/sysmedia/media/style/css/patches/patch_ie_6_r.css" rel="stylesheet" type="text/css" /><![endif]-->
<!--[if lte IE 7]><link href="http://www.who.int/sysmedia/media/style/css/screen/responsive-ie-fix.css" rel="stylesheet" type="text/css" /><![endif]-->  
<!--[if IE 8]><link href="http://www.who.int/sysmedia/media/style/css/screen/responsive-ie-fix.css" rel="stylesheet" type="text/css" /><![endif]-->
<!-- jquery_share_css_place_holder --> 


<link rel="stylesheet" type="text/css" href="http://www.who.int/sysmedia/media/style/css/language/lang_en_r.css"/>  

    <link rel="stylesheet" type="text/css" href="http://www.who.int/sysmedia/scripts/shadowbox/en/shadowbox.css" />
  <script type="text/javascript" src="http://www.who.int/sysmedia/scripts/shadowbox/en/shadowbox.js"></script>
    <script type="text/javascript">
//<![CDATA[
        Shadowbox.init({
          //troubleElements: ["select", "object", "embed", "canvas"],viewportPadding: 20,
          //flashVersion: 9.0.0,counterLimit: 20, displayCounter: true, displayNav: true, enableKeys: true,
          //modal: true, fadeDuration:0.35, handleUnsupported:: link, initialHeight: , initialWidth: , onChange: ,
          // onClose , onFinish, onOpen, overlayColor: #000,
          animate : true,
          animateFade:true,
          animSequence: "sync",
          continuous: true,
          counterType: "skip",
          handleOversize: "drag",
          modal: false,
          overlayOpacity: 0.8,
          showOverlay: true,
          resizeDuration: 0.50,
          showMovieControls: false,
          slideshowDelay: 0,
          displayNav: true
    });
    //]]>
    </script>




<!-- secondary nav styles -->
 <style type="text/css">



 	__gho a {color:#D86422;}

</style>
<script type="text/javascript">

        var path_elements = new Array('__gho');

        function fixMenu(){
                for( i = 0; i < path_elements.length; i++ ){
                        if( document.getElementById( path_elements[i] ) ){
                                document.getElementById( path_elements[i] ).firstChild.style.color = '#D86422';
                                break;
                        }
                }
        }

</script> 






</head>
<body class="main-site">
<!-- Google Tag Manager -->
<noscript><iframe src="//www.googletagmanager.com/ns.html?id=GTM-MDCJXB"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','GTM-MDCJXB');</script>
<!-- End Google Tag Manager -->



		<!-- begin: page -->
	<script>
		var show_contextly = 0;
	</script>



	<div id="page"  >
		<!-- begin: wrapper -->
		<div id="wrapper">
			                   
			<!-- begin: header -->
			<div id="header">
					<!--including masthead file: /mason/mheader_en.mc?entity_name=gho -->
					<!--googleoff: index-->  

 

<!-- begin: skip to content -->
<div id="skip"><a href="#content">Skip to main content</a></div>

<!-- CHANGED  -->
<!-- div id="campaignHighlight">
<a href="http://www.who.int/campaigns/hepatitis-day/2016/en/" id ="hepatitis-day-2016"> <span>Tobacco Day</span>
<img src="http://www.who.int/campaigns/hepatitis-day/2016/masthead-en.jpg" alt="Campaign week"></a>
</div -->

<!-- script> 
$( document ).ready(function() {
	function getRandomNumber(min, max){
			return Math.floor(Math.random() * (max - min + 1)) + min;
	}

	var i1 = "http://www.who.int/campaigns/world-blood-donor-day/2016/masthead-girl-en.jpg";
	var i2 = "http://www.who.int/campaigns/world-blood-donor-day/2016/masthead-boy-en.jpg";	          
	var i3 = "http://www.who.int/campaigns/world-blood-donor-day/2016/masthead-woman-en.jpg";
	var texts = [i1, i2, i3];
	var cUrl = "http://www.who.int/campaigns/world-blood-donor-day/2016/en/";
	$("#campaignHighlight").append( '<a href="' + cUrl +'" id ="blood-day-2016"> <span>Campaign</span><img src="'+ texts[getRandomNumber(0, texts.length-1)] +'" alt="Campaign"></a>');
});	
</script -->

  <div id="campaignHighlight"> 
  </div>


<!-- begin: branding -->
  <div id="branding">
    <a linkindex="0" href="/en/"
     title="<%=title%>">
    </a>
  </div>
  <!-- end: branding -->

  <!-- begin: access -->
  <div id="access">
    <h3>Access</h3>
    <ul>
      <li>
        <a linkindex="1" accesskey="0" title="Home"
        href="/en/">Home Alt+0</a>
      </li>
      <li>
        <a linkindex="2" accesskey="1" title="Navigation"
        href="#navigation">Navigation Alt+1</a>
      </li>
      <li>
        <a linkindex="3" accesskey="2" title="Content"
        href="#main">Content Alt+2</a>
      </li>
    </ul>
  </div>
  <!-- end: access -->
  
  <!-- begin: search -->
  <span id="mobile-search-icon" class="mobile-search-icon"><i class="search-icon-image"></i></span>
 <div id="search"> 
  <h3>Search</h3>
  <form id="search_form" action="http://search.who.int/search">
        <span id="search_label">
            <label for="q"> Search the
            <acronym title="World Health Organization">WHO</acronym>.int site</label>
        </span>

        <span id="search_input">
          <input name="q" id="q" title="Search the WHO.int site" type="text" />
        </span>
        <label for="search_submit" class="invisible"> Submit </label>
        <input type="hidden" name="ie" value="utf8" />
        <input type="hidden" name="site" value="who" />
        <input type="hidden" name="client" value="_en_r" />
        <input type="hidden" name="proxystylesheet" value="_en_r" /> 
        <input type="hidden" name="output" value="xml_no_dtd" />
        <input type="hidden" name="oe" value="utf8" />
        <input type="hidden" name="getfields" value="doctype"/>
        <input id="search_submit" value="Search" title="Search" type="submit" />
        <a href="http://search.who.int/search?ie=utf8&site=who&lr=lang_en&client=_en_r&proxystylesheet=_en_r&output=xml_no_dtd&oe=UTF-8&access=p&entqr=3&ud=1&proxycustom=%3CADVANCED/%3E" title="Advanced Search" id="search_advanced">
            Advanced search
        </a>
    </form>
</div>
 <!-- end: search -->
  
  
  <!-- begin: navigation -->
  <span id="mobile-nav-icon" class="mobile-nav-icon"><i class="nav-icon-image"></i></span>
  <div id="navigation">
    <h3>Navigation</h3>
    
    <ul>
      <li id="navigation_home"  >
      <a linkindex="5" href="/en/" title="Home">
          <span>Home</span>
        </a>
      </li>
      <li id="navigation_health-topics"   >
        <a href="/topics/en/" title="Health topics">
          <span>Health topics</span>
        </a>
      </li>
      <li id="navigation_data-and-statistics"  class="selected"  >
        <a href="/entity/gho/en/" title="Global Health Observatory (GHO) data">
          <span>Data</span>
        </a>
      </li>
      <li id="navigation_media-centre"  >
        <a href="/entity/mediacentre/en/" title="Media centre">
          <span>Media centre</span>
        </a>
      </li>
      <li id="navigation_publications"  >
        <a href="/publications/en/" title="Publications">
          <span>Publications</span>
        </a>
      </li>

	  
      <li id="navigation_countries"  >
        <a linkindex="6" href="/countries/en/"
        title="Countries">
          <span>Countries</span>
        </a>
      </li>
      <li id="navigation_programmes-and-projects"  >
        <a linkindex="7" href="/entity/en/"
        title="Programmes and projects">
          <span>Programmes</span>
        </a>
      </li>
	  <li id="navigation_governance"  >
        <a href="/governance/en/" title="Governance">
          <span>Governance</span>
        </a>
      </li>
      <li id="navigation_about-who" class="last  " >
        <a href="/about/en/" title="About WHO">
          <span>About <acronym title="World Health Organization">WHO</acronym></span>
        </a>
      </li>
    </ul>
  </div>
  <!-- end: navigation -->

  <div class="clear"></div>

  <!-- begin: language -->
  <div id="language">
    <h3>Language</h3>
    <div class="language_container">
        <div id="owl-language-carousel" dir="ltr" class="owl-carousel owl-theme">
             <script type="text/javascript">
          var addthis_config = addthis_config||{};
          addthis_config.lang = 'en';
 </script>
<div id="language_ar" class="item disabled" ><a href="#" title="Arabic"><span  dir="rtl" >عربي</span> </a> </div>
<div id="language_zh" class="item disabled" ><a href="#" title="Chinese"><span >中文</span> </a> </div>
<div id="language_en" class="item  selected" ><a href="#" title="English"><span >English</span> </a> </div>
<div id="language_fr" class="item disabled" ><a href="#" title="French"><span >Français</span> </a> </div>
<div id="language_ru" class="item disabled" ><a href="#" title="Russian"><span >Русский</span> </a> </div>
<div id="language_es" class="item last disabled" ><a href="#" title="Spanish"><span >Español</span> </a> </div>


        </div>
    </div>
  </div>

  <!-- end: language -->

  <!-- begin: social links -->
  <div class="header-social-links">
     <div class="addthis_inline_follow_toolbox"></div>
 </div>
  <!-- end: social links -->
   <!--googleon: index-->


 

 
			</div>
			<!-- end: header -->

			
	

			
			<!-- begin: main --> 
				<div id ="main">
				 <!-- begin: sidebar -->
				 <div id= "sidebar">
                   
	<!-- begin: secondary navigation subnavigation -->
	<div id="subnavigation">
		<h3>Menu</h3>

	 <!--googleoff: index-->
<!-- Global Health Observatory (GHO) data secondary navigation -->
<ul class="subnavigation">
<li id="__gho"><a href="/entity/gho/en/">Global Health Observatory data</a></li>
<li id="__gho__database" class="leave"><a 
href="/entity/gho/database/en/">Data repository</a></li>
<li id="__gho__publications" class="leave"><a 
href="/entity/gho/publications/en/">Reports</a></li>
<li id="__gho__countries" class="leave"><a 
href="/entity/gho/countries/en/">Country statistics</a></li>
<li id="__gho__map_gallery" class="leave"><a href="/entity/gho/map_gallery/en/">Map 
gallery</a></li>
<li id="__gho__indicator_registry" class="leave"><a 
href="/entity/gho/indicator_registry/en/">Standards</a></li>
</ul>
 <!--googleon: index-->


	</div>
	<!-- end: subnavigation -->


 
				  </div>
				 <!-- end: sidebar -->
				 				 				 				 
				 <!-- begin: content --> 
				    <div id ="content">
					    <h1><%=title%></h1>


    <!-- BEGIN TABLEAU PUBLIC CONTENT -->



<script type="text/javascript" 
        src="https://public.tableau.com/javascripts/api/viz_v1.js">
</script>
<div class="tableauPlaceholder">
  <noscript>
    <a href="#">
      <img style="border: none" s
	   rc="https://public.tableau.com/static/images/x/<%=tpid%>1_rss.png">
    </a>
  </noscript>
  <object class="tableauViz" 
	  width="982" 
	  style="display:none;" 
	  height="<%=height%>">
      <param name="host_url" value="https://public.tableau.com/">
      <param name="site_root" value="">
      <param name="name" value="<%=tpid%>">
      <param name="tabs" value="no">
      <!--
      <param name="name" value="SDGTarget3_1_1nostory/Situation">
      -->
      <param name="toolbar" value="no">
      <param name="animate_transition" value="yes">
      <param name="display_static_image" value="no">
      <param name="display_spinner" value="no">
      <param name="display_overlay" value="no">
      <param name="display_count" value="no">
      <param name="showTabs" value="no">
  </object>
</div>

    <!-- BEGIN TABLEAU PUBLIC CONTENT -->





					</div>
				<!-- end: content -->
				
				<div class="clear">
					<!-- all clear -->
				</div>
			</div>
			<!-- end: main -->
					<div id="breadcrumb">
    <h2>You are here:</h2>
	<ul>
		<li class="selected">
			<a href="/entity/gho/en/" title="Global Health Observatory (GHO) data">Global Health Observatory (GHO) data</a>
		</li>
    </ul>
	<div class="clear"></div>
</div>







			<!-- begin: footer -->
			<div id="footer">
				
<!--googleoff: index-->

<!-- begin: doormat -->
<div id="doormat">
    <h2>Quick Links</h2>
    <!-- column -->
    <div class="doormat_col_1_3">
        <h3>Sitemap</h3>
        <ul class="footer-col-links">
            <li>
                <a href="/en/index.html">Home</a>
            </li>
            <li>
                <a href="/topics/en/index.html">Health topics</a>
            </li>
            <li>
                <a href="/entity/gho/en/index.html">Data</a>
            </li>
            <li>
                <a href="/entity/mediacentre/en/index.html">Media centre</a>
            </li>
            <li>
                <a href="/publications/en/index.html">Publications</a>
            </li>
            <li>
                <a href="/countries/en/index.html">Countries</a>
            </li>
            <li>
                <a href="/entity/en/index.html">Programmes and projects</a>
            </li>
            <li>
                <a href="/governance/en/index.html">Governance</a>
            </li>
            <li>
                <a href="/about/en/index.html">About 
          <acronym title="World Health Organization">
          WHO</acronym></a>
            </li>
        </ul>
    </div>
    <!-- column -->
    <div class="doormat_col_2_3">
        <h3>Help and Services</h3>
        <ul class="footer-col-links">
            <li>
                <a href="/about/contacthq/en/index.html">Contacts</a>
            </li>
            <li>
                <a href="/suggestions/faq/en/index.html">FAQs</a>
            </li>
            <li>
                <a href="/entity/employment/en/index.html">Employment</a>
            </li>
            <li>
                <a href="/suggestions/en/index.html">Feedback</a>
            </li>
            <li>
                <a href="/about/privacy/en/index.html">Privacy</a>
            </li>
            <li>
                <a href="/about/scamalert/en/index.html">E-mail scams</a>
            </li>
        </ul>
    </div>
    <!-- column -->
    <div class="doormat_col_3_3">
        <h3>WHO Regional Offices</h3>
        <ul class="footer-col-links">
            <li>
                <a href="http://www.afro.who.int/" target="_new"><acronym title="World Health Organization">
          WHO</acronym> African Region</a>
            </li>
            <li>
                <a href="http://www.paho.org/" target="_new"><acronym title="World Health Organization">
          WHO</acronym> Region of the Americas</a>
            </li>
            <li>
                <a href="http://www.searo.who.int/" target="_new"><acronym title="World Health Organization">
          WHO</acronym> South-East Asia Region</a>
            </li>
            <li>
                <a href="http://www.euro.who.int/" target="_new"><acronym title="World Health Organization">
          WHO</acronym> European Region</a>
            </li>
            <li>
                <a href="http://www.emro.who.int/" target="_new"><acronym title="World Health Organization">
          WHO</acronym> Eastern Mediterranean Region</a>
            </li>
            <li>
                <a href="http://www.wpro.who.int/" target="_new"><acronym title="World Health Organization">
          WHO</acronym> Western Pacific Region</a>
            </li>
        </ul>
    </div>
    <!-- column -->
    <div class="clear"></div>
    <div>
        <script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-5803f964fe6c9599"></script>
        <div class="footer-social-links">
            <div class="addthis_inline_follow_toolbox"></div>
        </div>
        <div class="footer-social-links store-buttons">
            <a href="https://play.google.com/store/apps/details?id=uk.co.adappt.whoapp" target="_new">
                <img class="play-store" src="http://www.who.int/sysmedia/media/style/img/google-play-badge_en.png"></img>
            </a>
            <a href="https://itunes.apple.com/gb/app/who-info/id895463794?mt=8" target="_new">
                <img class="apple-store" src="http://www.who.int/sysmedia/media/style/img/apple_store_en.svg"></img>
            </a>
        </div>
    </div>
    <div class="clear">
        <!-- all clear -->
    </div>
</div>
<!-- end: doormat -->
<!-- begin: foot -->
<div id="foot">
    <p><a href="/about/copyright/en/">&#169; <acronym title="World Health Organization">
        WHO</acronym> 2016</a></p>
</div>
<!-- end: foot -->



<a href="#" class="back-to-top"><span>Back to top</span></a>

<div id="newsletter">
    <div id="newsletter-form">


        <div class="inlay">
            <!-- Begin MailChimp Signup Form -->
            <div id="mc_embed_signup">
                <form action="//who.us9.list-manage.com/subscribe/post?u=a6b34fbd46b688a84a907e16d&amp;id=823e9e35c1" method="post" id="mc-embedded-subscribe-form" name="mc-embedded-subscribe-form" class="validate" target="_blank" novalidate>
                    <div id="mc_embed_signup_scroll">
                        <div class="mc-field-group">
                            <label for="mce-EMAIL">Email Address</label>
                            <input type="email" value="@" name="EMAIL" class="email-address" id="mce-EMAIL">
                        </div>
                        <div id="mce-responses" class="clear">
                            <div class="response" id="mce-error-response" style="display:none"></div>
                            <div class="response" id="mce-success-response" style="display:none"></div>
                        </div>
                        <!-- real people should not fill this in and expect good things - do not remove this or risk form bot signups-->
                        <div style="position: absolute; left: -5000px;"><input type="text" name="b_a6b34fbd46b688a84a907e16d_823e9e35c1" tabindex="-1" value=""></div>
                        <input type="submit" value="Subscribe" name="subscribe" id="mc-embedded-subscribe" class="newsletter-button">
                    </div>
                </form>
            </div>
            <!--End mc_embed_signup-->

        </div>
        <!--End Inlay Color-->
    </div>

    <p class="more_stories">
        <a href="#" class="pull_newsletter" title="Sign up for WHO updates">Sign up for WHO updates</a>
    </p>
</div>



<script type="text/javascript">
    //if (typeof contextually_load === "undefined") {
    //console.info("contextually not loaded ");
    //} else {
    // console.info("contextually loaded");
    //if(document.getElementById("ctx-module")){ 
    //Contextly.load();
    //if(document.getElementsByClassName("ctx-siderail-container")){ 
    //Contextly.load();
    //	console.info("Contextually loaded.");
    //} else {
    //	console.info("contextually not loaded");
    //}
    //}
    //}
    if (typeof show_contextly == 'undefined') {
        $(".ctx-siderail-container").remove();
        $(".ctx-clearfix").remove();
        //console.log("Removed DIV");
    }

    //to load Contextly in Topic Covers, Story and Publications pages for indexing where the div is not created 
    if (typeof load_contextly !== 'undefined' && load_contextly == 1) {
        Contextly.load();
        //console.log("Ctly loaded js")
    }


    jQuery(document).ready(function() {

        //ADDED for campaign button Ebola
        // campaignHighlight('http://www.who.int/campaigns/no-tobacco-day/2016/wntd-masthead-en.jpg','tobacco-day-2016','en');
        //     campaignHighlight('http://www.who.int/campaigns/hepatitis-day/2016/masthead-en.jpg','hepatitis-day-2016','en');
        /* function getRandomNumber(min, max){
        		return Math.floor(Math.random() * (max - min + 1)) + min;
        	}
        	var i1 = "http://www.who.int/campaigns/world-blood-donor-day/2016/masthead-girl-en.jpg";
        	var i2 = "http://www.who.int/campaigns/world-blood-donor-day/2016/masthead-boy-en.jpg";	          
        	var i3 = "http://www.who.int/campaigns/world-blood-donor-day/2016/masthead-woman-en.jpg";
        	var texts = [i1, i2, i3];
        	campaignHighlight(texts[getRandomNumber(0, texts.length-1)],'blood-day-2016','en');
        	*/
        var offset = 300;
        var duration = 500;
        jQuery(window).scroll(function() {
            if (jQuery(this).scrollTop() > offset) {
                jQuery('.back-to-top').fadeIn(duration);
            } else {
                jQuery('.back-to-top').fadeOut(duration);
            }
        });

        jQuery('.back-to-top').click(function(event) {
            event.preventDefault();
            jQuery('html, body').animate({
                scrollTop: 0
            }, duration);
            return false;
        })

        jQuery(".pull_newsletter").toggle(function() {
                jQuery("#newsletter").animate({
                    top: "0px"
                });
                return false;
            },
            function() {
                jQuery("#newsletter").animate({
                    top: "-147px"
                });
                return false;
            }
        ); //toggle

    });
</script>

<!--googleon: index-->

			</div>
			<!-- end: footer -->
			
		</div>
		<!-- end: wrapper -->

	</div>
	<!-- end: page -->
<script type="text/javascript">
        fixMenu();
</script> 



</body>
</html>
