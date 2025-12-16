#!/usr/bin/env bash

CLI_FILE=./quartz-ds-config.cli

sed -i "s/--user-name=jbpm/--user-name=$JBPM_DB_USER/" $CLI_FILE
sed -i "s/--password=jbpm/--password=$JBPM_DB_PASSWORD/" $CLI_FILE
sed -i "s/ServerName=localhost/ServerName=$JBPM_DB_HOST/" $CLI_FILE
sed -i "s/DatabaseName=jbpm/DatabaseName=$JBPM_DB_NAME/" $CLI_FILE
sed -i "s/PortNumber=5432/PortNumber=$JBPM_DB_PORT/" $CLI_FILE

./jboss-cli.sh --file=$CLI_FILE