#!/bin/bash

# Set the vars needed by the Calm Runbook variables
era_ip="@@{era_ip}@@"
era_user="@@{era_user}@@"
era_password="@@{era_password}@@"
initials="@@{initials}@@"

echo "Checking if the FiestaDB is registered"

database_id=$(curl --insecure --user $era_user:$era_password "https://$era_ip/era/v0.9/databases" --silent -H 'Content-Type: application/json' | jq --arg name $initials"-FiestaDB-Lin" '.[] | select (.name==$name) .id' | tr -d \")

if [ -z $database_id ]
then
    exit 1
else
    exit 0
fi