Get-Module -Name VMware.* -ListAvailable -PipelineVariable module |
ForEach-Object -Process {
    Get-ChildItem -Path $module.ModuleBase -Directory -Filter "netcore*" |
    ForEach-Object -Process {
        Get-ChildItem -Path $_.FullName -Filter "*.Cmdlets.dll-Help.xml" |
        ForEach-Object -Process {
            [xml]$help = Get-Content -Path $_.FullName
            $help.helpItems.command |
            ForEach-Object -Process {
                New-Object PSObject -Property ([ordered]@{
                        Module = $module.Name
                        Cmdlet = "$($_.details.verb)-$($_.details.noun)"
                        Core = -not ($_.alertset.alert.para -match "This cmdlet is not supported on the Core edition of PowerShell.")
                    })
            }
        }
    }
} | Where-Object { -not $_.Core } |
Sort-Object -Property Module, Cmdlet
