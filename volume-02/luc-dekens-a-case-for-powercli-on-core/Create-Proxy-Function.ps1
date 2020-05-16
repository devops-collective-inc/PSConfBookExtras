$CmdletName = 'Open-VmConsoleWindow'

$Folder = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$Cmdlet = Get-Command -Name $CmdletName
$SObj = @{
    TypeName = 'System.Management.Automation.CommandMetaData'
    ArgumentList = $Cmdlet
}
$CmdletMeta = New-Object @SObj
[System.Management.Automation.ProxyCommand]::Create($CmdletMeta) |
Out-File -FilePath "$Folder\Proxy-$CmdletName.ps1"
