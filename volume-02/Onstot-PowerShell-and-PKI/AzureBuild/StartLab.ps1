Import-Module az
#Enable-AzureRmAlias
$Connected = Get-AzContext
if (!($connected)) {
    # sign in
    Write-Host "Logging in...";
    Login-AzAccount;
}

$subscriptionId = $Connected.Subscription.id
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzSubscription -SubscriptionID $subscriptionId;

Start-AzVM -ResourceGroupName "PKILab" -Name "dc1"
Start-AzVM -ResourceGroupName "PKILab" -Name "crl1" -AsJob
Start-AzVM -ResourceGroupName "PKILab" -Name "ENTca1" -AsJob
#Start-AzureRmVM -ResourceGroupName "PKILab" -Name "cescep" -AsJob
#Start-AzureRmVM -ResourceGroupName "PKILab" -Name "tool1" -AsJob

#The following commands are used to view and retrieve the jobs from above
#get-job
#Receive-job *

### The Offline Root is below.  Only bring online for CRL publish, or new CA Signing
#Start-AzVM -ResourceGroupName "PKILab" -Name "orca1" -AsJob

#get Private IP Addresses
function Get-LabPrivateIPs {
    param ()
    Get-AzNetworkInterface -ResourceGroupName PKILab | 
    ForEach-Object { $Interface = $_.Name; $IPs = $_ | 
        Get-AzNetworkInterfaceIpConfig | 
        Select-Object PrivateIPAddress; Write-Host $Interface $IPs.PrivateIPAddress }
}

function Get-LabPublicIPs {
    param ()
    $PublicIPs = (Get-AzPublicIpAddress -ResourceGroupName 'PKILab')
    foreach ($System in $PublicIPs) {
        Write-Output "$($System.Name) - $($System.IpAddress)"    
    }
}

Get-LabPublicIPs
Get-LabPrivateIPs

#RDP to the system
#mstsc.exe /v:<Public IP above>
