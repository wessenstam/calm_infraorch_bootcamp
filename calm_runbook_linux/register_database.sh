#!/bin/bash

# Set the vars needed by the Calm Runbook variables
era_ip="@@{era_ip}@@"
era_user="@@{era_user}@@"
era_password="@@{era_password}@@"
initials="@@{initials}@@"
hostip=$(hostname -I)
host_ip=${hostip::-1}

# Get Era Custer ID
era_id=$(curl --insecure --user $era_user:$era_password "https://$era_ip/era/v0.9/clusters" --silent -H 'Content-Type: application/json' | jq --arg name "EraCluster" '.[] | select (.name==$name) .id' | tr -d \")

# Get the UUID of the Bronze SLA
sla_id=$(curl --insecure --user $era_user:$era_password "https://$era_ip/era/v0.9/slas" --silent -H 'Content-Type: application/json' | jq --arg name "DEFAULT_OOB_BRONZE_SLA" '.[] | select (.name==$name) .id' | tr -d \")

# Build the payload json for Era
payload=$(cat <<EOF
{
  "actionArguments": [
    {
      "name": "listener_port",
      "value": "3306"
    },
    {
      "name": "db_user",
      "value": "root"
    },
    {
      "name": "vmIp",
      "value": "${host_ip}"
    },
    {
      "name": "software_home",
      "value": "/usr"
    },
    {
      "name": "db_name",
      "value": "FiestaDB"
    },
    {
      "name": "db_password",
      "value": "nutanix/4u"
    }
  ],
  "nxClusterId": "${era_id}",
  "databaseType": "mariadb_database",
  "databaseName": "${initials}-FiestaDB-Lin",
  "description": "",
  "clustered": false,
  "forcedInstall": true,
  "category": "DEFAULT",
  "vmIp": "${host_ip}",
  "vmUsername": "centos",
  "vmPassword": "nutanix/4u",
  "vmSshkey": "",
  "vmDescription": "",
  "autoTuneStagingDrive": true,
  "workingDirectory": "/tmp",
  "timeMachineInfo": {
    "autoTuneLogDrive": true,
    "slaId": "${sla_id}",
    "schedule": {
      "snapshotTimeOfDay": {
        "hours": 1,
        "minutes": 0,
        "seconds": 0
      },
      "continuousSchedule": {
        "enabled": true,
        "logBackupInterval": 30,
        "snapshotsPerDay": 1
      },
      "weeklySchedule": {
        "enabled": true,
        "dayOfWeek": "TUESDAY"
      },
      "monthlySchedule": {
        "enabled": true,
        "dayOfMonth": "18"
      },
      "quartelySchedule": {
        "enabled": true,
        "startMonth": "JANUARY",
        "dayOfMonth": "18"
      },
      "yearlySchedule": {
        "enabled": false,
        "dayOfMonth": 31,
        "month": "DECEMBER"
      }
    },
    "tags": [],
    "name": "${initials}-FiestaDB-Lin_TM"
  },
  "tags": []
}
EOF
)


# Register the Database of initials-FiestaDB
operation_id=$(curl --insecure --user $era_user:$era_password "https://$era_ip/era/v0.9/databases/register" -X POST --data "${payload}" --silent -H 'Content-Type: application/json' | jq '.operationId' | tr -d \")

# Running small waiting loop 
counter=0
while true
do
    ((counter=counter+1))
    # Get the status of the task
    status=$(curl --insecure --user $era_user:$era_password "https://$era_ip/era/v0.9/operations/$operation_id" --silent -H 'Content-Type: application/json' | jq '.status' | tr -d \")
    
    if [[ "${status}" != 5 ]] && [[ "${status}" != 4 ]]
    then
        echo "Registration is still running $counter/15. Sleeping 1 minute before retrying..."
        sleep 60
    else
    	break
    fi
done

if [[ "${status}" == 5 ]]
then
    echo "Registration has been successfull."
    exit 0
else
    echo "Registration has not been successfull. Exiting"
    exit 1
fi