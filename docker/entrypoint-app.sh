#!/bin/bash
set -e

echo "Starting IdentityIQ application..."

# Wait for database to be ready
echo "Waiting for database to be ready..."
until mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" > /dev/null 2>&1; do
    echo "Database not ready, waiting..."
    sleep 5
done

# Start Tomcat
echo "Starting Tomcat server..."
exec /opt/tomcat/bin/catalina.sh run