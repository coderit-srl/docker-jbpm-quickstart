#!/usr/bin/env bash

# If cli file not found, exit.
JBOSS_CLI=$JBOSS_HOME/bin/jboss-cli.sh
CLI_FILE=${CLI_FILE:-./setup.cli}

if [ ! -f $CLI_FILE ]; then
    echo "Configuration file $CLI_FILE, does not exist, doing nothing."
    exit 0
fi

echo "Running configuration file $CLI_FILE"
$JBOSS_CLI --file=$CLI_FILE