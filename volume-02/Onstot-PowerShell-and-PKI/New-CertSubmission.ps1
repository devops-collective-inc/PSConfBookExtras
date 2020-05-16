<#
.SYNOPSIS
Issue Certs from specified internal CA

.DESCRIPTION
Issue Certs from specified internal CA

.EXAMPLE
Load the function then run new-cert.web.  You will be prompted for the additional required values
. .\new-webcert.ps1

New-CertSubmit
cmdlet New-CertSubmit at command pipeline position 1
Supply values for the following parameters:
subject: bob.thing.com
shortName: bob

.EXAMPLE
Load the function then run new-cert.web.  Pass the required info through the pipeline
. .\new-webcert.ps1

New-CertSubmit -subject bob.thing.com -shortName bob

.NOTES
Authors: Greg Onstot
Version: 0.1.0
Version Date: 07/23/19

#>
function New-CertSubmit {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(
            ValueFromPipelineByPropertyName,
            Mandatory = $true,
            HelpMessage = 'Enter the FQDN of the system')]
        [string]$subject,
        [Parameter(
            ValueFromPipelineByPropertyName,
            Mandatory = $true,
            HelpMessage = 'Enter the Short name of the system')]
        [string]$shortName,
        [Parameter(
            ValueFromPipelineByPropertyName,
            Mandatory = $true)]
        [ValidateSet(
            "PKILab-WebServer",
            "PKILab-Server",
            "PKILab-WorkstationAuthentication")]
        [string]$CertTemplate,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SAN1,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SAN2,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SAN3,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SAN4,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SAN5
    )
    
    begin {
        if (!(test-path 'C:\Temp\')) { mkdir c:\temp}
        
        $filepath = "c:\temp\"
        if (!(test-path "$filepath\$subject.csr" -PathType Leaf)) { 
            $Message = @(
                "CSR is not in the default location, or does not match
the provided subject name - $Subject.csr
Please rename or move, and try again."
                ) -join ' '
            Write-Output  $Message

            break
        }

        $filepath = "c:\temp\$env:UserName"
        if (!(test-path $filepath)) { 
            mkdir $filepath
            write-output 'Folder did not exist...Created'
        }
    }
    
    process {
        #if (SAN-X) {
        #}
        
        $Attrib = "CertificateTemplate:$CertTemplate\nSAN:DNS=$subject&DNS=$shortName"
        Write-Output $Attrib
        if ($SAN1) {
            $Attrib = $Attrib + "&DNS=$SAN1"
            Write-Output $Attrib
        }
        if ($SAN2) {
            $Attrib = $Attrib + "&DNS=$SAN2"
            Write-Output $Attrib
        }
        if ($SAN3) {
            $Attrib = $Attrib + "%dns=$SAN3"
            Write-Output $Attrib
        }
        if ($SAN4) {
            $Attrib = $Attrib + "%dns=$SAN4"
            Write-Output $Attrib
        }
        if ($SAN5) {
            $Attrib = $Attrib + "%dns=$SAN5"
            Write-Output $Attrib
        }
        certreq -submit -config EntCA1.PKILab.local\PKILabEntCA01 -attrib $Attrib "c:\temp\$subject.csr" "$filepath\$subject.cer"
        Move-Item -path "c:\temp\$subject.csr" -Destination "$Filepath"
    }
    
    end {
    }
}
