# disable source routing -- run on the box in admin mode

set-netipv4protocol -SourceRoutingBehavior "Drop"
set-netipv4protocol -IcmpRedirects 0

# disable netbios over tcp/ip for all adapters -- run on host

$regkey = "HKLM:SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces"
Get-ChildItem $regkey | ForEach-Object { Set-ItemProperty -Path "$regkey\$($_.pschildname)" -Name NetbiosOptions -Value 2 -Verbose }

# SMB Hardening and best practice, run on the host

Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol
Set-SmbServerConfiguration -EnableSMB1Protocol $false
Set-SmbServerConfiguration -EnableSMB2Protocol $true
Set-smbserverconfiguration -AsynchronousCredits 64 -confirm:$false
Set-smbserverconfiguration -MaxThreadsPerQueue 20 -confirm:$false
Set-smbserverconfiguration -Smb2CreditsMax 2048 -confirm:$false
Set-smbserverconfiguration -Smb2CreditsMin 128 -confirm:$false
Set-smbserverconfiguration -DurableHandleV2TimeoutInSeconds 30 -confirm:$false
Set-smbserverconfiguration -AutoDisconnectTimeout 0 -confirm:$false
Set-smbserverconfiguration -CachedOpenLimit 5 -confirm:$false

# disable 8.3 filenames
REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisable8dot3NameCreation" /T REG_DWORD /D "1" /f

# set srv.sys to start on demand -- need to reverify
REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer" /v "DependOnService" /T REG_MULTI_SZ /D "SamSS\Srv2" /f

# enable client failback for SYSVOL and Netlogon
REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dfs\Parameters" /v "SysvolNetlogonTargetFailback" /T REG_DWORD /D "1" /f

# enable LSA protection -- https://docs.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/configuring-additional-lsa-protection
REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v "RunAsPPL" /T REG_DWORD /D "1" /f