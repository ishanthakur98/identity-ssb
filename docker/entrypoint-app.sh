#!/bin/bash
set -e

echo "Starting IdentityIQ application..."

# Check and create upload directory if it doesn't exist
UPLOAD_FILE_PATH=${UPLOAD_FILE_PATH:-"/opt/tomcat/webapps/identityiq/WEB-INF/uploads"}
if [ ! -d "$UPLOAD_FILE_PATH" ]; then
    echo "Creating upload directory: $UPLOAD_FILE_PATH"
    mkdir -p "$UPLOAD_FILE_PATH"
    chmod 775 "$UPLOAD_FILE_PATH"
fi

# Check and create full-text index directory if it doesn't exist
FULL_TEXT_INDEX_PATH=${FULL_TEXT_INDEX_PATH:-"/opt/tomcat/webapps/identityiq/WEB-INF/index"}
if [ ! -d "$FULL_TEXT_INDEX_PATH" ]; then
    echo "Creating full-text index directory: $FULL_TEXT_INDEX_PATH"
    mkdir -p "$FULL_TEXT_INDEX_PATH"
    chmod 775 "$FULL_TEXT_INDEX_PATH"
fi

# Replace DB_PASS
sed -i "s/DUMMY_DB_PASSWORD/$DB_PASS/g" /opt/tomcat/webapps/identityiq/WEB-INF/classes/iiq.properties

# Replace DB_URL
sed -i "s/DUMMY_DB_URL/$DB_HOST/g" /opt/tomcat/webapps/identityiq/WEB-INF/classes/iiq.properties

# Replace DB_USERNAME
sed -i "s/DUMMY_DB_USERNAME/$DB_USER/g" /opt/tomcat/webapps/identityiq/WEB-INF/classes/iiq.properties

# Replace DB_PORT
sed -i "s/DUMMY_DB_PORT/$DB_PORT/g" /opt/tomcat/webapps/identityiq/WEB-INF/classes/iiq.properties

echo "priniting file logs started"
cat /opt/tomcat/webapps/identityiq/WEB-INF/classes/iiq.properties
echo "priniting file logs ended"

# Wait for database to be ready
echo "Waiting for database to be ready..."
until mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" > /dev/null 2>&1; do
    echo "Database not ready, waiting..."
    sleep $DB_WAIT_TIME
done

# Set Java heap size if not already set (optimized for 32GB pod)
JAVA_OPTS=${JAVA_OPTS:-"-Xms24g -Xmx24g"}

# LDAP Specific customization - Environment Variables
export JAVA_OPTS="$JAVA_OPTS -Dcom.sun.jndi.ldap.connect.pool.timeout=300000"
export JAVA_OPTS="$JAVA_OPTS -Dcom.sun.jndi.ldap.connect.pool.protocol=ssl"
export JAVA_OPTS="$JAVA_OPTS -Dcom.sun.jndi.ldap.connect.pool.authentication=simple"
export JAVA_OPTS="$JAVA_OPTS -Dcom.sun.jndi.ldap.connect.pool.maxsize=10"

# Set additional Java options
# Adds G1 garbage collector for better performance
# Enables string deduplication to reduce memory usage
# Uses /dev/urandom for faster startup
export CATALINA_OPTS="$JAVA_OPTS -XX:+UseG1GC -XX:+UseStringDeduplication -Djava.security.egd=file:/dev/./urandom"

# Add LDAP options to CATALINA_OPTS as well
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.jndi.ldap.connect.pool.timeout=300000"
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.jndi.ldap.connect.pool.protocol=ssl"
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.jndi.ldap.connect.pool.authentication=simple"
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.jndi.ldap.connect.pool.maxsize=10"

# Start Tomcat
echo "Starting Tomcat server with options: $CATALINA_OPTS"
exec /opt/tomcat/bin/catalina.sh run