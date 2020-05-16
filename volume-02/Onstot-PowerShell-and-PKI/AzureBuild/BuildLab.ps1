$ErrorActionPreference = "Stop"
Write-Output 'Importing Modules...'
Import-Module az
#Enable-AzureRmAlias
$Connected = Get-AzContext
if (!($connected)) {
    # sign in
    Write-Host "Logging in...";
    Login-AzAccount;
}

$subs = Get-AzSubscription
if ($subs.count -gt 1) {
    Write-Output "More than 1 Subscription detected.  Select the subscript to use in the Out-GridView window that has openned, and then click OK to continue."
    $SubtoUse = $subs | Out-GridView -Title 'Select the Subscription to use for this deployment...' -PassThru
    $subscriptionId = $SubtoUse.SubscriptionId
}
else {
    Write-Host "Selecting subscription '$subscriptionId'";
    Select-AzureRmSubscription -SubscriptionID $subscriptionId;
    $subscriptionId = $Connected.Subscription.id        
}

#Set the Resource Group Name and Location
$resourceGroupLocation = "EastUS"
$resourceGroupName = "PKILab"
$templateFilePath = ".\template.json"
$i=1

$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if (!$resourceGroup) {
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if (!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else {
    Write-Host "Using existing resource group '$resourceGroupName'";
}

$TemplateFileName = @(".\DC1parameters.json", ".\ORCA1parameters.json", ".\CA1parameters.json", ".\CRL1parameters.json")
foreach ($Template in $TemplateFileName) {
    New-AzResourceGroupDeployment -resourceGroupName $resourceGroupName -Name PKILabBuild$i -templateFile $templateFilePath -TemplateParameterFile $Template -Verbose 
    $i++
}
