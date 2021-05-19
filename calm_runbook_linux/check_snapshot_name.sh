#!/bin/bash

# Set the vars needed by the Calm Runbook variables
era_ip="@@{era_ip}@@"
era_user="@@{era_user}@@"
era_password="@@{era_password}@@"
initials="@@{initials}@@"
snapshotname="@@{snapshotname}@@"

echo "Checking if there is a snapshot with the name $snapshotname"

snapshot_id=$(curl --insecure --user $era_user:$era_password "https://$era_ip/era/v0.9/snapshots" --silent -H 'Content-Type: application/json' | jq --arg name $snapshotname '.[] | select (.name==$name) .id' | tr -d \")

if [[ -z $snapshot_id ]]
then
    exit 1
else    
    exit 0
fi