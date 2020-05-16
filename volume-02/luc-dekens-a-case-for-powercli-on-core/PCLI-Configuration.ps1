$user = 'luc'
$pswd = 'VMware1!'
$vmName = 'UbuntuPS'

$vm = Get-VM -Name $vmName
$code = @'
$sConfig = @{
    InvalidCertificateAction = 'Ignore'
    ParticipateInCeip = $true
    DisplayDeprecationWarnings = $false
    Scope = 'User'
    Confirm = $false
}
Set-PowerCLIConfiguration @sConfig
'@

$sInvoke = @{
    VM = $vm
    ScriptText = $code
    ScriptType = 'powershellv6Snap'
    GuestUser = $user
    GuestPassword = $pswd | ConvertTo-SecureString -AsPlainText -Force
}
Invoke-VMScriptPlus @sInvoke
