class MyOBN:System.Management.Automation.ArgumentTransformationAttribute
{
    [ValidateSet(
        'Cluster', 'Datacenter', 'Datastore', 'DatastoreCluster', 'Folder',
        'VirtualMachine', 'VirtualSwitch', 'VMHost', 'VIServer'
    )]
    [String]$Type
    MyOBN([string]$Type)
    {
        $this.Type = $Type
    }
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object]$inputData)
    {
        if ($inputData -is [string])
        {
            if (-NOT [string]::IsNullOrWhiteSpace( $inputData ))
            {
                $cmdParam = "-$(if($this.Type -eq 'VIServer'){'Server'}else{'Name'}) $($inputData)"
                $sCmd = @{
                    Command = "Get-$($this.Type.Replace('VirtualMachine','VM')) $($cmdParam)"
                }
                return (Invoke-Expression @sCmd)
            }
        }
        elseif ($inputData.GetType().Name -match "$($this.Type)Impl")
        {
            return $inputData
        }
        elseif ($inputData.GetType().Name -eq 'Object[]')
        {
            return ($inputData | ForEach-Object {
                    if ($_ -is [String])
                    {
                        return (Invoke-Expression -Command "Get-$($this.Type.Replace('VirtualMachine','VM')) -Name `$_")
                    }
                    elseif ($_.GetType().Name -match "$($this.Type)Impl")
                    {
                        $_
                    }
                })
        }
        throw [System.IO.FileNotFoundException]::New()
    }
}
function Invoke-VMScriptPlus
{
    <#
.SYNOPSIS
  Runs a script in a Linux guest OS.
  The script can use the SheBang to indicate which interpreter to use.
  .DESCRIPTION
  This function will launch a script in a Linux guest OS.
  The script supports the SheBang line for a limited set of interpreters.
.NOTES
  Author:  Luc Dekens
  Version:
  1.0 14/09/17  Initial release
  1.1 14/10/17  Support bash here-document
  2.0 01/08/18  Support Windows guest OS, bat & powershell
  2.1 03/08/18  PowerShell she-bang for Linux
  2.2 17/08/18  Added ScriptEnvironment
  2.3 11/03/19  Resolve IP to FQDN to support certificate for ESXi node
  2.4 22/04/19  Switch to provide password inline to 'sudo' lines
  2.5 07/06/19  Switch WaitForToolsVersionChange to wait for a version change
.PARAMETER VM
  Specifies the virtual machines on whose guest operating systems
  you want to run the script.
.PARAMETER GuestUser
  Specifies the user name you want to use for authenticating with the
  virtual machine guest OS.
.PARAMETER GuestPassword
  Specifies the password you want to use for authenticating with the
  virtual machine guest OS.
.PARAMETER GuestCredential
  Specifies a PSCredential object containing the credentials you want
  to use for authenticating with the virtual machine guest OS.
.PARAMETER ScriptText
  Provides the text of the script you want to run. You can also pass
  to this parameter a string variable containing the path to the script.
  Note that the function will add a SheBang line, based on the ScriptType,
  if none is provided in the script text.
.PARAMETER ScriptType
  The supported Linux interpreters.
  Currently these are bash,perl,python3,nodejs,php,lua
.PARAMETER ScriptEnvironment
  A string array with environment variables.
  These environment variables are available to the script from ScriptText
.PARAMETER GuestOSType
  Indicates which type of guest OS the VM is using.
  The parameter accepts Windows or Linux. This parameter is a fallback for
  when the function cannot determine which OS Family the Guest OS
  belongs to
.PARAMETER
  Indicates which PowerShell Core version to use.
  The default is 6.0.2
.PARAMETER CRLF
  Switch to indicate of the NL that is returned by Linux, shall be
  converted to a CRLF
.PARAMETER Sudo
  Switch to convert all 'sudo' lines to an inline password 'sudo' line.
  Only taken into account when the GuestOSType is 'Linux'
.PARAMETER KeepFiles
  Switch to indicate that the temporary files, the script and the output files,
  shall not be deleted.
  Only to be used for debugging purposes.
.PARAMETER Server
  Specifies the vCenter Server systems on which you want to run the
  cmdlet. If no value is passed to this parameter, the command runs
  on the default servers. For more information about default servers,
  see the description of Connect-VIServer.
.PARAMETER WaitForToolsVersionChange
  When the invoked code changes the version of the VMware Tools, this switch
  tells the function to wait till this version change is visible in the script
.EXAMPLE
  $pScript = @'
  #!/usr/bin/env perl
  use strict;
  use warnings;
  print "Hello world\n";
  '@
  $sCode = @{
  VM = $VM
  GuestCredential = $cred
  ScriptType = 'perl'
  ScriptText = $pScript
  }
  Invoke-VMScriptPlus @sCode
.EXAMPLE
  $pScript = @'
  print("Happy 10th Birthday PowerCLI!")
  '@
  $sCode = @{
  VM = $VM
  GuestCredential = $cred
  ScriptType = 'python3'
  ScriptText = $pScript
  }
  Invoke-VMScriptPlus @sCode
  #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [MyOBN('VirtualMachine')]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]$VM,
        [Parameter(Mandatory = $true, ParameterSetName = 'PlainText')]
        [String]$GuestUser,
        [Parameter(Mandatory = $true, ParameterSetName = 'PlainText')]
        [SecureString]$GuestPassword,
        [Parameter(Mandatory = $true, ParameterSetName = 'PSCredential')]
        [PSCredential[]]$GuestCredential,
        [Parameter(Mandatory = $true)]
        [String]$ScriptText,
        [Parameter(Mandatory = $true)]
        [ValidateSet('bash', 'perl', 'python3', 'nodejs', 'php', 'lua', 'powershell',
            'powershellv6', 'powershellv6snap', 'bat')]
        [String]$ScriptType,
        [String[]]$ScriptEnvironment,
        [ValidateSet('Windows', 'Linux')]
        [String]$GuestOSType,
        [String]$PSv6Version = '6.0.2',
        [Switch]$CRLF,
        [Switch]$Sudo,
        [Switch]$KeepFiles,
        [MyOBN('VIServer')]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer]$Server = $global:DefaultVIServer,
        [Switch]$WaitForToolsVersionChange
    )
    Begin
    {
        $si = Get-View ServiceInstance
        $guestMgr = Get-View -Id $si.Content.GuestOperationsManager
        $gFileMgr = Get-View -Id $guestMgr.FileManager
        $gProcMgr = Get-View -Id $guestMgr.ProcessManager
        $shebangTab = @{
            'bash' = '#!/usr/bin/env bash'
            'perl' = '#!/usr/bin/env perl'
            'python3' = '#!/usr/bin/env python3'
            'nodejs' = '#!/usr/bin/env nodejs'
            'php' = '#!/usr/bin/env php'
            'lua' = '#!/usr/bin/env lua'
            'powershellv6' = '#!/usr/bin/pwsh'
            'powershellv6snap' = '#!/snap/bin/pwsh'
        }
    }
    Process
    {
        foreach ($vmInstance in $VM)
        {
            # Preamble
            if ($vmInstance.PowerState -ne 'PoweredOn')
            {
                Write-Error "VM $($vmInstance.Name) is not powered on"
                continue
            }
            if ($vmInstance.ExtensionData.Guest.ToolsRunningStatus -ne 'guestToolsRunning')
            {
                Write-Error "VMware Tools are not running on VM $($vmInstance.Name)"
                continue
            }
            $moref = $vmInstance.ExtensionData.MoRef

            # Create Authentication Object (User + Password)
            if ($PSCmdlet.ParameterSetName -eq 'PSCredential')
            {
                $GuestUser = $GuestCredential.GetNetworkCredential().username
                $plainGuestPassword = $GuestCredential.GetNetworkCredential().password
            }
            if ($PSCmdlet.ParameterSetName -eq 'PlainText')
            {
                $bStr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($GuestPassword)
                $plainGuestPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bStr)
            }
            $auth = New-Object VMware.Vim.NamePasswordAuthentication
            $auth.InteractiveSession = $false
            $auth.Username = $GuestUser
            $auth.Password = $plainGuestPassword

            # Are we targetting a Windows or a Linux box?
            # Try to find out
            if (-not $GuestOSType)
            {
                switch -Regex ($vmInstance.Guest.OSFullName)
                {
                    'Windows'
                    {
                        $GuestOSType = 'Windows'
                        if ('bat', 'powershell', 'powershellv6' -notcontains $ScriptType)
                        {
                            Write-Error "For a Windows guest OS the ScriptType can be Bat, PowerShell or PowerShellv6"
                            continue
                        }
                    }
                    'Linux'
                    {
                        $GuestOSType = 'Linux'
                        if ('bat', 'powershell' -contains $ScriptType)
                        {
                            Write-Error "For a Linux guest OS the ScriptType cannot be Bat or PowerShell"
                            continue
                        }
                    }
                    Default
                    {
                        Write-Error "Unable to determine the guest OS type on VM $($vmInstance.Name)"
                        continue
                    }
                }
            }
            if ($GuestOSType -eq 'Linux')
            {
                Write-Verbose "Seems to be a Linux guest OS"
                # Test if code contains a SheBang, otherwise add it
                $targetCode = $shebangTab[$ScriptType]
                if ($ScriptText -notmatch "^$($targetCode)")
                {
                    Write-Verbose "Add SheBang $targetCode"
                    $ScriptText = "$($targetCode)`n`r$($ScriptText)"
                }
                # Take care of the 'sudo' switch
                if ($Sudo)
                {
                    $ScriptText = ($ScriptText | ForEach-Object -Process {
                            $_ -replace 'sudo', "echo $plainGuestPassword | sudo -S"
                        })
                }
            }
            # Copy script to temp file in guest
            # Create temp file for script
            $suffix = ''
            if ($ScriptType -eq 'bat')
            {
                $suffix = ".cmd"
            }
            if ('powershell', 'powershellv6' -contains $ScriptType)
            {
                $suffix = ".ps1"
            }
            Try
            {
                $tempFile = $gFileMgr.CreateTemporaryFileInGuest($moref, $auth, "$($env:USERNAME)_$($PID)", $suffix, $null)
                Write-Verbose "Created temp script file in guest OS $($tempFile.Name)"
            }
            Catch
            {
                Throw "$error[0].Exception.Message"
            }
            # Create temp file for output
            Try
            {
                $tempOutput = $gFileMgr.CreateTemporaryFileInGuest($moref, $auth, "$($env:USERNAME)_$($PID)_output", $null, $null)
                Write-Verbose "Created temp output file in guest OS $($tempOutput.Name)"
            }
            Catch
            {
                Throw "$error[0].Exception.Message"
            }
            # Copy script to temp file
            if ($GuestOSType -eq 'Linux')
            {
                $ScriptText = $ScriptText.Split("`r") -join ''
            }
            $attr = New-Object VMware.Vim.GuestFileAttributes
            $clobber = $true
            $filePath = $gFileMgr.InitiateFileTransferToGuest($moref, $auth, $tempFile, $attr, $ScriptText.Length, $clobber)
            $ip = $filePath.split('/')[2].Split(':')[0]
            $hostName = Resolve-DnsName -Name $ip | Select-Object -ExpandProperty NameHost
            $filePath = $filePath.replace($ip, $hostName)
            $copyResult = Invoke-WebRequest -Uri $filePath -Method Put -Body $ScriptText
            if ($copyResult.StatusCode -ne 200)
            {
                Throw "ScripText copy failed!`rStatus $($copyResult.StatusCode)`r$(($copyResult.Content | ForEach-Object{[char]$_}) -join '')"
            }
            Write-Verbose "Copied scipttext to temp script file"

            # Get current environment variables

            $SystemEnvironment = $gProcMgr.ReadEnvironmentVariableInGuest($moref, $auth, $null)

            # Run script
            if ($WaitForToolsVersionChange)
            {
                $toolsVersion = $vmInstance.ExtensionData.Guest.ToolsVersion
            }
            switch ($GuestOSType)
            {
                'Linux'
                {
                    # Make temp file executable
                    $spec = New-Object VMware.Vim.GuestProgramSpec
                    $spec.Arguments = "751 $tempFile"
                    $spec.ProgramPath = '/bin/chmod'
                    Try
                    {
                        $procId = $gProcMgr.StartProgramInGuest($moref, $auth, $spec)
                        Write-Verbose "Run script file"
                    }
                    Catch
                    {
                        Throw "$error[0].Exception.Message"
                    }
                    # Run temp file
                    $spec = New-Object VMware.Vim.GuestProgramSpec
                    if ($ScriptEnvironment)
                    {
                        $spec.EnvVariables = $SystemEnvironment + $ScriptEnvironment
                    }
                    $spec.Arguments = " > $($tempOutput) 2>&1"
                    $spec.ProgramPath = "$($tempFile)"
                    Try
                    {
                        $procId = $gProcMgr.StartProgramInGuest($moref, $auth, $spec)
                        Write-Verbose "Run script with '$($tempFile) > $($tempOutput)'"
                    }
                    Catch
                    {
                        Throw "$error[0].Exception.Message"
                    }
                }
                'Windows'
                {
                    # Run temp file
                    $spec = New-Object VMware.Vim.GuestProgramSpec
                    if ($ScriptEnvironment)
                    {
                        $spec.EnvVariables = $SystemEnvironment + $ScriptEnvironment
                    }
                    switch ($ScriptType)
                    {
                        'PowerShell'
                        {
                            $spec.Arguments = " /C powershell -NonInteractive -File $($tempFile) > $($tempOutput)"
                            $spec.ProgramPath = "cmd.exe"
                        }
                        'PowerShellv6'
                        {
                            $spec.Arguments = " /C ""C:\Program Files\PowerShell\$($PSv6Version)\pwsh.exe"" -NonInteractive -File $($tempFile) > $($tempOutput)"
                            $spec.ProgramPath = "cmd.exe"
                        }
                        'Bat'
                        {
                            $spec.Arguments = " /s /c cmd > $($tempOutput) 2>&1 /s /c $($tempFile)"
                            $spec.ProgramPath = "cmd.exe"
                        }
                    }
                    Try
                    {
                        $procId = $gProcMgr.StartProgramInGuest($moref, $auth, $spec)
                        Write-Verbose "Run script with '$($spec.ProgramPath) $($spec.Arguments)'"
                    }
                    Catch
                    {
                        Throw "$error[0].Exception.Message"
                    }
                }
            }
            if ($WaitForToolsVersionChange)
            {
                Write-Verbose "Waiting for VMware Tools version to change"
                while ($toolsVersion -eq $vmInstance.ExtensionData.Guest.ToolsVersion)
                {
                    Start-Sleep -Seconds 1
                    $vmInstance.ExtensionData.UpdateViewData('Guest')
                }
                Write-Verbose "VMware Tools version changed from $toolsVersion to $($vmInstance.ExtensionData.Guest.ToolsVersion)"
            }

            # Wait for script to finish
            Try
            {
                $pInfo = $gProcMgr.ListProcessesInGuest($moref, $auth, @($procId))
                Write-Verbose "Wait for process to end"
                while ($pInfo -and $null -eq $pInfo.EndTime)
                {
                    Start-Sleep 1
                    $pInfo = $gProcMgr.ListProcessesInGuest($moref, $auth, @($procId))
                }
            }
            Catch
            {
                Throw "$error[0].Exception.Message"
            }
            # Retrieve output from script
            $fileInfo = $gFileMgr.InitiateFileTransferFromGuest($moref, $auth, $tempOutput)
            $ip = $fileInfo.Url.split('/')[2].Split(':')[0]
            $hostName = Resolve-DnsName -Name $ip | Select-Object -ExpandProperty NameHost
            $filePath = $fileInfo.Url.replace($ip, $hostName)
            $fileContent = Invoke-WebRequest -Uri $filePath -Method Get
            if ($fileContent.StatusCode -ne 200)
            {
                Throw "Retrieve of script output failed!`rStatus $($fileContent.Status)`r$(($fileContent.Content | ForEach-Object{[char]$_}) -join '')"
            }
            Write-Verbose "Get output from $($fileInfo.Url)"
            # Clean up
            # Remove output file
            if (-not $KeepFiles)
            {
                $gFileMgr.DeleteFileInGuest($moref, $auth, $tempOutput)
                Write-Verbose "Removed file $($tempOutput.Name)"
                # Remove temp script file
                $gFileMgr.DeleteFileInGuest($moref, $auth, $tempFile)
                Write-Verbose "Removed file $($tempFile.Name)"
            }

            # Package result in object
            New-Object PSObject -Property @{
                VM = $vmInstance
                ScriptOutput = & {
                    $out = ($fileContent.Content | ForEach-Object { [char]$_ }) -join ''
                    if ($CRLF)
                    {
                        $out.Replace("`n", "`n`r")
                    }
                    else
                    {
                        $out
                    }
                }
                Pid = $procId
                PidOwner = $pInfo.Owner
                Start = $pInfo.StartTime
                Finish = $pInfo.EndTime
                ExitCode = $pInfo.ExitCode
                ScriptType = $ScriptType
                ScriptSize = $ScriptText.Length
                ScriptText = $ScriptText
                GuestOS = $GuestOSType
            }
        }
    }
}