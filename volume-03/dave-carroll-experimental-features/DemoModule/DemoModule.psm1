<#
Experimental Features:
DemoModule.ExperimentalFunction
DemoModule.ExperimentalParameter
DemoModule.ExperimentalBehavior
The following two functions, both named Show-HelloWord, are mutually exclusive as determined by the
experimental state.

#>
function Show-HelloWorld {
    [Experimental('DemoModule.ExperimentalFunction', 'Hide')]
    [CmdletBinding()]
    param()

    'PowerShell 7 is shipping soon!' | Write-Host -ForegroundColor Green
}

function Show-HelloWorld {
    [Experimental('DemoModule.ExperimentalFunction', 'Show')]
    [CmdletBinding()]
    param()

    'PowerShell 7 is here!' | Write-Host -ForegroundColor Yellow
}


<#
Experimental Features:
DemoModule.ExperimentalParameter
DemoModule.ExperimentalBehavior

In the Get-LoremIpsum function, there are two mutually exclusive parameters.

Also, there is an experimental behavior that will display the text when the feature is enabled.
#>
function Get-LoremIpsum {
    [CmdletBinding()]
    param(
        # When the experimental feature is disabled, this parameter will be available.
        [Experimental('DemoModule.ExperimentalParameter', [ExperimentAction]::Hide)]
        [switch]$Display,

        # When the experimental feature is enabled, this parameter will be available.
        [Experimental('DemoModule.ExperimentalParameter', [ExperimentAction]::Show)]
        [switch]$Show
    )

    if ($Display) {
        $Lorem = @()
        $Lorem += 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
        $Lorem += 'Sed varius mi erat, in laoreet nibh eleifend eget.'
        $Lorem += 'Phasellus odio diam, tincidunt rhoncus massa in, feugiat'
        $Lorem += 'iaculis mauris. Nulla ornare enim et semper tincidunt.'
        $Lorem += 'Maecenas ac tempor quam, in scelerisque lorem.'
        $Lorem -join ' ' | Write-Output
    }

    if ($Show) {
        'The quick brown fox jumps over the lazy dog.' | Write-Output
    }

    # When this experimental feature is enabled, the text will be displayed.
    if ([ExperimentalFeature]::IsEnabled('DemoModule.ExperimentalBehavior')) {
        'This is an experimental behavior' | Write-Output
    }
}