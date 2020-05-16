Import-Module ActiveDirectory


function New-GroupBuild {
    New-ADGroup -name $SecGroupName -GroupCategory 'Security' -GroupScope 'DomainLocal' -samAccountName $SecGroupName -Path $SecOU
}

#Determine Domain info
$DomainDN = (([ADSI]"").distinguishedName[0])
$nbn = (get-addomain).netbiosname
$SecOU = "OU=T0 SecurityGroups,OU=Tier0,$DomainDN"


<#
Group usage descriptions
"SEC-BlockInteractiveLogon" - Used in a GPO to block interactive logon to accounts in this group
"SEC-BLockNetworkLogon"  - Used in a GPO to block Network logon to accounts in this group
"SEC-BlockRDPLogon"  - Used in a GPO to block RDP logon to accounts in this group
"SEC-ServiceAccounts" - Used to collect non-user accounts, and apply policies to them
"SEC-JEADCOps" - Grants access to non-DA troubleshooting access to a JEA role deployed on DC
"SEC-ComputerAccountAdmins" - Delegated access in AD to manage computer objects in specific OUs
"SEC-UserAdmins" - Delegated access in AD to manage user objects in specific OUs
"SEC-UserModify"  - Delegated access in AD to modify, but not create, user objects in specific OUs
"SEC-GroupAdmins"  - Delegated access in AD to manage groupss in specific OUs
"SEC-GroupModify"  - Delegated access in AD to modify, but not create, groups in specific OUs
"SEC-PWResetClearLockouts" - Help Desk role to reset passwords, and clear account lockouts
"SEC-ServerAdmins" - LAPS role to retrieve local admin passwords for servers and has rights to add computers to specific OUs
"SEC-ClientComputerAdmin" - LAPS role to retrieve local admin passwords for client computers  and has rights to add computers to specific OUs
"SEC-IAMAdmins" - Admin access to Tier 0 systems
"SEC-IAMLogon" - RDP access to Tier 0 Systems
"SEC-JoinComputers" - Delegated access to join computers to the domain
"SEC-SQLServerAdmins" - Example group for a SQL team
"SEC-PAM-SDHolder" - Eample group for delegated right to a PAM system to modify Domain Admin passwords, without being a Domain admin.  (the PAM system must be configured to prevent abuse of this access before deployment)

#>

$SecGroupNames = @(
"SEC-BlockInteractiveLogon", 
"SEC-BLockNetworkLogon", 
"SEC-BlockRDPLogon", 
"SEC-ServiceAccounts", 
"SEC-JEADCOps", 
"SEC-ComputerAccountAdmins", 
"SEC-UserAdmins", 
"SEC-UserModify", 
"SEC-GroupAdmins", 
"SEC-GroupModify", 
"SEC-PWResetClearLockouts", 
"SEC-ServerAdmins", 
"SEC-ClientComputerAdmin", 
"SEC-IAMAdmins", 
"SEC-IAMLogon", 
"SEC-JoinComputers", 
"SEC-ServerAdmins-SQL", 
"SEC-ServerAdmins-Web", 
"SEC-PKIAdmins",
"SEC-PKIWebCertRequester",
"SEC-PAM-SDHolder")

foreach ($SecGroupName in $SecGroupNames) {
    Write-Output $SecGroupName
    New-GroupBuild
}

Start-sleep 5

function New-DelegationComputer ($SearchBase, $SECADMGRP) {
    $GrantCMD = "dsacls $SearchBase /I:S /G ""$nbn\$SECADMGRP"":SDDTWO;;computer"
    cmd.exe /C $GrantCMD
    $GrantCMD = "dsacls $SearchBase /I:S /G ""$nbn\$SECADMGRP"":CCDC;computer"
    cmd.exe /C $GrantCMD
    $GrantCMD = "dsacls $SearchBase /I:S /G ""$nbn\$SECADMGRP"":WP;userAccountControl;computer"
    cmd.exe /C $GrantCMD
}

#Delegate AD computer account management in the following OUs, to the following Groups
$SearchBase = "OU=ClientComputers,OU=Tier2,$DomainDN"
$SECADMGRP = "SEC-ComputerAccountAdmins"
New-DelegationComputer $SearchBase $SECADMGRP

$SECADMGRP = "SEC-ClientComputerAdmin"
New-DelegationComputer $SearchBase $SECADMGRP

$SearchBase = "OU=MemberServers,OU=Tier1,$DomainDN"
$SECADMGRP = "SEC-ServerAdmins"
New-DelegationComputer $SearchBase $SECADMGRP

