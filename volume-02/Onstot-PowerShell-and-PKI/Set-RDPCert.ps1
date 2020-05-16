#requires -version 5
<#
  Version:        1.3
  Author:         Greg Onstot
  Version Date:  7/23/19

  Prerequisites:
- You must already have a 'Server Authentication' Certificate installed on your system.
- You must be logged on locally with an Admin level account
#>

<#
    .SYNOPSIS
    Uses an existing server certificate for RDP session

    .DESCRIPTION
    This script will list all non-expired certificates on your server, and allow you to select one to be used for RDP sessions

    .EXAMPLE
    Just run the script from an elevated powershell prompt
    Set-RDPCert.ps1

    .NOTES
    - This process must be performed yearly after the certificate renewal has completed
    - If the certificate assigned to be used for RDP is removed, the server will revert back to the default self-signed RDP certificate
    #>

$RDPCert = Get-ChildItem -path cert:\LocalMachine\My\* |
  Where-Object { $_.NotAfter -ge (get-date) } |
  Select-Object NotAfter, Subject, Issuer, Thumbprint
if ($RDPCert.Count -ne 1) {
    Write-Output $RDPCert.Count
    $RDPCert = Get-ChildItem -path cert:\LocalMachine\My\* |
    Where-Object { $_.NotAfter -ge (get-date) } |
    Select-Object NotAfter, Subject, Issuer, Thumbprint |
    Out-GridView -Title 'Select the cert to use for RDP Sessions...' -PassThru
}
$ThumbPrint = $RDPCert.Thumbprint

$Params = @{
  Namespace = "root/cimv2/TerminalServices"
  ClassName = "Win32_TSGeneralSetting"
  Filter = "TerminalName='RDP-tcp'"
}
$path = Get-CimInstance @Params

$path | Set-CimInstance -Property @{ SSLCertificateSHA1Hash = $Thumbprint }
$path.SSLCertificateSHA1Hash
#Create multiple CIMSessions to work remotely