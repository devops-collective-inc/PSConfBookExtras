# My Long-Running Script

# Connect to the vCenter Simulator
$Parameters = @{
    Server = "$env:vCenter"
    User = "$env:vcUser"
    Password = "$env:vcPass"
    Port = "443"
}
# Update the PowerCLI Profile
$PowerCLIProfile = @{
    InvalidCertificateAction = "Ignore"
    ParticipateInCeip = $false
    Scope = "AllUsers"
    Confirm = $false
}

"Setting PowerCLI Profile Configuration"
Set-PowerCLIConfiguration @PowerCLIProfile

"Connecting to vCenter: $env:vCenter"
Connect-VIServer @Parameters
"Starting Host Maintenance Loop."
Do {
    # Find any VMHosts in Maintenance mode
    $VMHosts = Get-VMHost | Where-Object {$_.ConnectionState -eq "Maintenance"}

    # Remove the Host from maintenance mode
    Foreach ($VMHost in $VMHosts){
        "Setting host back to Connected:"
        Set-VMHost -VMHost $VMhost -State Connected
        $VMHost.Name
    }

    # List the Current state of all VMHosts
    Get-VMHost | Select-Object Name,ConnectionState,PowerState


    "Waiting 10 Seconds"
    Start-Sleep -Seconds 10
    # Find any VMhosts with no VM's and place them in Maintenance mode
    $VMHosts = Get-VMHost
    Foreach ($VMHost in $VMHosts) {
        $VMs = Get-VMHost -Name $VMHost | Get-VM | Measure-Object
        if ($VMs.Count -eq 0){
            "Setting VMHost to Maintenance:"
            $VMHost.Name
            Set-VMHost -VMHost $VMhost -State Maintenance
        }
    }
    # List the Current state of all VMHosts
    Get-VMHost | Select-Object Name,ConnectionState,PowerState

    "Waiting 30 Seconds."
    Start-Sleep -Seconds 30
} while ($true)
