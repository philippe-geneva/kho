Cabinet
=======


 
This application creates a set of drawers divided into sections.  Each drawer contains
a link pointing to a visualization.  One drawer is opened by the user at a time, when
opening a new drawer, the previous drawer is closed


Configuration
=============

Edit the CSV files Cabinet.csv , CabinetSection.csv , CabinetRelatedLinks.csv
and CabinetSubSection.csv.  Main sections, must have a colour that can be overiden
by specifying a colour for a particular subsection. 

IDs must be unique for each file

For a section to appear, you must set the Status column to "published". If you wish to
hide the section, change the Status to not-published.

Components
==========

cabinet-widget.jsp
		Is the cabinet widget implementation

cabinet.jsp
		An example wrapper that provides headers and footers around a cabinet 
		instance.

uhc.jsp	
		The universal health coverage data portal page

hss.jsp  
                The health systems portal page

pc.jsp 
                The preventive chemotherapy page for neglected tropical diseases

gvap.jsp
                The global vaccination strategic plan page




