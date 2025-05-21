FROM registry.access.redhat.com/ubi8/ubi

# Install JDK 8 and wget
RUN yum install -y java-1.8.0-openjdk wget unzip && \
    yum clean all

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk

# Download and install Tomcat 9
ENV TOMCAT_VERSION=9.0.105

RUN wget https://downloads.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt && \
    mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Copy the WAR file into Tomcat webapps directory
COPY ../build/deploy/identityiq.war /opt/tomcat/webapps/

# Set permissions for OpenShift compatibility
RUN chmod -R g+rwX /opt/tomcat && \
    chown -R 1001:0 /opt/tomcat

# Expose Tomcat port
EXPOSE 8080

# Use non-root user for OpenShift
USER 1001

# Start Tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
