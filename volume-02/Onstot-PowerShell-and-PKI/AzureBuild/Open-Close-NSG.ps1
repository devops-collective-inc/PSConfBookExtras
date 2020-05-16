function New-NSGInbound {
    param ($resourceGroupName, $nsglist)
    foreach ($nsgname in $nsglist) {
        $ExistingNSG = Get-AzNetworkSecurityGroup -Name $nsgname -ResourceGroupName $resourceGroupName
        #add the RDP Inbound Rule
        $ExistingNSG | Add-AzNetworkSecurityRuleConfig -Name "Allow_3389" -Description "Allow RDP" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority "300" -SourceAddressPrefix $myPublicIP -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
        #update the NSG
        $ExistingNSG | Set-AzNetworkSecurityGroup
    }
}

function Remove-NSGInbound {
    param ($resourceGroupName, $nsglist)
    foreach ($nsgname in $nsglist) {
        $ExistingNSG = Get-AzNetworkSecurityGroup -Name $nsgname -ResourceGroupName $resourceGroupName
        Remove-AzNetworkSecurityRuleConfig -Name "Allow_3389" -NetworkSecurityGroup $ExistingNSG | Set-AzNetworkSecurityGroup
    }
}

#Get current public IP
$myPublicIP = (Invoke-WebRequest -Uri "https://api.ipify.org").content

#Target the new Resource Group
$resourceGroupName = 'PKILab'
$nsglist = @("DC1-nsg", "orca1-nsg", "crl1-nsg", "EntCA1-nsg") #"CESCEP1-nsg", "tool1-nsg"

#Open Ports
New-NSGInbound $resourceGroupName $nsglist

#close ports
#Remove-NSGInbound $resourceGroupName $nsglist

