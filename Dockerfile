FROM quay.io/kiegroup/jbpm-server-full:latest

# Copy custom configuration scripts
COPY --chown=jboss:jboss scripts/* /opt/jboss/wildfly/bin/
COPY --chown=jboss:jboss jbpm-config/bc-overlay/ /opt/jbpm-config/bc-overlay/

# Make scripts executable
RUN chmod +x /opt/jboss/wildfly/bin/*.sh

RUN curl -o $HOME/keycloak-wildfly-adapter.zip https://repo1.maven.org/maven2/org/keycloak/keycloak-wildfly-adapter-dist/18.0.2/keycloak-wildfly-adapter-dist-18.0.2.zip \
    && unzip $HOME/keycloak-wildfly-adapter.zip -d $JBOSS_HOME \
    && rm $HOME/keycloak-wildfly-adapter.zip

# Expose ports
EXPOSE 8080 9990 8001