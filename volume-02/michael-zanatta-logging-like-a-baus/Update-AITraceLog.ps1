#region Update-AITraceLog
#function to send an Applaction Insights Log Event
#----------------------------------------------------------------------------------------------------
function Update-AITraceLog() {
    <#
    .SYNOPSIS
    This function creates a custom event in an application insights.

    .DESCRIPTION
    This function create a custom event within Azure Application Insights.
    This function extends the functionality of Update-TraceLog, by providing the following benefits:

    1. Error StackTrace Log Events
    2. Added ability for users to add custom properties to the event.
    3. Automatic Object Seraliziation for Debugging and Reporting.
       Please note that collections are not supported at this time, due to limiations with Application insights.
    4. To improve the usability of the cmdlet, the following variables can be set in the parent:
        1. $ScriptName. Will automatically set -ResourceName parameter.
        2. $AppInsightsInstrumentationKey. Will automatically set the -InstrumentationKey parameter.
        3. $PSRunspaceFactory. Will automatically set the -AsyncPSRunspaceFactory parameter
    5. Asynchronous Logging. To reduce the performance impact of remote cloud logging, this function can create event's asynchronously.
       To create an async event, you will need to do the following:

        Creation of a PowerShell Runspace:

        # CreateRunspacePool(Minimum sessions, Maximum sessions)
        $MaxJobsAvaliable = 5
        $PowerShellRunspace = [runspacefactory]::CreateRunspacePool(1,$MaxJobsAvaliable)
        $PowerShellRunspace.Open()

        Once your code has been completed, you will need to await any outstanding jobs that are running:

        # Await all PowerShell Jobs to be completed, or you will be missing data
        do { Start-Sleep -Milliseconds 250 } Until ($PSRunspace.GetAvailableRunspaces() -eq $MaxJobsAvaliable)
        # Dispose of the RunspacePool
        $PowerShellRunspace.Dispose()

    This module has the following dependencies:

    -> PowerShell Version: 5.1 or Highter (To Support PowerShell Runspaces)
    -> PowerShell Module: ApplicationInsightsCustomEvents (https://gallery.technet.microsoft.com/scriptcenter/Log-Custom-Events-into-847900d7)

    .NOTES
    AUTHOR  : Michael Zanatta
    CREATED : 12/08/2019
    VERSION : BETA 0.5
            0.5 - Update to AsyncPSRunspaceFactory
                Added $PSRunspaceFactory variable to -AsyncPSRunspaceFactory
                Updated Documentation
            0.4 - Code Refactor and Updates
                Added Async Logging to Improve Performance
                Added Documentation
                Refactored Parameters
            0.3 - Code Refactor and Updates
                Added Custom Object Serialization Feature
            0.2 - Code Refactor and Updates
                Added Hashtable Feature
            0.1 - Initial Revision


    .INPUTS
        System.String[]

    .OUTPUTS
        System.Collections.Hashtable[]

    .PARAMETER Detail
    Initial log entry describing the action.

    .PARAMETER customHashTable
    A custom hashtable can be parsed into for custom object creation. The properties are prefixed with custom_.

    .PARAMETER customObject
    For debugging purposes; An object can be parsed into the cmdlet to be serialized in the log entry. The custom object property will be called "custom_object"

    .PARAMETER errorDetails
    Used by Get-AIError ; This is used by Get-AIError to transform the cmdlet into a stacktrace error.

    .PARAMETER type
    Describes the stream type of the log event. Values are:
        (Default) Information, Warning, Error, Verbose, Debug

    .PARAMETER InstrumentationKey
    The instrumentation key identifies the resource that you want to associate your telemetry data with (ie. What Application Insights Instance).
    To prevent the reuse of the InstrumentationKey, set the variable: $AppInsightsInstrumentationKey to be the key.

    .PARAMETER ResourceName
    Script/ Runbook Name of the Script.
    To prevent to reuse of the ResourceName, set the variable: $ScriptName

    .PARAMETER AsyncPSRunspaceFactory
    Specifying a PowerShell Runspace Factory will allow this cmdlet to process the log events a asynchronous events. The runspace pool will need to be handled
    by the parent:

        Creation of a PowerShell Runspace:

        # Source:
        # https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.runspaces.runspacefactory.createrunspacepool?view=pscore-6.2.0
        # CreateRunspacePool(minRunspaces, maxRunspaces)
        #Parameters
        #minRunspaces: The minimum number of Runspaces that exist in this pool. Should be greater than or equal to 1.
        #maxRunspaces: The maximum number of Runspaces that can exist in this pool. Should be greater than or equal to 1.

        $MaxJobsAvaliable = 5
        $PowerShellRunspace = [runspacefactory]::CreateRunspacePool(1,$MaxJobsAvaliable)
        $PowerShellRunspace.Open()

        Once your code has been completed, you will need to await any outstanding jobs that are running:

        # Await all PowerShell Jobs to be completed, or you will be missing data
        do { Start-Sleep -Milliseconds 250 } Until ($PowerShellRunspace.GetAvailableRunspaces() -eq $MaxJobsAvaliable)
        # Dispose of the RunspacePool
        $PowerShellRunspace.Dispose()


    .PARAMETER pesterShouldReturnParams
    Used in Unit Testing. This returns the parameter block for pester to check.

    .EXAMPLE
        Update-AITraceLog -Detail "This is a log entry" -InstrumentationKey "123" -ResourceName "TestScript.ps1"

        Description
        -----------
        This is the default execution. This will create a synchronous information log event.

    .EXAMPLE

        Update-AITraceLog -Detail "This is a log entry" -InstrumentationKey "123" -ResourceName "TestScript.ps1" -Type Error

        Description
        -----------
        This will create a synchronous Error log event.

    .EXAMPLE

        $AppInsightsInstrumentationKey = "123"
        $ScriptName = "DEMO.PS1"

        Update-AITraceLog -Detail "This is a log entry"

        Description
        -----------
        This will create a synchronous information log event, bypassing the need for using the -InstrumentationKey & -ResourceName parameter.

    .EXAMPLE

        # Create the Runspace Pool
        $PSRunspace = [runspacefactory]::CreateRunspacePool(1,1)
        $PSRunspace.Open()

        $AppInsightsInstrumentationKey = "123"
        $ScriptName = "DEMO.PS1"

        # Log the Event
        Update-AITraceLog -Detail "This is a log entry" -Type Debug -AsyncPSRunspaceFactory $PSRunspace

        # Cleanup
        # Await all PowerShell Jobs to be completed, or you will be missing data
        do { Start-Sleep -Milliseconds 250 } Until ($PSRunspace.GetAvailableRunspaces() -eq $MaxJobsAvaliable)
        # Dispose of the RunspacePool
        $PowerShellRunspace.Dispose()

        Description
        -----------
        This will create a asynchronous debug log event using a PowerShell runspace pool.
        It also bypassing the need for using the -InstrumentationKey & -ResourceName parameter.

    .EXAMPLE

        # Create the Runspace Pool
        $PSRunspaceFactory = [runspacefactory]::CreateRunspacePool(1,1)
        $PSRunspaceFactory.Open()

        $AppInsightsInstrumentationKey = "123"
        $ScriptName = "DEMO.PS1"

        # Log the Event
        Update-AITraceLog -Detail "This is a log entry" -Type Debug

        # Cleanup
        # Await all PowerShell Jobs to be completed, or you will be missing data
        do { Start-Sleep -Milliseconds 250 } Until ($PSRunspaceFactory.GetAvailableRunspaces() -eq $MaxJobsAvaliable)
        # Dispose of the RunspacePool
        $PSRunspaceFactory.Dispose()

        Description
        -----------
        This will create a asynchronous debug log event using a PowerShell runspace pool, bypassing the need for using the -InstrumentationKey, -ResourceName and -AsyncPSRunspaceFactory parameters.

    #>

    #Requires -version 5.1
    #------------------------------------------------------------------------------------------------
    [cmdletbinding(
        DefaultParameterSetName = 'Standard'
    )]
    param (
        [parameter(Mandatory,ParameterSetName = 'Standard', Position = 0, ValueFromPipeline)]
        [parameter(Mandatory,ParameterSetName = 'ExpandedHashTable', Position = 0, ValueFromPipeline)]
        [parameter(Mandatory,ParameterSetName = 'ExpandedObject', Position = 0, ValueFromPipeline)]
        [parameter(Mandatory,ParameterSetName = 'Error', Position = 0, ValueFromPipeline)]
        [String]
        $detail,
        [parameter(ParameterSetName = 'Standard', Position = 1)]
        [parameter(ParameterSetName = 'ExpandedHashTable', Position = 1)]
        [System.Collections.Hashtable]
        $customHashTable,
        [parameter(ParameterSetName = 'Standard', Position = 1)]
        [parameter(ParameterSetName = 'ExpandedObject', Position = 1)]
        [Object]
        $customObject,
        [parameter(ParameterSetName = 'Standard', Position = 1)]
        [parameter(ParameterSetName = 'Error', Position = 1)]
        [System.Collections.Hashtable]
        $errorDetails,
        [parameter(Position = 2, ParameterSetName = 'Standard')]
        [parameter(Position = 2, ParameterSetName = 'ExpandedHashTable')]
        [parameter(Position = 2, ParameterSetName = 'ExpandedObject')]
        [parameter(Position = 2, ParameterSetName = 'Error')]
        [string]
        [ValidateSet("Information", "Warning", "Error", "Verbose", "Debug")]
        $type="Information",
        [parameter(Position = 3, ParameterSetName = 'Standard')]
        [parameter(Position = 3, ParameterSetName = 'ExpandedHashTable')]
        [parameter(Position = 3, ParameterSetName = 'ExpandedObject')]
        [parameter(Position = 3, ParameterSetName = 'Error')]
        [String]
        $InstrumentationKey = $AppInsightsInstrumentationKey,
        [parameter(Position = 4, ParameterSetName = 'Standard')]
        [parameter(Position = 4, ParameterSetName = 'ExpandedHashTable')]
        [parameter(Position = 4, ParameterSetName = 'ExpandedObject')]
        [parameter(Position = 4, ParameterSetName = 'Error')]
        [String]
        $ResourceName = $ScriptName,
        [parameter(Position = 5, ParameterSetName = 'Standard')]
        [parameter(Position = 5, ParameterSetName = 'ExpandedHashTable')]
        [parameter(Position = 5, ParameterSetName = 'ExpandedObject')]
        [parameter(Position = 5, ParameterSetName = 'Error')]
        [System.Management.Automation.Runspaces.RunspacePool]
        $AsyncPSRunspaceFactory = $PSRunspaceFactory,
        [parameter(Position = 6, ParameterSetName = 'Standard')]
        [parameter(Position = 6, ParameterSetName = 'ExpandedHashTable')]
        [parameter(Position = 6, ParameterSetName = 'ExpandedObject')]
        [parameter(Position = 6, ParameterSetName = 'Error')]
        [Switch]
        $pesterShouldReturnParams
    )

    #Use the begin block to retrieve the component from the call stack, format the output and check if the logfile needs to be rolled over
    begin {

        # Set the Event Body Charachter Length
        $EventCharLimit = 4000
        # Set the Event Body Property Limit
        $PropertyLimit = 20

        # Throw an Error if the InstrumentationKey parameter is missing
        if (-not($InstrumentationKey)) {
            Throw "Missing -InstrumentationKey Parameter or Missing `$AppInsightsInstrumentationKey variable."
        }
        # Throw an Error if the ResourceName parameter is missing
        if (-not($ResourceName)) {
            Throw "Missing -ResourceName Parameter or Missing `$RunbookName variable."
        }

        #Retrieve the calling function using the call stack
        $callStack = Get-PSCallStack

        #Enumerate the members of the call stack to find the caller
        for ($i = 0; $i -le $callStack.Count; $i++) {

            #If the caller is the current function, move on
            if ($callStack[$i].Command -eq $($MyInvocation.MyCommand.Name)) {
                $i++

                #If the function was Get-AIError, get the next caller
                if ($callStack[$i].Command -eq "Get-AIError") {
                    $i++
                    $component = $callStack[$i].Command
                    break
                } else {
                    $component = $callStack[$i].Command
                    break
                }
            }
        }

    }
    process {
        # Capture the Event Date
        $EventDate = Get-Date

        # Define the Parameters for the Log
        $params = @{
            InstrumentationKey = $InstrumentationKey
            EventName = $ResourceName
            EventDictionary = [System.Collections.Generic.Dictionary[string,string]]::new()
        }

        # Build the Initial Events
        $params.EventDictionary.Add('ResourceName',$ResourceName)
        $params.EventDictionary.Add('EventType', $Type.ToUpper())
        $params.EventDictionary.Add('DateTimeLogged', (Get-Date $EventDate -Format "HH:mm:ss.ffffff"))
        $params.EventDictionary.Add('DateTimeLoggedUTC', (Get-Date $EventDate.ToUniversalTime() -Format "HH:mm:ss.ffffff"))
        $params.EventDictionary.Add('Component', $component)
        $params.EventDictionary.Add('Detail', $detail)

        # If the customItems Parameter was specified, add the key/values to the event. Otherwise write the details
        if ($customHashTable) {
            $customHashTable.Keys | ForEach-Object { $params.EventDictionary.Add(("custom_{0}" -f $_), $customHashTable[$_]) }
        }
        # If the customObject Parameter was specified, add the known properites to the event. Otherwise seralize the object as JSON
        if ($customObject) {

            # Add the Object to the parameterset
            $params.EventDictionary.Add('custom_object', ($customObject | ConvertTo-Json -Depth 2))

            #
            # Cleanup the JSON for kusto

            # Due to issues with how kusto parse_json serializes Dates, escape all dates twice.
            # Add an additional Escape character to the beginning of the datetime
            $params.EventDictionary.custom_object = $params.EventDictionary.custom_object.Replace('"\/Date(','"\\/Date(')
            # Add an additional Escape character to the end of the datetime
            $params.EventDictionary.custom_object = $params.EventDictionary.custom_object.Replace(')\/"',')\\/"')
            # Remove Blank Lines from the JSON
            $params.EventDictionary.custom_object = $params.EventDictionary.custom_object -replace '\s+\r\n+', "`r`n"
        }

        # Create a Dictonary Object
        switch ($type) {
            "Verbose" {
                # Print a Verbose Message
                Write-Verbose "$component`t$detail"
            }
            "Warning" {
                # Print a Warning
                Write-Warning "$component`t$detail"
            }
            "Error" {
                # If the Error Details was specified, then an object with each of the properties has been added.
                # Append that to the custom request.
                if ($errorDetails) {
                    # Remove the Details Key and Append the Error Details to the Event
                    if ($detail) {$params.EventDictionary.Remove('Detail') }
                    # Iterate Through Each of the Key's and Add them
                    $errorDetails.Keys | ForEach-Object { $params.EventDictionary.Add($_, $errorDetails[$_]) }
                }
                # Write the Error
                Write-Error "$component`t$detail"
            }
            "Debug" {
                # Print the Debug
                Write-Debug "$component`t$detail"
            }
            "Information" {
                # Print some Information
                Write-Information "$component`t$detail"
            }
        }

        # If the Parameter "-pesterShouldReturnParams" is called, return the parameters
        if ($pesterShouldReturnParams) { Write-Output $params }

        # If the parameter "-AsyncPSRunspaceFactory" is called, process the job asynchronously
        if ($AsyncPSRunspaceFactory) {

            #
            # Define the Async Scriptblock
            $ScriptBlock = {
                param(
                    [System.Collections.Hashtable]$hashtable
                )
                #Requires -Modules ApplicationInsightsCustomEvents

                $RetryCounter = 1
                # Loop
                Do {
                    try {
                        Log-ApplicationInsightsEvent @hashtable
                        # Break the Loop
                        break
                    } catch {
                        # Sleep for a Second
                        Start-Sleep -Seconds (4 * $RetryCounter)
                        # Increment Counter
                        $RetryCounter++
                    }
                } Until ($RetryCounter -eq 6)

            }

            # Create a Private Function to start the Job
            function Invoke-PSRunspace {
                # Create a new Powershell instance and connect to the existing passed runspace
                $newPowerShell = [PowerShell]::Create().AddScript($ScriptBlock).AddArgument($params)
                $newPowerShell.RunspacePool = $AsyncPSRunspaceFactory
                # Invoke the Job
                $null = $newPowerShell.BeginInvoke()
            }

            # Invoke the Async Call by Calling the Runspace
            Invoke-PSRunspace

        } else {
            # Define Retry Counter
            $RetryCounter = 1
            # Loop
            Do {
                try {
                    $null = Log-ApplicationInsightsEvent @params
                    # Break the Loop
                    break
                } catch {
                    # Print a non terminating error
                    Write-Warning $_
                    # Sleep for a Second
                    Start-Sleep -Seconds (4 * $RetryCounter)
                    # Increment Counter
                    $RetryCounter++
                }
            } Until ($RetryCounter -eq 6)
        }

    }
}
#endregion Update-AITraceLog
