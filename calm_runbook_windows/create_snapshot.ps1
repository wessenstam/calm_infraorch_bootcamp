# Set the vars needed by the Calm Runbook variables
$era_ip="@@{era_ip}@@"
$era_user="@@{era_user}@@"
$era_passwd="@@{era_password}@@"
$initials="@@{initials}@@"
$snapshotname="@@{snapshotname}@@"

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

Write-Host "Creating snapshot FirstSnapshot_Runbook for $initials-FiestaDB-Win"

# Get the TMS ID of the FiestaDB Time Machine
$APIParams = @{
    method="GET"
    Uri="https://"+$era_ip+"/era/v0.9/tms"
    ContentType="application/json"
    Header = $Header
}
try{
    $response=(Invoke-RestMethod @APIParams)
}catch{
    sleep 10 # Sleeping 3 minutes before progressing
    $response=(Invoke-RestMethod @APIParams)
}
$tms_uuid=($response | where-object {$_.name -Match "$initials-FiestaDB-Win_TM"}).id

# Build the Payload
$Payload=@"
{
    "name":"$snapshotname"
}
"@

$APIParams = @{
    method="POST"
    Uri="https://"+$era_ip+"/era/v0.9/tms/"+$tms_uuid+"/snapshots"
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

# Give Era some time to start the process
Start-Sleep 30 

# Small loop so we wait for the snapshot to happen
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
    Write-Host "Snapshot creation is still in progress.. Sleeping 1 minute before retrying ($counter/15)."
    start-sleep 60
    if ($counter -lt 15){
        $response=(Invoke-RestMethod @APIParams)
    }else{
        Write-Host "We waited 15 minutes and the Snapshot creation has not succeeded. Exiting..."
        exit 1
    }
    $counter++
}
if ($response.status -eq 5){
    Write-Host "Snapshot creation has been successfull."
    exit 0
}else{
    Write-Host "Snapshot creation has not been successfull. Exiting"
    exit 1
}