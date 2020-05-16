# Example Scenario: AD-1
# Show a graph of what groups a user is part of
#   $UserName = jdoe
#Requires –Version 5
#Requires -Modules ActiveDirectory
#Requires -Modules PSGraph
param(
    # Parameter help description
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $ADObject
)

$LDAPFilter= "(& (|(objectClass=group)(objectClass=user))(|(name=$($ADObject))(SAMAccountName=$($ADObject))(ObjectSID=$($ADObject))(DistinguishedName=$($ADObject))))"
Try {
    $Object = Get-ADObject -LDAPFilter $LDAPFilter
} catch {
    Write-Error "Unable to find: $ADObject"
    break
}

Function Get-MembersOf {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ADObject
    )
    $ShapeHashTable = @{
        user  = "circle"
        group = "box"
    }

    Write-Verbose "$ADObject"
    $ADObj = Get-ADObject -Identity $ADObject -Properties memberof

    Node $ADObj @{label={$_.Name};shape = $ShapeHashTable["$_.objectClass"]}

    $ADObj.memberof | ForEach-Object {
        $ADMbr = Get-ADObject -Identity $_

        Node $ADMbr @{label={$_.Name};shape = $ShapeHashTable["$_.objectClass"]}

        edge -From $ADObj -To $ADMbr
        Write-Verbose "--- $_"
        ## This is a recursive call and will go as deep as need
        Get-MembersOf -ADObject $_
    }
}

graph ADGroups @{rankdir = 'LR' } {
    Get-MembersOf -ADObject $Object
} | Show-PSGraph
