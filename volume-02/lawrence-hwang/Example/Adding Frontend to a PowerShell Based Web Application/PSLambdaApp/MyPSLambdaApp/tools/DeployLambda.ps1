param (
    [string]$ConfigName = 'psl_default',
    [string]$ConfigPath
)

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
    finally {
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
$s3bucketname = $Config.s3bucketname
$AWSRegion = $Config.AWSRegion

$s3prefix = $lambdaname
# $ScriptPath = Join-Path -Path $srcFolderPath -ChildPath "$lambdaname.ps1"
# $ArtifactPath = Join-Path -Path $artifactFolderPath -ChildPath "$lambdaname.zip"
$ServerlessTemplateFilePath = Join-Path -Path $srcFolderPath -ChildPath 'MyPSLambdaApp-serverless.template'
$UpdatedTemplateFilePath = Join-Path -Path $artifactFolderPath -ChildPath 'MyPSLambdaApp-updated.template'

$ModuleName = 'AWSPowerShell*'
if (-Not (Get-Module $ModuleName)) {
    Get-Module -name AWSPowerShell* -ListAvailable | Select-Object -First 1 | Import-Module
}
Set-DefaultAWSRegion -Region $AWSRegion
#endregion parameters

$Script = Get-ChildItem -Path $srcFolderPath -Filter *.ps1 -Exclude *.tests.ps1 -Recurse
foreach ($s in $Script) {
    $ScriptPath = $s.FullName
    $ArtifactPath = Join-Path -Path $artifactFolderPath -ChildPath "$($s.BaseName).zip"
    # Packaging the AWS PowerShell Lambda package.
    New-AWSPowerShellLambdaPackage -ScriptPath $ScriptPath -OutputPackage $ArtifactPath -PowerShellSdkVersion ($psversiontable.psversion.ToString())
}

# Transforming the template using the AWS CLI/ SAM CLI
# It uses the aws cloudformation package command
aws cloudformation package --template-file $ServerlessTemplateFilePath --s3-bucket $s3bucketname --s3-prefix $s3prefix --output-template-file $UpdatedTemplateFilePath --region $AWSRegion

# Deploy the transformed cloudformation template into the account. Here I am using the lambdaname as the stack name but really you can pick whatever you like.

# Obtaining the cfn override parameter
# The file, psl_cfnparam.property, can be used for overriding the CFN parameter defaults.
# Each line represent a CFN parameter and must be in following format:
# ParameterName=ParameterValue
# Hint: DO NOT put password in here.
try {
    $cfnparam = Get-Content "$PSScriptRoot\psl_cfnparam.property" -ErrorAction Stop
    $cfnparam
}
catch {
    $cfnparam = $null
}

if ([string]::IsNullOrWhiteSpace($cfnparam)) {
    # Nothing in the cfnparam file or the file does not exist.
    # Deploy using the default values in the CFN.
    aws cloudformation deploy --template-file $UpdatedTemplateFilePath --stack-name $lambdaname --capabilities CAPABILITY_IAM --region $AWSRegion
}
else {
    # cfn param specified, using it to override the CFN default values.
    aws cloudformation deploy --template-file $UpdatedTemplateFilePath --stack-name $lambdaname --capabilities CAPABILITY_IAM --parameter-overrides $cfnparam --region $AWSRegion
}
