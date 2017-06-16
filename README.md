# Kenya National Health Observatory

The Kenya NHO proof of concept is constructed from GHO components.  These components have been stripped down to make the proof of concept easier to manage.

Requirements:

1. Java 1.7 or better
2. Tomcat 7 or better
3. git client
4. ant
5. bash shell

Note - if on windows, you may wish to install cygwin 

Installation instructions:

Step 1:  Install required software


Step 2:  Get a copy of the KHO from github

Step 3:  Install sql lite driver in tomcat lib directory:
         You can find the driver in the lib directory of the tableau-public
         or the cabinet project

Step 4:  Build minerva, cabinet, and tableau-public
         In each subproject directory, run the command ant.  This will
         create data.war, cabinet.war, and tableau-public.war in
         the respective dist subdirectories

Step 5:  Start the comcat server:

         cd <TOMCAT_INSTALLATION>/bin
         ./catalina.sh start

Step 6:  Copy the war files you created in Step 4 to 
         <TOMCAT_INSTALLATION>/webapps


Configuration:

Different aspects of the proof of concept are configured using different 
GHO components:

Modifying the home page and adding new drawers or sets of drawers:
This is controlled by the cabinet component.  In order to add a section of
drawers and/or individual drawers, edit the files CabinetSection.csv and
CabinetSubSection.csv.  The documentation of the component provides an 
explanation of the configuration files.  If you wish to edit the structure of the main page, it is found under cabinet/cabinet/kenya.jsp and includes components from cabinet/cabinet/themes/kenya.

If you wish to modify the menus found inside each cabinet, edit the file
kenya-nho.xml which is found in minerva/setup/kenya-nho.xml.  Instructions on 
the file format are provided in minerva's documentation.

In order to include a new tableau-public visualization, first create the 
visualization and publish it to TableauPublic, then edit the file viz.csv to
add a new entry.  The file is found in tableau-public/viz.csv.  In order
to identify the visualization, use the last two path components from the 
"share" URL of the visualization.

In all cases, in order to apply the updated configurations, you must rebuild 
the specific component with the ant command and copy the war file to you
tomcat/webapps directory


Assuming the whole system is running on a single desktop, the application 
link becomes http://localhost:8080/cabinet/kenya.jsp


