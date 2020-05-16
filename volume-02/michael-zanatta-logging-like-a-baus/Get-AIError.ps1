#region Get-AIError
#function to handle errors
#----------------------------------------------------------------------------------------------------
function Get-AIError() {
    #Requires -modules ApplicationInsightsCustomEvents
    #Download: ApplicationInsightsCustomEvents at: https://gallery.technet.microsoft.com/scriptcenter/Log-Custom-Events-into-847900d7
    #------------------------------------------------------------------------------------------------
    [CmdletBinding()]
    param (
        [parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [system.Management.Automation.ErrorRecord[]]
        $ErrorDetails
    )
    begin {
        #Check the  command exists
        if (-not(get-command -Name Log-ApplicationInsightsEvent -ErrorAction SilentlyContinue)) {
            throw "Required component Log-ApplicationInsightsEvent missing"
        }
    }
    process {
        #Enumerate each error object passed to the function
        foreach ($errObject in $ErrorDetails) {

            # Declare the Log Detail

            $logDetail = "Line: {0} Char: {1} Category: {2} Activity: {3} Target: {4} Error: {5}" -f `
            $errObject.InvocationInfo.ScriptLineNumber,
            $errObject.InvocationInfo.OffsetInLine,
            $errObject.CategoryInfo.Category,
            $errObject.CategoryInfo.Activity,
            $errObject.CategoryInfo.TargetName,
            $errObject.Exception.Message

            # Create a HashTable Object
            $errorHashTable = @{
                Line = $errObject.InvocationInfo.ScriptLineNumber
                Char = $errObject.InvocationInfo.OffsetInLine
                Category = $errObject.CategoryInfo.Category
                Activity = $errObject.CategoryInfo.Activity
                Target = $errObject.CategoryInfo.TargetName
                Error = $errObject.Exception.Message
            }

            #Update Application Insights
            Update-AITraceLog -type Error -detail $logDetail -errorDetails $errorHashTable
        }
    }
    end {
        #Clear the error object
        $null = $Error.Clear()
    }
}
#endregion Get-AIError