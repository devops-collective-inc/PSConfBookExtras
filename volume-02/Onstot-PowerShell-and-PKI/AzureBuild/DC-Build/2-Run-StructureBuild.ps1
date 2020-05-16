Add-WindowsFeature RSAT-ADDS-Tools

.\ADOUStructureBuild.ps1
.\ADGroupBuilds.ps1

#Write-Output "You now need to download and intall LAPS before continuing.  Get it from here:   https://www.microsoft.com/en-us/download/details.aspx?id=46899 (preferably never from a prod Domain Controller)"
#pause

#Start-Process -FilePath "https://www.microsoft.com/en-us/download/details.aspx?id=46899"

#.\ADEnableFeatures.ps1
#.\GPOBuilds.ps1