# Set the vars needed by the Calm Runbook variables
$era_ip="@@{era_ip}@@"
$era_user="@@{era_user}@@"
$era_passwd="@@{era_password}@@"
$snapshot_name="@@{snapshotname}@@"
$initials="@@{initials}@@"

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

write-host "Restoring snapshot $snapshot"

# Get the snapshots in Era and find the correct uuid for the database
$APIParams = @{
    method="GET"
    Uri="https://"+$era_ip+"/era/v0.9/snapshots"
    ContentType="application/json"
    Header = $Header
}
try{
    $response=(Invoke-RestMethod @APIParams)
}catch{
    sleep 10 # Sleeping 3 minutes before progressing
    $response=(Invoke-RestMethod @APIParams)
}
$snapshot_id=($response | where-object {$_.name -Match "$snapshot_name"}).id

# Get the uuid of the database
$APIParams = @{
    method="GET"
    Uri="https://"+$era_ip+"/era/v0.9/databases"
    ContentType="application/json"
    Header = $Header
}
try{
    $response=(Invoke-RestMethod @APIParams)
}catch{
    sleep 10 # Sleeping 3 minutes before progressing
    $response=(Invoke-RestMethod @APIParams)
}
$database_id=($response | where-object {$_.name -Match "$sinitials-FiestaDB-Win"}).id

$Payload=@"
{
    "snapshotId": "$snapshot_id",
    "latestSnapshot": null,
    "userPitrTimestamp": null,
    "actionArguments": [
      {
        "name": "sameLocation",
        "value": "true"
      }
    ]
  }

"@

# Start restore of the database
$APIParams = @{
    method="POST"
    Uri="https://"+$era_ip+"/era/v0.9/databases/"+$database_id+"/restore"
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

Start-Sleep 30

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
    Write-Host "Restore is still in progress.. Sleeping 1 minute before retrying ($counter/15)."
    start-sleep 60
    if ($counter -lt 15){
        $response=(Invoke-RestMethod @APIParams)
    }else{
        Write-Host "We waited 15 minutes and the Database has not been restored. Exiting..."
        exit 1
    }
    $counter++
}
if ($response.status -eq 5){
    Write-Host "Restore has been successfull."
    exit 0
}else{
    Write-Host "Restore has not been successfull. Exiting"
    exit 1
}