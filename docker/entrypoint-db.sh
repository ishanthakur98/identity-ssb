#!/bin/bash
set -e

echo "Starting database operations..."
echo "DB_DEPLOYMENT: $DB_DEPLOYMENT"
echo "INITIAL_DEPLOYMENT: $INITIAL_DEPLOYMENT"


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
    sleep $DB_WAIT_TIME
done

if [[ "$INITIAL_DEPLOYMENT" == "yes" ]]; then
    
    echo "Running IIQ console import for initial setup..."
    cd /opt/tomcat/webapps/identityiq/WEB-INF/bin
    chmod +x ./iiq

    ./iiq schema
    sed -i 's/mysql_native_password/caching_sha2_password/g' /opt/tomcat/webapps/identityiq/WEB-INF/database/create_identityiq_tables-8.3.mysql
    
    echo "Running initial database schema creation..."
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /opt/tomcat/webapps/identityiq/WEB-INF/database/create_identityiq_tables-8.3.mysql
    
    ./iiq console <<EOF
    import init.xml
    exit
EOF
elif [[ "$DB_DEPLOYMENT" == "yes" ]]; then
    chmod +x ./iiq

    echo "Running custom configuration import..."
    cd /opt/tomcat/webapps/identityiq/WEB-INF/bin
    ./iiq console <<EOF
import sp.init-custom.xml
exit
EOF
fi

echo "Database operations completed successfully"
exit 0  # Explicitly exit after DB operations