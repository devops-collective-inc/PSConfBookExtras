# Example: CVAD-2
# Show what servers are hosting an application
#    Application -> (Application Groups and Delivery Groups) -> Servers
#Requires –Version 5
#Requires -Modules PSGraph
param(
    # Define the delivery group to to audit
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("[A-Za-z0-9*]")]
    [String] $ApplicationName
)

## this function will get XenDesktops (Servers) in a Delivery Group
## based on Name or UUID along with Tag restrictions
function Get-SvrsInDelGrp {
    [CmdletBinding(DefaultParameterSetName = 'by Name')]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true, 
            Position = 0,
            ParameterSetName = 'by Name')]
        [string[]]$Name,
        [Parameter(ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'by UUID')]
        [guid[]]$UUID,
        [Parameter(ParameterSetName = 'by Name')]
        [Parameter(ParameterSetName = 'by UUID')]
        [string]$RestrictTotTag
    )
    Begin { }
    Process {
        if ($name) {
            foreach ($GrpName in $Name) {
                if ($RestrictTotTag) {
                    $XAServers | Where-Object { $_.DesktopGroupName -eq $GrpName
                        -and $_.Tags -contains $RestrictTotTag }
                    Get-BrokerDesktop -DesktopGroupName $GrpName
                        -Tag $RestrictTotTag
                }
                else {
                    $XAServers | Where-Object DesktopGroupName -eq $GrpName
                    Get-BrokerDesktop -DesktopGroupName $GrpName 
                }
            }
        }
        If ($UUID) {
            foreach ($GrpUUID in $UUID) {
                if ($RestrictTotTag) {
                    $XAServers | Where-Object { $_.DesktopGroupUUID -eq $GrpUUID
                        -and $_.Tags -contains $RestrictTotTag }
                    Get-BrokerDesktopGroup -UUID $GrpUUID | Get-BrokerDesktop
                        -Tag $RestrictTotTag
                }
                else {
                    $XAServers | Where-Object DesktopGroupUUID -eq $GrpUUID
                    Get-BrokerDesktopGroup -UUID $GrpUUID | Get-BrokerDesktop 
                }
            }
        }
    }
    End { }
}

# This section will gather all the relevant data from the Citrix environment
# initialize all the XenApp $XA_____ variables with data
$XAServerNames = Get-BrokerMachine -DesktopKind Shared | 
    Select-Object @{name = 'Name'; e = { ($_.MachineName -split '\\')[1] } } | 
    Sort-Object Name | 
    Select-Object -ExpandProperty Name
$XADelGroupNames = Get-BrokerDesktopGroup | 
    Select-Object -ExpandProperty Name
$XAServers = Get-BrokerMachine -DesktopKind Shared
$XAApps = Get-BrokerApplication
$XAAppGroups = Get-BrokerApplicationGroup
$XADelGroups = Get-BrokerDesktopGroup 

Write-Verbose "Finding apps for -> $($DeliveryGroupName.Name)"
$MyXAApps = $XAApps | Where-Object PublishedName -like $ApplicationName

graph "ServersForApplication" @{rankdir = 'LR' } {
    foreach ($XAApp in $MyXAApps) {
        $AppName = $XAApp.PublishedName
        Write-Verbose "app   : $AppName"
        # create Application Node
        $AppNode = @{
            name       = "app_$AppName"
            Ranked     = $true
            Attributes = @{
                shape = 'oval'
                label = $AppName
            }
        }
        Node @AppNode

        # loop through Application Groups directly assigned to App
        $XAApp.AssociatedApplicationGroupUUIDs | ForEach-Object {
            $appgrpUUID = $_.guid

            # Set flag if this AppGrp is RestrictToTag
            $appGrpRestrictToTag = $_.RestrictToTag

            # loop through AppGrps diectly assign to App
            $XAAppGroups |
            Where-Object uuid -eq $appgrpUUID |
            ForEach-Object {
                $AppGrpName = $_.Name

                Write-warning "appgrp: $AppGrpName"
                # create Application Group Node
                $AppGrpNode = @{
                    name       = "appgrp_$AppGrpName"
                    Ranked     = $true
                    Attributes = @{
                        shape = 'folder'
                        label = $AppGrpName
                    }
                }
                node @AppGrpNode

                # create link from App to App Group
                Edge -From "app_$AppName" -to "appgrp_$AppGrpName"

                # loop through Delivery Groups diectly assign to App
                $XADelGroups | 
                Where-Object UUID -in $_.AssociatedDesktopGroupUUIDs |
                ForEach-Object {
                    $DelGrpName = $_.Name

                    Write-warning "delgrp: $DelGrpName"
                    # create Delivery Group Node
                    $DelGrpNode = @{
                        name       = "delgrp_$DelGrpName"
                        Ranked     = $true
                        Attributes = @{
                            shape = 'circle'
                            label = $DelGrpName
                        }
                    }
                    node @DelGrpNode
                    Edge -From ("appgrp_$AppGrpName") -to "delgrp_$DelGrpName"

                    # Get Servers from Delivery Group
                    #  passing in the RestrictToTag
                    # If RestrictToTag is empty,
                    #  all servers will be resturned
                    $SrvSearch = @{
                        UUID           = $_.UUID.guid
                        RestrictTotTag = $appGrpRestrictToTag
                    }
                    $Servers = Get-SvrsInDelGrp @SrvSearch

                    $Servers | ForEach-Object {
                        #  get the ComputerName from MachineName value
                        #     (DOMAIN\ComputerName)
                        $svrName = ($_.MachineName -split '\\')[1]  

                        Write-warning "svr   : $svrName"
                        $SvrNode = @{
                            name       = "svr_$svrName"
                            Ranked     = $true
                            Attributes = @{
                                shape = 'box3d'
                                label = $svrName
                            }
                        }
                        node @SvrNode
                        Edge -From ("delgrp_$DelGrpName") -to "svr_$svrName"
                    }
                }
            }
        }

        # loop through Delivery Groups directly assigned to App
        $_.AssociatedDesktopGroupUUIDs | ForEach-Object {
            $delgrpUUID = $_.guid

            # loop through DelGrps diectly assign to App
            $XADelGroups |
            Where-Object uuid -eq $DelgrpUUID |
            ForEach-Object {
                $DelGrpName = $_.Name

                Write-warning "delgrp: $DelGrpName"
                # create Delivery Group Node
                $DelGrpNode = @{
                    name       = "delgrp_$DelGrpName"
                    Ranked     = $true
                    Attributes = @{
                        shape = 'circle'
                        label = $DelGrpName
                    }
                }
                node @DelGrpNode
                Edge -From "app_$AppName" -to "delgrp_$DelGrpName"

                # Get Servers from Delivery Group
                #  passing in the RestrictToTag
                # If RestrictToTag is empty,
                #  all servers will be resturned
                $SrvSearch = @{
                    UUID = $_.UUID.guid
                }
                $Servers = Get-SvrsInDelGrp @SrvSearch

                $Servers | ForEach-Object {
                    #  get the ComputerName from MachineName value
                    #     (DOMAIN\ComputerName)
                    $svrName = ($_.MachineName -split '\\')[1]  

                    Write-warning "svr   : $svrName"
                    $SvrNode = @{
                        name       = "svr_$svrName"
                        Ranked     = $true
                        Attributes = @{
                            shape = 'box3d'
                            label = $svrName
                        }
                    }
                    node @SvrNode
                    Edge -From ("delgrp_$DelGrpName") -to "svr_$svrName"

                }
            }
        }
    }
} | Export-PSGraph
