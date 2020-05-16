Copy-Item .\CAPolicy.inf C:\Windows

Get-Disk | 
Where-Object partitionstyle -eq 'raw' | 
Initialize-Disk -PartitionStyle MBR -PassThru |
New-Partition -DriveLetter F -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false


mkdir F:\CertLog
mkdir F:\CertDB


Add-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
$CAParms = @{
    CACommonName = 'PKILab-RootCA'
    CAType = 'StandaloneRootCa'
    DatabaseDirectory = 'F:\CertDB'
    LogDirectory = 'F:\CertLog'
    ValidityPeriodUnits = '30'
}

#Install-AdcsCertificationAuthority -CAType StandaloneRootCa -CACommonName PKILab-RootCA -ValidityPeriodUnits 30
Install-ADcsCertificationAuthority @CAParms -Verbose #-WhatIf

Add-CACRLDistributionPoint -Uri http://crl1.pkilab.local/pkilab/PKILab-RootCA%8%9.crl -AddToCertificateCDP -AddToFreshestCrl -Force
Remove-CACrlDistributionPoint 'ldap:///CN=<CATruncatedName><CRLNameSuffix>,CN=<ServerShortName>,CN=CDP,CN=Public Key Services,CN=Services,<ConfigurationContainer><CDPObjectClass>' -Force
Remove-CACrlDistributionPoint 'http://<ServerDNSName>/CertEnroll/<CaName><CRLNameSuffix><DeltaCRLAllowed>.crl' -Force
Remove-CACrlDistributionPoint 'file://<ServerDNSName>/CertEnroll/<CaName><CRLNameSuffix><DeltaCRLAllowed>.crl' -Force

Add-CAAuthorityInformationAccess  -Uri http://crl1.pkilab.local/pkilab/<ServerDNSName>_<CaName><CertificateName>.crt -AddToCertificateAia -Force
Remove-CAAuthorityInformationAccess 'ldap:///CN=<CATruncatedName>,CN=AIA,CN=Public Key Services,CN=Services,<ConfigurationContainer><CAObjectClass>' -Force
Remove-CAAuthorityInformationAccess 'http://<ServerDNSName>/CertEnroll/<ServerDNSName>_<CAName><CertificateName>.crt' -Force
Remove-CAAuthorityInformationAccess 'file://<ServerDNSName>/CertEnroll/<ServerDNSName>_<CAName><CertificateName>.crt' -Force

certutil -setreg CA\ValidityPeriod "Years"
certutil -setreg CA\ValidityPeriodUnits 10

Restart-Service certsvc
certutil -crl

certsrv.msc

Explorer C:\Windows\System32\CertSrv\CertEnroll
<#
Copy the CRL to the CRL server before attempting to stand up an Enterprise Issuing CA
Copy the crt to the DC and run the script called out there:
certutil -dspublish -f orca1_PKILab-RootCA.crt
#>
