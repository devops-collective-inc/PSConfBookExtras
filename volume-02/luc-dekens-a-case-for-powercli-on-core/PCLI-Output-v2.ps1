$user = 'luc'
$pswd = 'VMware1!'
$vmName = 'UbuntuPS'

$vm = Get-VM -Name $vmName
$code = @'
Connect-VIserver -Server $server -Session $sessionId | Out-Null
Get-VM | Select-Object -Property Name,MemoryGB,NumCPu |
ConvertTo-Json |
Out-File -Path $fileName
'@

$server = $global:defaultviserver.name
$sessionId = $global:defaultviserver.SessionId
$fileName = '/tmp/result.json'

$sInvoke = @{
    VM = $vm
    ScriptText = $ExecutionContext.InvokeCommand.ExpandString($code)
    ScriptType = 'powershellv6Snap'
    GuestUser = $user
    GuestPassword = $pswd | ConvertTo-SecureString -AsPlainText -Force
}
$result = Invoke-VMScriptPlus @sInvoke
$sCopy = @{
    VM = $vm
    Source = $fileName
    Destination = '.'
    GuestToLocal = $true
    GuestUser = $user
    GuestPassword = $pswd | ConvertTo-SecureString -AsPlainText -Force
}
Copy-VMGuestFile @sCopy
