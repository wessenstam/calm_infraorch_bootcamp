# Set the vars needed by the Calm Runbook variables
$era_ip="@@{era_ip}@@"
$era_user="@@{era_user}@@"
$era_passwd="@@{era_password}@@"
$snapshot_name="@@{snapshotname}@@"
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

Write-Host "Checking if the snapshot given exists"
# Get the snapshots in Era
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

if ($snapshot_id -eq $null){
	exit 1
}else{
	exit 0
}