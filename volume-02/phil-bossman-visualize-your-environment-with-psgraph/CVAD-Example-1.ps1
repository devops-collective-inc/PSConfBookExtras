# Example: CVAD-1
# Show what applications are hosted from a delivery group
#    Delivery Group -> (Application Groups and Direct Applications)
#Requires –Version 5
#Requires -Modules PSGraph
param(
    # Define the delivery group to to audit
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("[A-Za-z0-9*]")]
    [String] $DeliveryGroupName
)

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

Write-Verbose "Finding groups that match name -> $($DeliveryGroupName.Name)"
$Delgrps = $XADelGroups | Where-Object Name -Like $DeliveryGroupName

Write-Verbose "--- $($Delgrps.count) groups"
graph "AppsInDelGrp" @{rankdir = 'LR' } {
    # loop through Delivery Groups
    foreach ($DelGrp in $DelGrps) {
        $DelGrpName = $DelGrp.Name

        Write-Verbose "delGrp: $DelGrpName"
        # create Delivery Group Node
        $DelGrpNode = @{
            name       = "delgrp_$DelGrpName"
            Ranked     = $true
            Attributes = @{
                shape = 'circle'
                label = $DelGrpName
            }
        }
        Node @DelGrpNode

        # loop through Application Groups for specific Delivery Group
        $xaAppGroups |
        Where-Object AssociatedDesktopGroupUUIDs -Contains $Delgrp.uuid |
        ForEach-Object {
            $AppGrpName = $_.Name
            $AppGrpUUID = $_.UUID

            Write-Verbose "AppGrp: $AppGrpName"
            # create Application Group Node

            $AppGrpNode = @{
                name       = "appgrp_$AppGrpName"
                Ranked     = $true
                Attributes = @{
                    shape = 'folder'
                    label = $AppGrpName
                }
            }
            Node @AppGrpNode
            edge -From "delgrp_$DelGrpName" -To "appgrp_$AppGrpName"


            # loop through Applications directly assigned to App Group
            $XAapps |
            Where-Object AssociatedApplicationGroupUUIDs -Contains $AppGrpUUID |
            ForEach-Object {
                $appName = $_.PublishedName

                Write-Verbose "app   : $appName"
                # create Application Node
                $AppNode = @{
                    name       = "app_$AppName"
                    Ranked     = $true
                    Attributes = @{
                        shape = 'oval'
                        label = $AppName
                    }
                }
                node @AppNode
                Edge -From "appgrp_$AppGrpName" -to "app_$AppName"
            }

        }

        # loop through Applications directly assigned to this Delivery Group
        $XAapps |
        Where-Object AssociatedDesktopGroupUUIDs -Contains $DelGrp.uuid |
        ForEach-Object {
            $appName = $_.PublishedName

            Write-Verbose "app   : $appName"
            # create Application Node
            $AppNode = @{
                name       = "app_$AppName"
                Ranked     = $true
                Attributes = @{
                    shape = 'oval'
                    label = $AppName
                }
            }
            node @AppNode
            Edge -From "delgrp_$DelGrpName" -to "app_$AppName"
        }
    }
    Rank $DelGrps.Name
} | Export-PSGraph