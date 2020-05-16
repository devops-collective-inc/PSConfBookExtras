function Get-VICredentialStoreItem
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [alias('Host')]
        [string]
        ${Hostname} = '*',

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${User} = '*',

        [Parameter(Position = 2)]
        [string]
        ${Password},

        [Parameter(Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${File}
    )

    begin
    {
        try
        {
            $outBuffer = $null

            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $cmdletName = 'VMware.VimAutomation.Core\Get-VICredentialStoreItem'
            if ($PSEdition -eq 'Core')
            {
                $cmdletName = 'PCLIProxies\Get-VICredentialStoreItemCore'
            }
            $cmdletType = [System.Management.Automation.CommandTypes]::Cmdlet
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand($cmdletName, $cmdletType)

            $scriptCmd = { & $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch
        {
            throw
        }
    }

    process
    {
        try
        {
            $steppablePipeline.Process($_)
        }
        catch
        {
            throw
        }
    }

    end
    {
        try
        {
            $steppablePipeline.End()
        }
        catch
        {
            throw
        }
    }
    <#

.ForwardHelpTargetName VMware.VimAutomation.Core\New-VICredentialStoreItem
.ForwardHelpCategory Cmdlet

#>
}

function Get-VICredentialStoreItemCore
{
    param(
        [alias('Host')]
        [string]$HostName = '*',
        [string]$User = '*',
        [string]$File = "$HOME/.vicredentials.xml"
    )

    if (Test-Path -Path $File)
    {
        Import-Clixml -Path $File |
        Where-Object { $_.HostName -like $Host -and $_.User -like $User }
    }
}

function New-VICredentialStoreItem
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [alias('Host')]
        [string]
        ${Hostname},

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${User},

        [Parameter(Position = 2)]
        [string]
        ${Password},

        [Parameter(Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${File})

    begin
    {
        try
        {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $cmdletName = 'VMware.VimAutomation.Core\New-VICredentialStoreItem'
            if ($PSEdition -eq 'Core')
            {
                $cmdletName = 'PCLIProxies\New-VICredentialStoreItemCore'
            }
            $cmdletType = [System.Management.Automation.CommandTypes]::Cmdlet
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand($cmdletName, $cmdletType)
            $scriptCmd = { & $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch
        {
            throw
        }
    }

    process
    {
        try
        {
            $steppablePipeline.Process($_)
        }
        catch
        {
            throw
        }
    }

    end
    {
        try
        {
            $steppablePipeline.End()
        }
        catch
        {
            throw
        }
    }
    <#

.ForwardHelpTargetName VMware.VimAutomation.Core\New-VICredentialStoreItem
.ForwardHelpCategory Cmdlet

#>
}

function New-VICredentialStoreItemCore
{
    param(
        [alias('Host')]
        [string]$HostName,
        [string]$User,
        [string]$Password,
        [string]$File = "$HOME/.vicredentials.xml"
    )

    if (Test-Path -Path $File)
    {
        Import-Clixml -Path $File
    }
    New-Object -TypeName PSObject -Property @{
        Host = $HostName
        User = $User
        Password = $Password
    } | Export-Clixml -Path $File -Depth 2
}

function Remove-VICredentialStoreItem
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [alias('Host')]
        [string]
        ${Hostname},

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${User},

        [Parameter(Position = 2)]
        [string]
        ${Password},

        [Parameter(Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${File})

    begin
    {
        try
        {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $cmdletName = 'VMware.VimAutomation.Core\Remove-VICredentialStoreItem'
            if ($PSEdition -eq 'Core')
            {
                $cmdletName = 'PCLIProxies\Remove-VICredentialStoreItemCore'
            }
            $cmdletType = [System.Management.Automation.CommandTypes]::Cmdlet
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand($cmdletName, $cmdletType)
            $scriptCmd = { & $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch
        {
            throw
        }
    }

    process
    {
        try
        {
            $steppablePipeline.Process($_)
        }
        catch
        {
            throw
        }
    }

    end
    {
        try
        {
            $steppablePipeline.End()
        }
        catch
        {
            throw
        }
    }
    <#

.ForwardHelpTargetName VMware.VimAutomation.Core\New-VICredentialStoreItem
.ForwardHelpCategory Cmdlet

#>
}

function Remove-VICredentialStoreItemCore
{
    param(
        [cmdletbinding()]
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Pipeline')]
        [PSObject[]]$CredentialSToreItem,
        [parameter(ParameterSetName = 'Direct')]
        [alias('Host')]
        [string]$HostName = '*',
        [parameter(ParameterSetName = 'Direct')]
        [string]$User = '*',
        [parameter(ParameterSetName = 'Direct')]
        [string]$File = "$HOME/.vicredentials.xml"
    )

    Begin
    {
        if (Test-Path -Path $File)
        {
            $creds = Import-Clixml -Path $File
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'Pipeline')
        {
            foreach ($item in $CredentialSToreItem)
            {
                $creds = $creds |
                Where-Object { $_.HostName -notlike $item.Host -and $_.User -like $item.User }
            }
        }
        else
        {
            $creds = $creds |
            Where-Object { $_.Host -notlike $HostName -and $_.User -notlike $User }
        }
    }

    End
    {
        $creds | Export-Clixml -Path $File -Depth 2
    }
}

function Connect-VIServer
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'Default', Mandatory = $true, Position = 0)]
        [Parameter(ParameterSetName = 'SamlSecurityContext', Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${Server},

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'SamlSecurityContext')]
        [ValidateNotNull()]
        [ValidateRange(0, 65535)]
        [int]
        ${Port},

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'SamlSecurityContext')]
        [ValidateSet('http', 'https')]
        [string]
        ${Protocol},

        [Parameter(ParameterSetName = 'Default', ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        ${Credential},

        [Parameter(ParameterSetName = 'Default', ValueFromPipeline = $true)]
        [Alias('Username')]
        [string]
        ${User},

        [Parameter(ParameterSetName = 'Default')]
        [string]
        ${Password},

        [Parameter(ParameterSetName = 'Default')]
        [string]
        ${Session},

        [Parameter(ParameterSetName = 'SamlSecurityContext', Mandatory = $true, ValueFromPipeline = $true)]
        [VMware.VimAutomation.Common.Types.V1.Authentication.SamlSecurityContext]
        ${SamlSecurityContext},

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'SamlSecurityContext')]
        [switch]
        ${NotDefault},

        [Parameter(ParameterSetName = 'Default')]
        [switch]
        ${SaveCredentials},

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'SamlSecurityContext')]
        [switch]
        ${AllLinked},

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'SamlSecurityContext')]
        [switch]
        ${Force},

        [Parameter(ParameterSetName = 'Menu', Mandatory = $true)]
        [switch]
        ${Menu})

    begin
    {
        try
        {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            if ($PSEdition -eq 'Core')
            {
                $paramServer = $PSBoundParameters.ContainsKey('Server')
                $paramPassword = $PSBoundParameters.ContainsKey('Password')
                if ($paramServer -and -not $paramPassword)
                {
                    $item = Get-VICredentialStoreItemCore -HostName $Server
                    if ($item)
                    {
                        $PSBoundParameters.Add('User', $item.User)
                        $PSBoundParameters.Add('Password', $item.Password)
                    }
                }
            }
            $cmdletName = 'VMware.VimAutomation.Core\Connect-VIServer'
            $cmdletType = [System.Management.Automation.CommandTypes]::Cmdlet
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand($cmdletName, $cmdletType)
            $scriptCmd = { & $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch
        {
            throw
        }
    }

    process
    {
        try
        {
            $steppablePipeline.Process($_)
        }
        catch
        {
            throw
        }
    }

    end
    {
        if ($PSEdition -eq 'Core')
        {
            if ($PSBoundParameters.ContainsKey('SaveCredentials'))
            {
                $sNewItem = @{
                    HostName = $PSBoundParameters.ContainsKey('Server')
                    User = $PSBoundParameters.ContainsKey('User')
                    Password = $PSBoundParameters.ContainsKey('Password')
                }
                New-VICredentialStoreItemCore @sNewItem
            }
        }

        try
        {
            $steppablePipeline.End()
        }
        catch
        {
            throw
        }
    }
    <#

.ForwardHelpTargetName VMware.VimAutomation.Core\Connect-VIServer
.ForwardHelpCategory Cmdlet

#>
}

function Get-VMHostHardware
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'GetById')]
        [string[]]
        ${Id},

        [Parameter(ParameterSetName = 'Default', ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        ${VMHost},

        [switch]
        ${WaitForAllData},

        [switch]
        ${SkipCACheck},

        [switch]
        ${SkipCNCheck},

        [switch]
        ${SkipRevocationCheck},

        [switch]
        ${SkipAllSslCertificateChecks},

        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        ${Server})

    begin
    {
        try
        {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $cmdletName = 'VMware.VimAutomation.Core\Get-VMHostHardware'
            if ($PSEdition -eq 'Core')
            {
                $cmdletName = 'PCLIProxies\Get-VMHostHardwareCore'
            }
            $cmdletType = [System.Management.Automation.CommandTypes]::Cmdlet
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand($cmdletName, $cmdletType)
            $scriptCmd = { & $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch
        {
            throw
        }
    }

    process
    {
        try
        {
            $steppablePipeline.Process($_)
        }
        catch
        {
            throw
        }
    }

    end
    {
        try
        {
            $steppablePipeline.End()
        }
        catch
        {
            throw
        }
    }
    <#

.ForwardHelpTargetName VMware.VimAutomation.Core\Get-VMHostHardware
.ForwardHelpCategory Cmdlet

#>
}

function Get-VMHostHardwareCore
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'GetById')]
        [string[]]
        ${Id},

        [Parameter(ParameterSetName = 'Default', ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        ${VMHost},

        [switch]
        ${WaitForAllData},

        [switch]
        ${SkipCACheck},

        [switch]
        ${SkipCNCheck},

        [switch]
        ${SkipRevocationCheck},

        [switch]
        ${SkipAllSslCertificateChecks},

        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        ${Server})

    Process
    {
        $sEsxCli = @{
            VMHost = $VMHost
            V2 = $true
        }
        if ($Server)
        {
            $sEsxCli.Add('Server', $Server)
        }
        $esxcli = Get-EsxCli @sEsxCli
        New-Object -TypeName PSObject -Property ([ordered]@{
                AssetTag = $esxcli.hardware.platform.get.Invoke().BIOSAssetTag
                BiosVersion = $VMHost.ExtensionData.Hardware.BiosInfo.BiosVersion
                CpuCoreCountTotal = $VMHost.ExtensionData.Hardware.CpuInfo.NumCpuCores
                CpuCount = $VMHost.ExtensionData.Hardware.CpuInfo.NumCpuPackages
                CpuModel = $VMHost.ExtensionData.Summary.Hardware.CpuModel
                Manufacturer = $VMHost.Manufacturer
                MemoryModules = @()
                MemorySlotCount = $null
                MhzPerCpu = $VMHost.ExtensionData.Summary.Hardware.CpuMhz
                Model = $VMHost.Model
                NicCount = $VMHost.ExtensionData.Summary.Hardware.NumNics
                PowerSupplies = $null
                SerialNumber = $esxcli.hardware.platform.get.Invoke().SerialNumber
                Uid = $VMHost.Uid
                VMHost = $VMHost
            })

    }
}

