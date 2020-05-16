param (
    [string]$ConfigName = 'psl_default',
    [string]$ConfigPath
)
#region helper function
function Get-PSLConfig {
    [cmdletbinding()]
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
$AWSRegion = $Config.AWSRegion

$ModuleName = 'AWSPowerShell*'
if (-Not (Get-Module $ModuleName)) {
    Get-Module -name AWSPowerShell* -ListAvailable | Select-Object -First 1 | Import-Module
}
Set-DefaultAWSRegion -Region $AWSRegion
#endregion parameters

if ($lambdaname.Length -le 20) {
    $Result = Get-LMFunctionList | Where-Object FunctionName -like "$lambdaname*" | Invoke-LMFunction
}
else {
    $Result = Get-LMFunctionList | Where-Object FunctionName -like "*$($lambdaname.Substring(0,20))*" | Invoke-LMFunction
}

$StreamReader = [System.IO.StreamReader]::new($Result.Payload)
$StreamReader.ReadToEnd()
