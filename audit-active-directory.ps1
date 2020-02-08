# fix replication frequency to 15 minutes for any that aren't 15

# Get-ADReplicationSiteLink -Filter "ReplicationFrequencyInMinutes -ne 15" -Properties ReplicationFrequencyInMinutes | % {Set-ADReplicationSiteLink $_ -ReplicationFrequencyInMinutes 15}

# fix replication topology notification enablement

# get-adreplicationsitelink -filter "*" | % {Set-ADReplicationSiteLink $_ -Add @{options=1}}

# fix default users and computers containers

# redircmp "OU=Computers-Workstations,DC=lab,DC=pmormr,DC=com"
# redirusr "OU=Users-Admin,DC=lab,DC=pmormr,DC=com"

# enable ad recycle bin

# Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target "lab.pmormr.com"

# disable source routing -- run on the box in admin mode

# set-netipv4protocol -SourceRoutingBehavior "Drop"
# set-netipv4protocol -IcmpRedirects 0

# disable netbios over tcp/ip for all adapters -- run on host

# $regkey = "HKLM:SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces"
# Get-ChildItem $regkey |foreach { Set-ItemProperty -Path "$regkey\$($_.pschildname)" -Name NetbiosOptions -Value 2 -Verbose}

# Reconfigure SMB fun -- run on the host

# Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol
# Set-SmbServerConfiguration -EnableSMB1Protocol $false
# Set-SmbServerConfiguration -EnableSMB2Protocol $true
# Set-smbserverconfiguration -AsynchronousCredits 64 -confirm:$false
# Set-smbserverconfiguration -MaxThreadsPerQueue 20 -confirm:$false
# Set-smbserverconfiguration -Smb2CreditsMax 2048 -confirm:$false
# Set-smbserverconfiguration -Smb2CreditsMin 128 -confirm:$false
# Set-smbserverconfiguration -DurableHandleV2TimeoutInSeconds 30 -confirm:$false
# Set-smbserverconfiguration -AutoDisconnectTimeout 0 -confirm:$false
# Set-smbserverconfiguration -CachedOpenLimit 5 -confirm:$false

# disable 8.3 filenames
# REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisable8dot3NameCreation" /T REG_DWORD /D "1" /f

# set srv.sys to start on demand
# REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer" /v "DependOnService" /T REG_MULTI_SZ /D "SamSS\Srv2" /f

# enable client failback for SYSVOL and Netlogon
# REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dfs\Parameters" /v "SysvolNetlogonTargetFailback" /T REG_DWORD /D "1" /f

# enable LSA protection -- https://docs.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/configuring-additional-lsa-protection
# REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v "RunAsPPL" /T REG_DWORD /D "1" /f

#



# run audit

Import-Module Testimo

$TestimoConfig = Get-TestimoConfiguration
$TestimoConfig.Forest.Backup.Tests.LastBackupTests.Enable = $false
$TestimoConfig.Forest.OptionalFeatures.Tests.PrivAccessManagement.Enable = $false
$TestimoConfig.Forest.OptionalFeatures.Tests.LapsAvailable.Enable = $false
$TestimoConfig.Forest.SiteLinks.Tests.MinimalReplicationFrequency.Parameters.ExpectedValue = 15
$TestimoConfig.Forest.SiteLinks.Tests.MinimalReplicationFrequency.Parameters.OperationType = "eq"
$TestimoConfig.Forest.SiteLinks.Tests.UseNotificationsForLinks.Enable = $true
$TestimoConfig.Domain.PasswordComplexity.Tests.LockoutThreshold.Parameters.ExpectedValue = 25
$TestimoConfig.Domain.PasswordComplexity.Tests.LockoutThreshold.Parameters.OperationType = "eq"
$TestimoConfig.Domain.PasswordComplexity.Tests.MaxPasswordAge.Parameters.ExpectedValue = 366
$TestimoConfig.Domain.PasswordComplexity.Tests.MinPasswordLength.Parameters.ExpectedValue = 5
$TestimoConfig.DomainControllers.EventLogs.Tests.ApplicationLogMode.Parameters.ExpectedValue = "Circular"
$TestimoConfig.DomainControllers.EventLogs.Tests.PowershellLogMode.Parameters.ExpectedValue = "Circular"
$TestimoConfig.DomainControllers.EventLogs.Tests.SecurityLogMode.Parameters.ExpectedValue = "Circular"
$TestimoConfig.DomainControllers.EventLogs.Tests.SystemLogMode.Parameters.ExpectedValue = "Circular"


# if there's no trusts, disable trust verification
$TestTrust = Get-AdTrust -Filter * -Properties *
if ( $null -eq $TestTrust) {
    $TestimoConfig.Domain.Trusts.Enable = $false
}



$TestResults = Invoke-Testimo -Configuration $TestimoConfig -ReportPath "output/current_report.html" -ReturnResults -ShowErrors
$TestResults | where-object {$_.Status -eq $false } | Format-Table -AutoSize *