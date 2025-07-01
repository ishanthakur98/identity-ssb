#!/bin/bash
set -e

#ORACLE_CONN_STRING="${ORACLE_USER}/${ORACLE_PASSWORD}@${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SID}"

if [[ "$SQL_DEPLOYMENT" == "yes" && "$FIRST_DEPLOYMENT" == "yes" ]]; then
  # Run Oracle DB script
  cd /opt/tomcat/webapps/identityiq/WEB-INF/database
#  sqlplus -S "$ORACLE_CONN_STRING" @create_identityiq_tables-8.3.oracle
   echo "Running MySQL schema script..."
  mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /scripts/create_identityiq_tables-8.3.mysql

  # Run IIQ console import
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