$SearchBase = "OU=DefaultComputers,$DomainDN"
$SECADMGRP = "SEC-JoinComputers"
New-DelegationComputer $SearchBase $SECADMGRP

#Help Desk - Reset password/clear lockout
$SearchBase = """OU=Standard Users,OU=Accounts,$DomainDN"""
$SECADMGRP = "SEC-PWResetClearLockouts"
$GrantCMD = "dsacls $SearchBase /I:S /G ""$nbn\$SECADMGRP"":CA;""Reset Password"";user"
cmd.exe /C $GrantCMD

$GrantCMD = "dsacls $SearchBase /I:S /G ""$nbn\$SECADMGRP"":WP;""pwdLastSet"";user"
cmd.exe /C $GrantCMD

$GrantCMD = "dsacls $SearchBase /I:S /G ""$nbn\$SECADMGRP"":WP;""lockoutTime"";user"
cmd.exe /C $GrantCMD

#group management
#Grant Create/Delete and read/write all properites on decendant group opbjects to this group
$SearchBase = """OU=Groups,$DomainDN"""
$SECADMGRP = "SEC-GroupAdmins"
$GrantCMD = "dsacls $SearchBase /I:S /G ""$nbn\$SECADMGRP"":CCDCRPWP;;group"
cmd.exe /C $GrantCMD

#grant modify group membership to decendant group objects to this group
$SECADMGRP = "SEC-GroupModify"
$GrantCMD = "dsacls $SearchBase /I:S /G ""$nbn\$SECADMGRP"":WP;member"
cmd.exe /C $GrantCMD

#user management
#Grant Create/Delete and read/write all properites on decendant user opbjects to this group
$SearchBase = """OU=Standard Users,OU=Accounts,$DomainDN"""
$SECADMGRP = "SEC-UserAdmins"
$GrantCMD = "dsacls $SearchBase /I:S /G ""$nbn\$SECADMGRP"":CCDCRPWP;;user"
cmd.exe /C $GrantCMD


#redirect default user/computers out of containers to OUs.
redirusr ou=defaultusers,DC=PKILab,dc=Local
redircmp ou=defaultcomputers,DC=PKILab,dc=Local


#Run the following later in an Admin CMD shell if required
#The following can be used as one way to delegate password management to Domain Admin level accounts, from an account that itself is not a Domain Admin
#This group, and any accounts in it, must be secured in the same manner as a direct member of the Domain Admins group.
#dsacls "CN=AdminSDHolder,CN=System,DC=MyLab,DC=local" /G "\SEC-PAM - SDHolder":CA;"Reset Password"
#dsacls "CN=AdminSDHolder,CN=System,DC=MyLab,DC=local" /G "\SEC-PAM - SDHolder":RPWP;pwdLastSet


#Create accounts and populate the groups
$T0AdminUserPath = "OU=T0 Privileged Accounts,OU=Tier0,$DomainDN"
$T0ServiceAccountPath = "OU=T0 Service Accounts,OU=Tier0,$DomainDN"
$T1AdminUserPath = "OU=T1 Privileged Accounts,OU=Tier1,$DomainDN"
$StandardUserPath = "OU=Standard Users,OU=Accounts,$DomainDN"

#Dumping Passwords to the screen on the DC.
#Even though it is just on the DC, DON'T DO THIS IN PROD!
Add-Type -AssemblyName System.Web
function New-QuickUsers ($Name, $Path)
{
    $PW = [System.Web.Security.Membership]::GeneratePassword(15, 3)
    $mypwd = ConvertTo-SecureString -String $PW -Force -AsPlainText
    Write-Output "Record this for later: $Name - $PW"
    New-ADUser -Name $Name -GivenName $Name -Surname $Name -DisplayName "Display $Name" -UserPrincipalName "$Name@$nbn.Local" -SamAccountName $Name -AccountPassword $mypwd -Enabled $true -Path $Path
}

$name = 'Bob'
New-QuickUsers $name $StandardUserPath

$name = 'Admin-Bob'
New-QuickUsers $name $T1AdminUserPath

$Name = 'myDomain_Admin'
New-QuickUsers $name $T0AdminUserPath

$name = 'myCA_Admin'
New-QuickUsers $name $T0AdminUserPath

$name = 'myCA_svc'
New-QuickUsers $name $T0ServiceAccountPath

start-sleep 2
Add-ADGroupMember -identity 'Domain Admins' -members 'myDomain_Admin'
Add-ADGroupMember -identity "SEC-PKIAdmins" -members 'myCA_Admin','myCA_svc'
Add-ADGroupMember -identity "SEC-PKIWebCertRequester" -members 'Admin-Bob'
