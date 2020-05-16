#Requires -RunAsAdministrator
<#
.SYNOPSIS
Issue Certs from specified internal CA

.DESCRIPTION
Issue Certs from specified internal CA
You must be Local Admin on the system where this runs.
You must haver rights on the CA to issue this type of certificate.

.EXAMPLE
Just run the script, and provide the requested CertName info.   
It will call the function and create a cert using the 'copy of web server' template.
Current version just works for FQDN, and ShortName.  No other SAN info.

.\New-CSR.ps1

.NOTES
Authors: Greg Onstot
Version: 0.0.5
Version Date: 07/23/19

#>
function New-BasicINF {
    param ($CertName, $ShortName, $CertTemplate)
   
    $myOutput = @"
;----------------- request.inf ----------------- 

[Version] 

Signature="$Windows NT$ 

[NewRequest]

Subject = "CN=$CertName,OU=YourORGTeam,O=YourORG,L=Seattle,S=Washington,C=US"

KeySpec = 1 
KeyLength = 2048 
; Can be 1024, 2048, 4096, 8192, or 16384. 
; Larger key sizes are more secure, but have 
; a greater impact on performance. 
Exportable = TRUE 
MachineKeySet = TRUE 
SMIME = False 
PrivateKeyArchive = FALSE 
UserProtected = FALSE 
UseExistingKeySet = FALSE 
ProviderName = "Microsoft RSA SChannel Cryptographic Provider" 
ProviderType = 12
RequestType = PKCS10 
KeyUsage = 0xa0 

[EnhancedKeyUsageExtension] 

OID=1.3.6.1.5.5.7.3.1 ; this is for Server Authentication 

;-----------------------------------------------

[Extensions]
; If your client operating system is Windows Server 2008, Windows Server 2008 R2, Windows Vista, or Windows 7
; SANs can be included in the Extensions section by using the following text format. Note 2.5.29.17 is the OID for a SAN extension.

2.5.29.17 = "{text}"
_continue_ = "dns=$ShortName&"
_continue_ = "dns=$CertName&"

[RequestAttributes] 
CertificateTemplate= "$CertTemplate"
"@
    $myOutput |Out-File "c:\temp\$ShortName-new.inf"

}

if (!(test-path 'C:\Temp\')) { mkdir c:\temp}

$filepath = "C:\Temp\$env:UserName"
if (!(test-path $filepath)) { 
    mkdir $filepath
    write-output 'User Folder did not exist...Created'
}

#Getinfo to create csr, and then cert
$ThisYear = (get-date).ToString('yyyyMMdd-hhmm')
$env:COMPUTERNAME
$CertName = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
$ShortName = $env:COMPUTERNAME
$CertTemplate = 'PKILab-WebServer'

#create the INF
New-BasicINF $CertName $ShortName $CertTemplate

#Use the INF to create the CSR
certreq -new "c:\temp\$ShortName-new.inf" c:\temp\$CertName-$ThisYear.csr

#submit the CSR to the CA
#If the end user needs self sevice but with SAN names, Comment out the next few lines and instead use the function from New-CerSubmission.ps1
$CsrPath = "c:\temp\$CertName-$ThisYear.csr"
$CertPath = "c:\temp\$CertName.cer"
certreq -submit -config EntCA1\PKILabEntCA01  $CsrPath $CertPath

#install the cert locally on your systems
Certreq -accept c:\temp\$CertName.cer

