FROM registry.access.redhat.com/ubi8/ubi

# Install JDK 8 and wget
RUN yum install -y java-1.8.0-openjdk wget unzip && \
    yum clean all

ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
ENV TOMCAT_VERSION=9.0.105

# Download and install Tomcat 9
RUN wget https://downloads.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt && \
    mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Copy the identityiq directory contents into Tomcat
COPY identityiq/ /opt/tomcat/webapps/identityiq/

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set permissions for OpenShift compatibility
RUN chmod -R g+rwX /opt/tomcat && \
    chown -R 1001:0 /opt/tomcat

EXPOSE 8080

USER 1001

ENTRYPOINT ["/entrypoint.sh"]