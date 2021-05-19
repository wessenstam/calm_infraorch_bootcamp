#!/bin/bash

# Set the vars needed by the Calm Runbook variables
era_ip="@@{era_ip}@@"
era_user="@@{era_user}@@"
era_password="@@{era_password}@@"
initials="@@{initials}@@"

echo "Create snapshot FirstSnapshot_Runbook for $initials-FiestaDB-Lin"
# Get Era Custer ID
tms_uuid=$(curl --insecure --user $era_user:$era_password "https://$era_ip/era/v0.9/tms" --silent -H 'Content-Type: application/json' | jq --arg name $initials"-FiestaDB-Lin_TM" '.[] | select (.name==$name) .id' | tr -d \")

# Build the Payload
payload=$(cat <<EOF
{
    "name":"FirstSnapshot_Runbook"
}
EOF
)

# Register the Database of initials-FiestaDB
operation_id=$(curl --insecure --user $era_user:$era_password "https://$era_ip/era/v0.9/tms/$tms_uuid/snapshots" -X POST --data "${payload}" --silent -H 'Content-Type: application/json' | jq '.operationId' | tr -d \")

# Running small waiting loop 
counter=0
while true
do
    ((counter=counter+1))
    # Get the status of the task
    status=$(curl --insecure --user $era_user:$era_password "https://$era_ip/era/v0.9/operations/$operation_id" --silent -H 'Content-Type: application/json' | jq '.status' | tr -d \")
    
    if [[ "${status}" != 5 ]] && [[ "${status}" != 4 ]]
    then
        echo "Snapshot creation is still running $counter/15. Sleeping 1 minute before retrying..."
        sleep 60
    else
    	break
    fi
done

if [[ "${status}" == 5 ]]
then
    echo "Snapshot creation has been successfull."
    exit 0
else
    echo "Snapshot creation has not been successfull. Exiting"
    exit 1
fi