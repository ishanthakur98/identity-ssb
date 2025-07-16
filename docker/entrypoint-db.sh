#!/bin/bash
set -e

echo "Starting database operations..."
echo "SQL_DEPLOYMENT: $SQL_DEPLOYMENT"
echo "FIRST_DEPLOYMENT: $FIRST_DEPLOYMENT"

# Exit if no SQL deployment needed
if [[ "$SQL_DEPLOYMENT" != "yes" ]]; then
    echo "SQL_DEPLOYMENT is not 'yes', skipping database operations"
    exit 0
fi

# Validate required environment variables
required_vars=("DB_HOST" "DB_PORT" "DB_USER" "DB_PASS" "DB_NAME")
for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        echo "ERROR: Required environment variable $var is not set"
        exit 1
    fi
done

# Wait for database to be ready
echo "Waiting for database to be ready..."
until mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" > /dev/null 2>&1; do
    echo "Database not ready, waiting..."
    sleep 5
done

if [[ "$FIRST_DEPLOYMENT" == "yes" ]]; then
    echo "Running initial database schema creation..."
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /scripts/create_identityiq_tables-8.3.mysql
    
    echo "Running IIQ console import for initial setup..."
    cd /opt/tomcat/webapps/identityiq/WEB-INF/bin
    ./iiq console <<EOF
import init.xml
exit
EOF
else
    echo "Running custom configuration import..."
    cd /opt/tomcat/webapps/identityiq/WEB-INF/bin
    ./iiq console <<EOF
import sp.init-custom.xml
exit
EOF
fi

echo "Database operations completed successfully"