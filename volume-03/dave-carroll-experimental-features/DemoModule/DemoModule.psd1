@{
    RootModule = 'DemoModule.psm1'
    ModuleVersion = '0.7.0'
    CompatiblePSEditions = 'Core'
    GUID = 'a007643e-c876-4806-b6cb-367963716e98'
    Author = 'Dave'
    CompanyName = 'thedavecarroll'
    Copyright = '2020 (c) Dave Carroll. All rights reserved.'
    PowerShellVersion = '7.0'
    FunctionsToExport = 'Show-HelloWorld','Get-LoremIpsum'

    PrivateData = @{
        PSData = @{
            ExperimentalFeatures = @(
                @{
                    Name = 'DemoModule.ExperimentalFunction'
                    Description = 'Demo of Experimental Functions'
                },
                @{
                    Name = 'DemoModule.ExperimentalParameter'
                    Description = 'Demo of Experimental Parameter'
                },
                @{
                    Name = 'DemoModule.ExperimentalBehavior'
                    Description = 'Demo of Experimental Behavior'
                }
            )
        }
    }
}