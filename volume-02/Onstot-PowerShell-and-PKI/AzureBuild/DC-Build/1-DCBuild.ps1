#Basic Lab DC Build script
#Assumption - you have a Win2016+ VM and run the script from within it.

Get-Disk | 
Where-Object partitionstyle -eq 'raw' | 
Initialize-Disk -PartitionStyle MBR -PassThru |
New-Partition -DriveLetter F -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false

install-windowsfeature AD-Domain-Services
Import-Module ADDSDeployment
Add-WindowsFeature RSAT-ADDS-Tools

#The following will default to Win2016 Domain and Functional Modes, and prompt for the DSRM password.
#The existing local administator password will become
Install-ADDSForest `
-ForestMode "Default" `
-DomainName "PKILab.local" `
-DomainNetbiosName "PKILab" `
-InstallDns:$true `
-CreateDnsDelegation:$false `
-DatabasePath "F:\Windows\NTDS" `
-LogPath "F:\Windows\NTDS" `
-SysvolPath "F:\Windows\SYSVOL" `
-NoRebootOnCompletion:$false `
-Force:$true