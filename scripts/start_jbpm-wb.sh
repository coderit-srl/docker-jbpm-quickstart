#!/usr/bin/env bash

# Start Wildfly with the given arguments.
echo "Update database connection setup"
./update_db_config.sh

echo "Running standard customization script"
./setup-wildfly.sh

echo "Running keycloak adapter install script"
CLI_FILE="adapter-elytron-install-offline.cli" ./setup-wildfly.sh

echo "Running JBPM keycloak adapter integration script"
CLI_FILE="jbpm-keycloak-setup.cli" ./setup-wildfly.sh

CUSTOM_CLI_FILE=${CUSTOM_CLI_FILE:-custom.cli}
echo "Running custom init script"
CLI_FILE=${CUSTOM_CLI_FILE} ./setup-wildfly.sh

echo "Running jBPM Server Full on JBoss Wildfly..."
exec ./standalone.sh -b $JBOSS_BIND_ADDRESS $EXTRA_OPTS -Dorg.kie.server.location=$KIE_SERVER_LOCATION \
  -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true \
  -Dkeycloak.authServer=${KEYCLOAK_URL} \
  -Dorg.uberfire.ext.security.management.api.userManagementServices=KCAdapterUserManagementService \
  -Dorg.uberfire.ext.security.management.keycloak.authServer=${KEYCLOAK_URL} \
  -Dorg.uberfire.ext.security.management.keycloak.use-resource-role-mappings=true \
  -Dorg.uberfire.ext.security.management.keycloak.resource=kie
exit $?