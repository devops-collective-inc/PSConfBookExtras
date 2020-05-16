Add-WindowsFeature file-services
Add-WindowsFeature Adcs-Enroll-Web-Pol -includeManagementTools
Add-WindowsFeature Adcs-Enroll-Web-Svc -includeManagementTools

cd Cert:\LocalMachine\My
Install-AdcsEnrollmentPolicyWebService -AuthenticationType Username -KeyBasedRenewal -SSLCertThumbprint (dir -dnsname <CA_SERVERNAME>.<DOMAIN>.FQDN).Thumbprint
Install-AdcsEnrollmentPolicyWebService -AuthenticationType Certificate -KeyBasedRenewal -SSLCertThumbprint (dir -dnsname <CA_SERVERNAME>.<DOMAIN>.FQDN).Thumbprint

Install-AdcsEnrollmentWebService -ServiceAccountName "<DOMAIN>\s-cepces" -CAConfig "<CASERVERNAME>.<DOMAIN>.FQDN\<DOMAIN> CA 01" -SSLCertThumbprint (dir -dnsname <CA_SERVERNAME>.<DOMAIN>.FQDN).Thumbprint -AuthenticationType Username
Install-AdcsEnrollmentWebService -CAConfig "<CASERVERNAME>.<DOMAIN>.FQDN\<DOMAIN> CA 01" -SSLCertThumbprint (dir -dnsname <CA_SERVERNAME>.<DOMAIN>.FQDN).Thumbprint -AuthenticationType Certificate -RenewalOnly -AllowKeyBasedRenewal
