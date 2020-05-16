

#region Write-ErrorLogLog
#function to handle errors
function Write-ErrorLog() {

    [CmdletBinding()]
    param (
        [parameter(Mandatory, Position = 0, ValueFromPipeline = $true)]
        [System.Management.Automation.ErrorRecord]
        $ErrorDetail
    )

    $logDetail = "Line: {0} Char: {1} Category: {2} Activity: {3} Target: {4} Error: {5}" -f `
            $ErrorDetail.InvocationInfo.ScriptLineNumber,
            $ErrorDetail.InvocationInfo.OffsetInLine,
            $ErrorDetail.CategoryInfo.Category,
            $ErrorDetail.CategoryInfo.Activity,
            $ErrorDetail.CategoryInfo.TargetName,
            $ErrorDetail.Exception.Message

    #Write to the logfile
    $logDetail | Write-TraceLog -stream Critical
}
#endregion Write-ErrorLog

#region Write-TraceLog
#function to update SMS Trace Log file
#----------------------------------------------------------------------------------------------------
function Write-TraceLog() {
    #------------------------------------------------------------------------------------------------
    [CmdletBinding()]
    param (
        [parameter(Mandatory, Position = 0, ValueFromPipeline = $true)]
        [String[]]
        $details,
        [parameter(Position = 1)]
        [string]
        [ValidateSet("Information", "Warning", "Critical", "Verbose", "Debug")]
        $Stream="Information",
        [parameter(Position = 2)]
        [String]
        $LogfilePath = $LogFile
    )
    #Use the begin block to retrieve the command from the call stack, format the output and check if the logfile needs to be rolled over
    begin {

        # Throw an Error if the logfile is missing
        if (-not($LogfilePath)) {
            Throw "Missing -path Parameter or Missing `$LogFile Varaible."
        }

        #Change the level of the logging based on log level, 1 is information, 2 is warning and 3 is error
        switch ($stream) {
            "Information" {
                $level = "1"
            }
            "Warning" {
                $level = "2"
            }
            "Critical" {
                $level = "3"
            }
            "Verbose" {
                $level = "4"
            }
            "Debug" {
                $level = "5"
            }
        }

        #Retrieve the calling function using the call stack
        $callStack = Get-PSCallStack

        #Enumerate the members of the call stack to find the caller
        $command = $(
                        if ($callstack[1].Command -eq "Write-ErrorLog") { Write-Output $callstack[2].Command }
                        else { Write-Output $callstack[1].Command}
                      )
        
        #
        # Perform a Log File Rollover
        #

        # Check if the logfile exists
        if (Test-Path -LiteralPath $LogfilePath -ErrorAction SilentlyContinue) {

            #Get the logfile object
            $logFileObject = Get-item -LiteralPath $LogfilePath

            #if the logfile size is greater than 10MB, roll it over
            if (($logFileObject.Length / 1024 / 1024) -ge 10) {

                #Set the rollover logfile name
                $rollOverFile = $logFileObject.FullName.Replace($logFileObject.Extension, ".lo_")

                # Remove the current log file if it exists
                if (Test-Path -LiteralPath $rollOverFile -ErrorAction SilentlyContinue) {
                    Remove-Item -LiteralPath "$($rollOverFile)" -Force
                }

                $RetryCounter = 1
                do {
                    try {
                        # Test if the logfile exists. If not, another concurrent process has rolled over the logfile.
                        # It can be skipped!
                        if (Test-Path -LiteralPath $LogfilePath) {
                            Rename-Item -LiteralPath $LogfilePath -NewName "$($logFileObject.BaseName).lo_" -Force
                        }
                        # Exit the Loop
                        break
                    } catch {
                        #Need to know if this is regularly failing due to the potential performance impact of the retry loop
                        Write-Warning $_
                        # Back off Exponentially. If the process is locked this will help pause it.
                        Start-Sleep -Seconds (2 * $RetryCounter)
                        $RetryCounter++
                    }
                } until ($RetryCounter -gt 3)
            }
        }
    }
    process {
        foreach ($detail in $details) {

            if ($level -eq 4) {
                Write-Verbose "$command`t$detail"
            } elseif ($level -eq 2) {
                Write-Warning "$command`t$detail"
            } elseif ($level -eq 3) {
                Write-Error "$command`t$detail"
            } elseif ($level -eq 5) {
                Write-Debug "$command`t$detail"
                # CMTrace Dosen't Support Debug. Use Verbose Instead
                $level = 4
            }
            else {
                #Write the output to the console
                Write-Information "$command`t$detail"
            }

            # Define Retry Counter
            $RetryCounter = 1

            Do {

                try {
                    #Format the log output into SMS Trace format

                    $LogEntry = "<![LOG[{0}]LOG]!><time=`"{1}`" date=`"{2}`" component=`"{3}`" context=`"`" type=`"{4}`" thread=`"{5}`" file=`"`">{6}" -f `
                        $detail,
                        (Get-Date -Format "HH:mm:ss.ffffff"),
                        (Get-Date -Format "MM-dd-yyyy"),
                        ("$($Global:ScriptName):$($command)"),
                        $level,
                        $pid,
                        [Environment]::NewLine

                    # Write the Entry
                    [System.IO.File]::AppendAllText($LogfilePath, $LogEntry)
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
#endregion Write-TraceLog


#region Examples
#
# An Example of Updating the TraceLog
#

Write-TraceLog "* * * * * * * * * * * * * * * Script Started * * * * * * * * * * * * * * * "
Write-TraceLog "Script Parameters:"
ForEach ($Key in $PsBoundParameters.Keys) {
    # Log each of the Parameters that were included.
    Write-TraceLog ("Parameter Name {0}: {1}" -f $([string]$Key), $($PsBoundParameters[$Key]))
}

#
# An Example of Capturing and Logging an Error
#

try {
    throw "Forced Error"
} catch {
    Write-ErrorLog $_
}

#endregion Examples