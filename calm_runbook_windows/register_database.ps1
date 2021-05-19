# Set the vars needed by the Calm Runbook variables
$era_ip="@@{era_ip}@@"
$era_user="@@{era_user}@@"
$era_passwd="@@{era_password}@@"
$initials="@@{initials}@@"

$host_ip=(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).IPaddress


$Header=@{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($era_user+":"+$era_passwd));}

# Getting the HTTPS working with self-signed certificates
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

Write-Host "Our FiestaDB has not been found in Era"
Write-Host "Registering the FiestaDB in Era"

# Get the Era cluster ID
$APIParams = @{
    method="GET"
    Uri="https://"+$era_ip+"/era/v0.9/clusters"
    ContentType="application/json"
    Header = $Header
}
try{
    $response=(Invoke-RestMethod @APIParams)
}catch{
    sleep 10 # Sleeping 3 minutes before progressing
    $response=(Invoke-RestMethod @APIParams)
}
$cluster_uuid=($response | where-object {$_.name -Match "EraCluster"}).id

# Get the UUID of the Bronze SLA
$APIParams = @{
    method="GET"
    Uri="https://"+$era_ip+"/era/v0.9/slas"
    ContentType="application/json"
    Header = $Header
}
try{
    $response=(Invoke-RestMethod @APIParams)
}catch{
    sleep 10 # Sleeping 3 minutes before progressing
    $response=(Invoke-RestMethod @APIParams)
}
$sla_uuid=($response | where-object {$_.name -Match "DEFAULT_OOB_BRONZE_SLA"}).id


# Build the payload json for Era
$Payload=@"
{
"actionArguments": [
{
    "name": "era_manage_log",
    "value": true
},
{
    "name": "sql_login_used",
    "value": false
},
{
    "name": "same_as_admin",
    "value": true
},
{
    "name": "recovery_model",
    "value": "Full-logged"
},
{
    "name": "vmIp",
    "value": "$host_ip"
},
{
    "name": "sysadmin_username_win",
    "value": "Administrator"
},
{
    "name": "sysadmin_password_win",
    "value": "Nutanix/4u"
},
{
    "name": "instance_name",
    "value": "MSSQLSERVER"
},
{
    "name": "database_name",
    "value": "FiestaDB"
}
],
"nxClusterId": "$cluster_uuid",
"databaseType": "sqlserver_database",
"databaseName": "$initials-FiestaDB-Win",
"description": "",
"clustered": false,
"forcedInstall": true,
"category": "DEFAULT",
"vmIp": "$host_ip",
"vmUsername": "Administrator",
"vmPassword": "Nutanix/4u",
"vmSshkey": "",
"vmDescription": "",
"autoTuneStagingDrive": false,
"workingDirectory": "c:\\",
"timeMachineInfo": {
"autoTuneLogDrive": true,
"slaId": "$sla_uuid",
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
    "dayOfWeek": "MONDAY"
    },
    "monthlySchedule": {
    "enabled": true,
    "dayOfMonth": "17"
    },
    "quartelySchedule": {
    "enabled": true,
    "startMonth": "JANUARY",
    "dayOfMonth": "17"
    },
    "yearlySchedule": {
    "enabled": false,
    "dayOfMonth": 31,
    "month": "DECEMBER"
    }
},
"tags": [],
"name": "$initials-FiestaDB-Win_TM"
},
"tags": []
}
"@
# Register the Database of initials-FiestaDB
$APIParams = @{
    method="POST"
    Uri="https://"+$era_ip+"/era/v0.9/databases/register"
    ContentType="application/json"
    Body=$Payload
    Header = $Header
}
try{
    $response=(Invoke-RestMethod @APIParams)
}catch{
    sleep 10 # Sleeping 3 minutes before progressing
    $response=(Invoke-RestMethod @APIParams)
}
$operation_id=$response.operationId

# Small loop so we wait for the registration to happen
$APIParams = @{
    method="GET"
    Uri="https://"+$era_ip+"/era/v0.9/operations/"+$operation_id
    ContentType="application/json"
    Header = $Header
}
try{
    $response=(Invoke-RestMethod @APIParams)
}catch{
    sleep 10 # Sleeping 3 minutes before progressing
    $response=(Invoke-RestMethod @APIParams)
}
$counter=0
while ($response.status -ne 5 -and $response.status -ne 4){
    Write-Host "Registration is still in progress.. Sleeping 1 minute before retrying ($counter/15)."
    start-sleep 60
    if ($counter -lt 15){
        $response=(Invoke-RestMethod @APIParams)
    }else{
        Write-Host "We waited 15 minutes and the Database has not been registered. Exiting..."
        exit 1
    }
    $counter++
}
if ($response.status -eq 5){
    Write-Host "Registration has been successfull."
    exit 0
}else{
    Write-Host "Registration has not been successfull. Exiting"
    exit 1
}