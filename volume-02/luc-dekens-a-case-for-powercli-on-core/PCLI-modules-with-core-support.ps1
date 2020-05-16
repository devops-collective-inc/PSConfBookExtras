$shell = New-Object -ComObject Shell.Application

Get-Module -Name 'VMware.*' -ListAvailable |
Where-Object { $_.ModuleBase -match "Program Files" } |
Select-Object Name, Version,
@{N = 'Date'; E = {
        $script:fName = ($_.Path -replace '.psd1', '.cat')
        if (Test-Path -Path $script:fName)
        {
            $script:folder = Split-Path -Path $script:fName -Parent
            $file = Split-Path -Path $script:fName -Leaf
            $sFolder = $shell.Namespace($script:folder)
            $sFile = $sFolder.ParseName($file)
            $sFolder.GetDetailsOf($sFile, 3)
        }
        else { 'na' }
    }
},
@{N = 'Validation'; E = {
        if (Test-Path -Path $script:fName)
        {
            Test-FileCatalog -CatalogFilePath $script:fName -FilesToSkip *.xml
        }
        else { 'na' } }
},
@{N = 'Core'; E = {
        if ($_.Name -ne 'VMware.PowerCLI')
        {
            Test-Path -Path "$($script:folder)\netcoreapp2.0"
        }
        else { 'na' } }
} | Format-Table -AutoSize
