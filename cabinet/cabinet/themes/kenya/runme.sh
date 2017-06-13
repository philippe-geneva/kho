#!/bin/sh 

echo "Copying GHO data system menu file to hqsudevlin."
scp -q kenya-nho.xml ghouser@hqsudevlin.who.int:~/htdocs/jakarta-tomcat/webapps/data/WEB-INF/menus/kenya-nho.xml

echo "Restarting Minerva on hqsudevlin."
ssh ghouser@hqsudevlin.who.int "touch ~/htdocs/jakarta-tomcat/webapps/data/WEB-INF/web.xml"

echo "Copying kenya menu file to Minerva"
cp kenya-nho.xml ../../../../minerva/setup
