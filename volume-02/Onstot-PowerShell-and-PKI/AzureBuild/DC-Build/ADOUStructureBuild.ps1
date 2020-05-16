#Determine Domain info
$DomainDN = (([ADSI]"").distinguishedName[0])
Import-Module ActiveDirectory

Function New-ADOU {
    [cmdletbinding()]            
    param(            
        [string] $TestOU            
    )  
    try {
        if ([adsi]::Exists("LDAP://OU=$TestOU,$RootOU")) {
            Write-host "$TestOU OU Exists"
        }
        else {
            Write-Host "OU $TestOU does not Exist"
            Write-Output 'Creating OUs'
            New-ADOrganizationalUnit -Path $RootOU -Name $TestOU -Description $TestOU
        }
    }
    catch {
        "Error was $_"
        $line = $_.InvocationInfo.ScriptLineNumber
        "Error was in Line $line"
    }
}

$RootOU = $DomainDN
New-ADOU 'Accounts'
New-ADOU 'Tier0'
New-ADOU 'Tier1'
New-ADOU 'Tier2'
New-ADOU 'PreProduction'
New-ADOU 'DefaultComputers' #redirect new systems here - GPO warning
New-ADOU 'DefaultUsers' #redirect new users here - GPO warning

$RootOU = "OU=Groups,$DomainDN"  #Delegate Group Management here
New-ADOU 'Security'
New-ADOU 'Distribution'

$RootOU = "OU=Accounts,$DomainDN" #Delegate User mgmt to Help Desk here, or at lower levels as needed
New-ADOU 'Standard Users'
New-ADOU 'Service Accounts'
New-ADOU 'Contacts'
New-ADOU 'Disabled'

$RootOU = "OU=PreProduction,$DomainDN"  # no delegation
New-ADOU 'PolicyTest' #no delegation - GPO creation area
New-ADOU 'Workstations' #delegate computer mgmt to T2 Admins
New-ADOU 'Servers' #delegate computer mgmt to T1 Admins
New-ADOU 'Accounts' #Delegate to user management team
New-ADOU 'Groups' #delegate to group management team - separate for DLs?

$RootOU = "OU=Tier0,$DomainDN" # No Delegation - DA ONlY
New-ADOU 'T0 Servers'
New-ADOU 'T0 SecurityGroups'
New-ADOU 'T0 Privileged Accounts'
New-ADOU 'T0 Service Accounts'
New-ADOU 'T0 Privileged Workstations'
New-ADOU 'T0 Standard Accounts'
New-ADOU 'T0 Standard Workstations'

$RootOU = "OU=T0 Servers,OU=Tier0,$DomainDN" # No Delegation - DA ONlY
New-ADOU 'T0 Federation Servers'
New-ADOU 'T0 PAM servers'
New-ADOU 'T0 IDM Provisioning Servers'
New-ADOU 'T0 Web Servers'
New-ADOU 'T0 Tool Servers'
New-ADOU 'T0 PKI Servers'

$RootOU = "OU=T0 SecurityGroups,OU=Tier0,$DomainDN"
New-ADOU 'SecurityTeams'
New-ADOU 'PAMRoles'
New-ADOU 'PAMAccounts'

$RootOU = "OU=Tier1,$DomainDN" # Delegate to specific T1 Admins?
New-ADOU 'T1 Privileged Accounts'
New-ADOU 'T1 Privileged Workstations'
New-ADOU 'MemberServers'

$RootOU = "OU=MemberServers,OU=Tier1,$DomainDN" # Delegate to specific T1 Admins?
New-ADOU 'SQL Servers'
New-ADOU 'Web Servers'

$RootOU = "OU=Tier2,$DomainDN"  # Delegate to specific T2 Admins?
New-ADOU 'T2 Privileged Accounts'
New-ADOU 'T2 Privileged Workstations'
New-ADOU 'ClientComputers'
