#!/usr/bin/env bash
## Java JDK 8 +U131 Solution
#  -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
# JAVA_OPTIONS="Xms300m"

webapps=/webapps

## fix GREENFIELD
greenfield=${GREENFIELD}
if [ $greenfield ];then
   if [ $greenfield = "run" ];then
      greenfield='run'
   else
      greenfield=''
   fi
fi

## fix MYSQL_ENV_FORCE
mysql_env_setup=${MYSQL_ENV_SETUP}
if [ $mysql_env_setup ];then
   if [ $mysql_env_setup = "force" ];then
      mysql_env_setup='force'
   else
      mysql_env_setup=''
   fi
fi

## copy config logback-spring.xml
if [ ! -d "$webapps/config" ];then
   mkdir -p "$webapps/config"
fi

if [ ! -f "$webapps/config/logback-spring.xml" ];then
   cp /tmp/logback-spring.xml $webapps/config
fi
if [ ! -f "$webapps/config/produce.yml" ];then
   cp /tmp/produce.yml $webapps/config
fi
if [ ! -f "$webapps/config/greenfield.yml" ];then
   cp /tmp/greenfield.yml $webapps/config
fi

if [ ! -f "$webapps/config/application.yml" ];then
   if [ $greenfield ];then
      cp $webapps/config/greenfield.yml $webapps/config/application.yml
   else
      cp $webapps/config/produce.yml $webapps/config/application.yml
   fi
else
   ## check if application.yml is cp from greenfield.yml
   result=$(cat $webapps/config/application.yml | grep greenfield)
   #result=${result// /}
   IFS=''
   if [ $result ];then
      cp $webapps/config/produce.yml $webapps/config/application.yml
   fi
   IFS=' '
fi


## fix url with ${URL}
#bash /usr/local/bin/fix_url.sh

#if [ ! -f "$webapps/deploy-lib.sh" ];then
#   cp /tmp/deploy-lib.sh $webapps
#fi

#if [ ! -f "$webapps/predeploy.sh" ];then
#   cp /tmp/predeploy.sh $webapps
#fi

#if [ ! -f "$webapps/deploy.sh" ];then
#   cp /tmp/deploy.sh $webapps
#fi

## config application.yml
if [ -f $webapps/config/application.yml ];then

   ## MYSQL env force update
   if [ ${mysql_env_setup} ];then

      #MYSQL_SERVER: 120.79.77.207
      #MYSQL_PORT: 3306
      #MYSQL_DATABASE: pay
      YAML=$webapps/config/application.yml

      if [ ${MYSQL_SERVER} ];then
         ## handle port
         mysql_port=''
         if [ ${MYSQL_PORT} ];then
            mysql_port=":${MYSQL_PORT}"
         fi

         if [ ${MYSQL_DATABASE} ];then
            mysql_db=${MYSQL_DATABASE}
            sed -i "s/jdbc:mysql:\/\/[[:digit:]]\+.[[:digit:]]\+.[[:digit:]]\+.[[:digit:]]\+:[[:digit:]]\+\/\w\+/jdbc:mysql:\/\/${MYSQL_SERVER}$mysql_port\/$mysql_db/" $YAML
         else
            sed -i "s/jdbc:mysql:\/\/[[:digit:]]\+.[[:digit:]]\+.[[:digit:]]\+.[[:digit:]]\+:[[:digit:]]\+/jdbc:mysql:\/\/${MYSQL_SERVER}$mysql_port/" $YAML
         fi
      fi

      if [ ${MYSQL_USER} ];then
         sed -i "s/username:.*/username: ${MYSQL_USER}/" $YAML
      fi

      if [ ${MYSQL_PASSWORD} ];then
         sed -i "s/password:.*/password: ${MYSQL_PASSWORD}/" $YAML
      fi
   fi ## mysql_env_force
fi



## copy service.sh to webapps
## do not need service.sh anymore
#if [ ! -e "$webapps/service.sh" ];then
#   cp /usr/local/bin/service.sh $webapps/service.sh
#fi

## run app
cd $webapps

runapp=''
apps=$(ls *.jar | wc -l)
if [ $apps = 1 ];then
   ## only one app, specific 8080 port
   for app in $(ls *.jar -t)
   do
      runapp=$app
      #break
   done

   ## check exists
   if [ -e $runapp ];then
      if [ $greenfield ];then
          echo "java -jar $runapp --spring.profiles.active=greenfield --server.port=8080"
          java -jar $runapp --spring.profiles.active=greenfield --server.port=8080
      else
          echo "nohup java -jar $runapp --spring.profiles.active=produce --server.port=8080 > /dev/null 2>&1 &"
          nohup java -jar $runapp --spring.profiles.active=produce --server.port=8080 > /dev/null 2>&1 &
      fi
   fi
fi

## start other endpoint
for ep in $(find . -name "*.jar");do

   wd=$(dirname $ep)
   if [ $wd = "." -o $wd = "./" ];then
      continue;
   fi

   cd $wd
   ep=$(basename $ep)

   ## start each endpoint
   if [ $greenfield ];then
      echo "java -jar $ep --spring.profiles.active=greenfield"
      java -jar $ep --spring.profiles.active=greenfield
   else
      echo "nohup java -jar $ep --spring.profiles.active=produce > /dev/null 2>&1 &"
      nohup java -jar $ep --spring.profiles.active=produce > /dev/null 2>&1 &
   fi

   ## go back
   cd $webapps
done

##
#/usr/sbin/nginx "-g" "daemon off;"
tail -f /dev/null
