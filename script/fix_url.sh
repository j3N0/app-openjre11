#!/usr/bin/env bash

webapps=/webapps

## debug
#webapps=/home/power/dockerfiles/allin-web
##

#export URL_SHORT='mysqlserver:3307\/db_name'
#export USERNAME=root1
#export PASSWORD=root1
#export GREENFIELD=run
#cp $webapps/config/produce.yml $webapps/config/application.yml
#cat $webapps/config/application.yml | grep url

if [ -f $webapps/config/application.yml ];then
   username=${USERNAME}
   password=${PASSWORD}
   mysqlurl=${URL_SHORT/\//\\\/}

   if [ ${URL_SHORT} ];then
       if [ ! $username ];then
         username=root
       fi
       if [ ! $password ];then
         password=root
       fi

       #jdbc:mysql://127.0.0.1:3306/test?
       sed -i "s/url: jdbc:mysql:\/\/[0-9\.a-z:]*\/[a-z\_]*/url: jdbc:h2:\/\/$mysqlurl/" $webapps/config/application.yml
       ##
       sed -i "s/username:.*/username: $username/" $webapps/config/application.yml
       sed -i "s/password:.*/password: $password/" $webapps/config/application.yml

       if [ $GREENFIELD ];then
          sed -i "s/initialize:.*/initialize: true/" $webapps/config/application.yml
       else
          sed -i "s/initialize:.*/initialize: false/" $webapps/config/application.yml
       fi
   fi
fi
