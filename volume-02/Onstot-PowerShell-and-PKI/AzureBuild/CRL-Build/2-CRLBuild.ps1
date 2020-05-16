Get-Disk | 
Where-Object partitionstyle -eq 'raw' | 
Initialize-Disk -PartitionStyle MBR -PassThru |
New-Partition -DriveLetter F -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false

$folder = 'F:\inetpub\pkilab'

Install-WindowsFeature -name Web-Server -IncludeManagementTools
New-Item -type directory -path $folder
New-SmbShare -Name 'CRL' -Path $folder -ChangeAccess 'SEC-PKIAdmins'
Grant-SmbShareAccess -Name 'CRL' -AccountName 'pkilab\domain admins' -AccessRight Full -Force


Import-Module WebAdministration
$SiteName = 'IIS:\Sites\Default Web Site\'
#set the Default Web site to point at the folder for the CRL 
Set-ItemProperty $SiteName -name physicalPath -value $folder

#set the NTFS perms too
$acl = Get-Acl $folder
$NewPerm = 'pkilab\SEC-PKIAdmins','Read,Modify','ContainerInherit,ObjectInherit','None','Allow'
$NewRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $NewPerm
$Acl.SetAccessRule($NewRule)
$Acl | Set-Acl -Path $folder

#enable Directory Browsing
Set-WebConfigurationProperty -Filter /system.webServer/directoryBrowse -name enabled -Value $true
Get-WebConfigurationProperty -filter /system.webServer/directoryBrowse -name enabled -PSPath $SiteName

#enable Double Escaping for the Delta CRL +
Set-WebConfiguration -Filter system.webServer/security/requestFiltering -PSPath $SiteName -Value @{allowDoubleEscaping=$true}
