Copy-Item .\CAPolicy.inf C:\Windows

Write-Output 'Make sure you logged on with the domain admin account to be able to stand up the enterprise PKI.  Whoami should return pkilab\myladmin.  IF not, press CTRL-C to exit, then log back in.'
whoami.exe
Pause

Get-Disk | 
Where-Object partitionstyle -eq 'raw' | 
Initialize-Disk -PartitionStyle MBR -PassThru |
New-Partition -DriveLetter F -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false


mkdir F:\CertLog
mkdir F:\CertDB

Add-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
$CAParms = @{
    CACommonName = 'PKILabEntCA01'
    CAType = 'EnterpriseSubordinateCA'
    DatabaseDirectory = 'F:\CertDB'
    LogDirectory = 'F:\CertLog'
    OutputCertRequestFile = "C:\ENTCA01.req"
}

Install-ADcsCertificationAuthority @CAParms -OverwriteExistingKey -AllowAdministratorInteraction -Verbose #-WhatIf

Add-CACRLDistributionPoint -Uri http://crl1.pkilab.local/pkilab/PKILab-RootCA%8%9.crl -AddToCertificateCDP -AddToFreshestCrl -Force
Remove-CACrlDistributionPoint 'ldap:///CN=<CATruncatedName><CRLNameSuffix>,CN=<ServerShortName>,CN=CDP,CN=Public Key Services,CN=Services,<ConfigurationContainer><CDPObjectClass>' -Force
Remove-CACrlDistributionPoint 'http://<ServerDNSName>/CertEnroll/<CaName><CRLNameSuffix><DeltaCRLAllowed>.crl' -Force
Remove-CACrlDistributionPoint 'file://<ServerDNSName>/CertEnroll/<CaName><CRLNameSuffix><DeltaCRLAllowed>.crl' -Force

Add-CAAuthorityInformationAccess  -Uri http://crl1.pkilab.local/pkilab/<ServerDNSName>_<CaName><CertificateName>.crt -AddToCertificateAia -Force
Remove-CAAuthorityInformationAccess 'ldap:///CN=<CATruncatedName>,CN=AIA,CN=Public Key Services,CN=Services,<ConfigurationContainer><CAObjectClass>' -Force
Remove-CAAuthorityInformationAccess 'http://<ServerDNSName>/CertEnroll/<ServerDNSName>_<CAName><CertificateName>.crt' -Force
Remove-CAAuthorityInformationAccess 'file://<ServerDNSName>/CertEnroll/<ServerDNSName>_<CAName><CertificateName>.crt' -Force

certutil -crl

certsrv.msc
Explorer C:\Windows\System32\CertSrv\CertEnroll

#Remove-WindowsFeature Adcs-Cert-Authority

Add-LocalGroupMember -Group 'administrators' -Member 'pkilab\sec-PKIAdmins'

#Create a Scheduled task to Publish the CRL
#Get user credential so that the job has access to the network
$cred = Get-Credential -Credential pkilab\myCA_svc
$ClearPass = $cred.GetNetworkCredential().password
$action = New-ScheduledTaskAction -Execute 'C:\Scripts\New-DailyCRL.bat'
$trigger = New-ScheduledTaskTrigger -Daily -At 6am
$task = New-ScheduledTask -Action $action -Trigger $trigger
$Task | Register-ScheduledTask -TaskName 'PublishCRL' -User 'pkilab\myCA_svc' -Password $ClearPass 

#gpedit.msc
