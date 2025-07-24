FROM ishanthakur1998/iiq-base:latest

# Copy the identityiq directory contents into Tomcat
COPY identityiq/ /opt/tomcat/webapps/identityiq/

# Create scripts directory
RUN mkdir -p /scripts

# Copy entrypoint scripts
COPY entrypoint-app.sh /scripts/app.sh
COPY entrypoint-db.sh /scripts/db.sh
RUN chmod +x /scripts/app.sh /scripts/db.sh

# Create identityiq user and set permissions for OpenShift compatibility
RUN useradd -u 1001 identityiq && \
    chmod -R g+rwX /opt/tomcat && \
    chown -R identityiq:0 /opt/tomcat /scripts

EXPOSE 8080

USER identityiq

# No default entrypoint - let Kubernetes specify the command