$user = 'luc'
$pswd = 'VMware1!'
$vmName = 'UbuntuPS'

$vm = Get-VM -Name $vmName
$code = @'
$sModule = @{
     Name = 'VMware.PowerCLI'
     Scope = 'CurrentUser'
     AllowClobber= $true
     Force = $true
}
Install-Module @sModule
Get-Module -Name VMware* -ListAvailable
'@

$sInvoke = @{
    VM = $vm
    ScriptText = $code
    ScriptType = 'powershellv6Snap'
    GuestUser = $user
    GuestPassword = $pswd | ConvertTo-SecureString -AsPlainText -Force
    #    KeepFiles = $true
    #    Verbose = $true
}
Invoke-VMScriptPlus @sInvoke
