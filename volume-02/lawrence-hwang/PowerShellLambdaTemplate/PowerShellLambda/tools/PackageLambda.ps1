param (
    [string]$ConfigName = 'psl_default',
    [string]$ConfigPath
)

if ($PSEdition -eq 'Desktop') {
    throw 'This deployment script only works with PS Core version'
}

#region helper function
function Get-PSLConfig {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $Path,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $ConfigName
    )
    try {
        $ConfigContent = Get-Content -Path $Path -Raw
        $Config = ConvertFrom-Json -InputObject $ConfigContent | Select-Object -ExpandProperty $ConfigName
    }
    catch {
        $TError = $error[0]
        throw "Error: $TError"
    }
    Finally {
        $Config
    }
}
#endregion helper function

#region parameters
# The lambda name should be under 25 so it doesn't get truncated.
$RootFolderPath = Split-Path -Path $PSScriptRoot -Parent
$toolsFolderPath = Join-Path -Path $RootFolderPath -ChildPath 'tools'
$srcFolderPath = Join-Path -Path $RootFolderPath -ChildPath 'src'
$artifactFolderPath = Join-Path -Path $RootFolderPath -ChildPath 'artifact'


# Using the default config.json path
if ($ConfigPath -eq '') {
    $ConfigPath = Join-Path $toolsFolderPath -ChildPath 'psl_config.json'
}

Write-Verbose "ConfigPath: $ConfigPath" -verbose

try {
    $Config = Get-PSLConfig -Path $ConfigPath -ConfigName $ConfigName -ErrorAction Stop
}
catch {
    throw 'Missing Config.'
}

$lambdaname = $Config.lambdaname

$ScriptPath = Join-Path -Path $srcFolderPath -ChildPath "$lambdaname.ps1"
$ArtifactPath = Join-Path -Path $artifactFolderPath -ChildPath "$lambdaname.zip"

$ModuleName = 'AWSPowerShell*'
if (-Not (Get-Module $ModuleName)) {
    Get-Module -name AWSPowerShell* -ListAvailable | Select-Object -First 1 | Import-Module
}

#endregion parameters

# Packaging the AWS PowerShell Lambda package to the artifact folder
New-AWSPowerShellLambdaPackage -ScriptPath $ScriptPath -OutputPackage $ArtifactPath -PowerShellSdkVersion ($PSVersionTable.PSVersion.ToString())
