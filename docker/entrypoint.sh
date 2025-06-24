#!/bin/bash
set -e

if [[ "$SQL_DEPLOYMENT" == "yes" && "$FIRST_DEPLOYMENT" == "yes" ]]; then
  cd /opt/tomcat/webapps/identityiq/WEB-INF/bin
  ./iiq console <<EOF
import init.xml
exit
EOF
elif [[ "$SQL_DEPLOYMENT" == "yes" && "$FIRST_DEPLOYMENT" == "no" ]]; then
  cd /opt/tomcat/webapps/identityiq/WEB-INF/bin
  ./iiq console <<EOF
import sp.init-custom.xml
exit
EOF
else
  # Both flags are "no", just start Tomcat
  exec /opt/tomcat/bin/catalina.sh run
fi