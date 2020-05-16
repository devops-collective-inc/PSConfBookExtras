$user = 'luc'
$pswd = 'VMware1!'
$vmName = 'UbuntuPS'

$vm = Get-VM -Name $vmName
$code = @'
Connect-VIserver -Server $server -Session $sessionId | Out-Null
Get-VM | Select-Object -Property Name,MemoryGB,NumCPu |
ConvertTo-Csv -NoTypeInformation -Delimiter ','
'@

$server = $global:defaultviserver.name
$sessionId = $global:defaultviserver.SessionId

$sInvoke = @{
    VM = $vm
    ScriptText = $ExecutionContext.InvokeCommand.ExpandString($code)
    ScriptType = 'powershellv6Snap'
    GuestUser = $user
    GuestPassword = $pswd | ConvertTo-SecureString -AsPlainText -Force
}
$result = Invoke-VMScriptPlus @sInvoke
$result.ScriptOutput.Split("`n") | ConvertFrom-Csv |
Export-Csv -Path .\report.csv -NoTypeInformation -UseCulture
