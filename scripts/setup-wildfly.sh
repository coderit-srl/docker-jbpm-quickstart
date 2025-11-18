#!/usr/bin/env bash

# If cli file not found, exit.
JBOSS_CLI=$JBOSS_HOME/bin/jboss-cli.sh
CLI_FILE=./setup.cli

if [ ! -f $CLI_FILE ]; then
    echo "Configuration file $CLI_FILE, does not exist, doing nothing."
    exit 0
fi

$JBOSS_CLI --file=$CLI_FILE