function New-UbuntuVM
{
    <#
.SYNOPSIS
Create an Ubuntu station with Cloud-Init
.DESCRIPTION
This function will create a new VM from an Ubuntu Cloud OVA.
The configuration settings settings are provided in a JSON file.
.NOTES
Author:  Luc Dekens
Version:
1.0 21/07/19  Initial release
.PARAMETER JSONPath
The location of the JSON file with the configuration parameters
.PARAMETER LogFile
Optional file for capturing logging information.
This includes the output of the customisation scripts
.EXAMPLE
New-UbuntuVM -JSONPath .\ubuntu.json
.EXAMPLE
New-UbuntuVM -JSONPath .\ubuntu.json -LogFile .\ubuntuPS.log
#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$JSONPath
    )

    # Get Parameters

    $paramDataJSON = Get-Content -Path $JSONPath | Out-String
    $paramData = ConvertFrom-Json -InputObject $paramDataJSON

    # Determine location for VM
    $obj = Get-Inventory -Name $paramData.vSphere.VMHost
    if ($obj -is [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster])
    {
        $obj = Get-VMHost -Location $obj | Get-Random
    }
    $esx = $obj

    $dsc = Get-DatastoreCluster -Name $paramData.vSphere.Storage -ErrorAction SilentlyContinue
    if ($dsc)
    {
        $ds = Get-Datastore -RelatedObject $dsc | Get-Random
    }
    else
    {
        $ds = Get-Datastore -Name $paramData.vSphere.Storage
    }

    # Deploy VMs
    foreach ($vmInfo in $paramData.VM)
    {
        # Clean up existing VM (if requested)
        if ($vmInfo.Cleanup)
        {
            $vm = Get-VM -Name $vmInfo.Name -ErrorAction SilentlyContinue
            if ($vm)
            {
                Stop-VM -VM $vm -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
                Remove-VM -VM $vm -DeletePermanently -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
            }
        }

        # Customise cloud-config
        $cloudConfig = $ExecutionContext.InvokeCommand.ExpandString(($vmInfo.CloudConfig -join "`r`n"))

        # Configure the OVA properties
        $ovfProp = Get-OvfConfiguration -Ovf $vmInfo.OVA
        $ovfProp.Common.user_data.Value = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($cloudConfig))
        $ovfProp.NetworkMapping.VM_Network.Value = $vmInfo.Network.Portgroup

        $sApp = @{
            Source = $vmInfo.OVA
            Name = $vmInfo.Name
            Datastore = $ds
            DiskStorageFormat = $vmInfo.DiskStorageFormat
            VMHost = $esx
            OvfConfiguration = $ovfProp
        }
        $vm = Import-VApp @sApp

        # Update the Notes field
        $sNote = @{
            VM = $vm
            Notes = $vmInfo.VMNote.Replace('#timestamp#', (Get-Date -Format 'dd/MM/yyyy HH:mm'))
            Confirm = $false
        }
        $vm = Set-VM @sNote

        # Adapt HW (if required)
        if ($vm.NumCpu -ne $vmInfo.NumCpu)
        {
            $vm = Set-VM -VM $vm -NumCpu $vmInfo.NumCpu -Confirm:$false
        }
        if ($vm.MemoryGB -ne $vmInfo.MemoryGB)
        {
            $vm = Set-VM -VM $vm -MemoryGB $vmInfo.MemoryGB -Confirm:$false
        }

        # Power on VM
        Start-VM -VM $vm -Confirm:$false
    }
}

$pName = 'UbuntuPSGui'
$json = ".\$($pName).json"

New-UbuntuVM -JSONPath $json
