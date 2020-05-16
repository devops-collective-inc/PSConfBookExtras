$user = 'luc'
$pswd = 'VMware1!'
$vmName = 'UbuntuPS'

$vm = Get-VM -Name $vmName
$code = @'
Connect-VIserver -Server $server -Session $sessionId | Out-Null
Get-VM | Select-Object -Property Name | Out-String -Width 132
#Disconnect-VIServer -Server $server -Confirm:`$false
'@

$server = $global:defaultviserver.name
$sessionId = $global:defaultviserver.SessionId

$sInvoke = @{
    VM = $vm
    ScriptText = $ExecutionContext.InvokeCommand.ExpandString($code)
    ScriptType = 'powershellv6Snap'
    GuestUser = $user
    GuestPassword = $pswd | ConvertTo-SecureString -AsPlainText -Force
    CRLF = $true
    KeepFiles = $true
    #    Verbose = $true
}
$result = Invoke-VMScriptPlus @sInvoke
$result.ScriptOutput
