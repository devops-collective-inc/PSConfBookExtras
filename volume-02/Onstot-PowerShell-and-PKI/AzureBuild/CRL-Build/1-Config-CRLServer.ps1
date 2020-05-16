Get-DnsClientServerAddress
Get-DnsClientServerAddress | Where-Object {($_.interfaceAlias -like 'Ethernet') -and ($_.ServerAddresses -like '*')} |Set-DnsClientServerAddress -ServerAddresses ("10.0.0.4","10.151.12.242","10.151.12.146","172.22.32.250","10.150.60.100")
Get-DnsClientServerAddress
add-computer -domainname pkilab.local -Passthru -OUPath "OU=T0 Web Servers,OU=T0 Servers,OU=Tier0,DC=PKILab,DC=local"
Pause
Restart-computer