function Open-VmConsoleWindow
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [VMware.VimAutomation.ViCore.Types.V1.VM.RemoteConsoleVM[]]
        ${VM},

        [switch]
        ${FullScreen},

        [switch]
        ${UrlOnly},

        [VMware.VimAutomation.Sdk.Types.V1.VIConnection[]]
        ${Server})

    begin
    {
        try
        {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $cmdletName = 'VMware.VimAutomation.Core\Open-VmConsoleWindow'
            if ($PSEdition -eq 'Core')
            {
                $cmdletName = 'PCLIProxies\Open-VmConsoleWindowCore'
            }
            $cmdletType = [System.Management.Automation.CommandTypes]::Cmdlet
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand($cmdletName, $cmdletType)
            $scriptCmd = { & $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch
        {
            throw
        }
    }

    process
    {
        try
        {
            $steppablePipeline.Process($_)
        }
        catch
        {
            throw
        }
    }

    end
    {
        try
        {
            $steppablePipeline.End()
        }
        catch
        {
            throw
        }
    }
    <#

.ForwardHelpTargetName VMware.VimAutomation.Core\Open-VMConsoleWindow
.ForwardHelpCategory Cmdlet

#>
}

function Open-VmConsoleWindowCore
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [VMware.VimAutomation.ViCore.Types.V1.VM.RemoteConsoleVM[]]
        ${VM},

        [switch]
        ${FullScreen},

        [switch]
        ${UrlOnly},

        [VMware.VimAutomation.Sdk.Types.V1.VIConnection[]]
        ${Server})

    $mks = $VM.ExtensionData.AcquireMksTicket()
    $parm = "vmrc://$($vm.VMHost.Name):902/?mksticket=$($mks.Ticket)&thumbprint=$($mks.SslThumbPrint)&path=$($mks.CfgFile)"
    if (UrlOnly)
    {
        $parm
    }
    else
    {
        & "vmrc" $parm
    }
}
