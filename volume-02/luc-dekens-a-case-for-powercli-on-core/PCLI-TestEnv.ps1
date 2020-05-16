$user = 'luc'
$pswd = 'VMware1!'
$vmName = 'UbuntuPS'

$vm = Get-VM -Name $vmName
$code = @'
sudo printenv
'@

$sInvoke = @{
    VM = $vm
    ScriptText = $code
    ScriptType = 'bash'
    GuestUser = $user
    GuestPassword = $pswd | ConvertTo-SecureString -AsPlainText -Force
    KeepFiles = $true
    Verbose = $true
}
Invoke-VMScriptPlus @sInvoke
