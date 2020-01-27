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

$TestResults = Invoke-Testimo -Configuration $TestimoConfig -ShowReport:$true -ReturnResults -ShowErrors
$TestResults | Format-Table -AutoSize *
