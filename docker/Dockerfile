FROM registry.access.redhat.com/ubi8/ubi


# Install JDK 8 and wget
RUN yum install -y java-1.8.0-openjdk wget unzip && \
    yum clean all

# Install MySQL client
RUN yum install -y wget && \
    wget https://repo.mysql.com/mysql80-community-release-el8-1.noarch.rpm && \
    yum install -y --nogpgcheck mysql80-community-release-el8-1.noarch.rpm && \
    # Disable GPG check for MySQL repo
    sed -i 's/gpgcheck=1/gpgcheck=0/' /etc/yum.repos.d/mysql-community*.repo && \
    yum install -y mysql-community-client && \
    yum clean all

ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
ENV TOMCAT_VERSION=9.0.97

COPY identityiq/WEB-INF/database/create_identityiq_tables-8.3.mysql /scripts/create_identityiq_tables-8.3.mysql

# Replace all occurrences of mysql_native_password with caching_sha2_password
RUN sed -i 's/mysql_native_password/caching_sha2_password/g' /scripts/create_identityiq_tables-8.3.mysql

# Download and install Tomcat 9
RUN wget https://downloads.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz || \
    wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt && \
    mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Copy the identityiq directory contents into Tomcat
COPY identityiq/ /opt/tomcat/webapps/identityiq/

# Copy entrypoint scripts
COPY entrypoint-db.sh /entrypoint-db.sh
COPY entrypoint-app.sh /entrypoint-app.sh
RUN chmod +x /entrypoint-db.sh /entrypoint-app.sh

# Set permissions for OpenShift compatibility
RUN chmod -R g+rwX /opt/tomcat && \
    chown -R 1001:0 /opt/tomcat

EXPOSE 8080

USER 1001

ENTRYPOINT ["/entrypoint-app.sh"]