


# Run audit

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

Get-EventsInformation -LogName 'Application', 'System', 'Security', 'Microsoft-Windows-PowerShell/Operational' -machine "lab-dc02"