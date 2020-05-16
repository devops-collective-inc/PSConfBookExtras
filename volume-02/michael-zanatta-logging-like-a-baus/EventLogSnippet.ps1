#
# PSCore Users Please Note!
#

# Please Note: If you are running PSCore, you will need to install the
# Windows Compatibility Module, by running: 

Install-Module WindowsCompatibility -Scope CurrentUser -AllowClobber
Import-Module WindowsCompatibility
Import-WinModule Microsoft.PowerShell.Management

# However note that this creates a Remote PowerShell session to PS 5.1
# so ensure that Windows Remoting is Enabled by running.
Enable-PSRemoting -Force
# or
winrm qc

#
# Interfacing with the Event Log
#

#
# Writing to the Event Log

# Source: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/write-eventlog?view=powershell-5.1

# Example 1: Write an event to the Application event log
Write-EventLog -LogName "Application" -Source "MyApp" -EventID 3001 -EntryType Information -Message "MyApp added a user-requested feature to the display." -Category 1 -RawData 10,20

# Example 2: Write an event to the Application event log of a remote computer
Write-EventLog -ComputerName "Server01" -LogName Application -Source "MyApp" -EventID 3001 -Message "MyApp added a user-requested feature to the display."

#
# Create a Custom Event Log

# Source: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-eventlog?view=powershell-5.1

# This command creates the TestLog event log on the local computer and registers a new source for it.
New-EventLog -source TestApp -LogName TestLog -MessageResourceFile C:\Test\TestApp.dll

# This command adds a new event source, NewTestApp, to the Application log on the Server01 remote computer.
$file = "C:\Program Files\TestApps\NewTestApp.dll"
New-EventLog -ComputerName Server01 -Source NewTestApp -LogName Application -MessageResourceFile $file -CategoryResourceFile $file

#
# Create a Custom Event Log Source

New-EventLog -LogName Application -Source 'Intune Bitlocker Encryption Script' -ErrorAction SilentlyContinue
