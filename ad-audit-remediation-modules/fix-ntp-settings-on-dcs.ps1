# fix time sync settings



$testpdc = Get-ADDomainController
if($testpdc.OperationMasterRoles -contains 'PDCEmulator'){
    w32tm.exe /unregister
    Start-Sleep -Seconds 30
    w32tm.exe /register
    Start-Sleep -Seconds 30
    Start-Service W32Time
    Start-Sleep -Seconds 5
    w32tm.exe /config /manualpeerlist:”0.us.pool.ntp.org 1.us.pool.ntp.org 2.us.pool.ntp.org 3.us.pool.ntp.org” /syncfromflags:ALL /reliable:YES /update
    Set-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config' -Name 'AnnounceFlags' -Value '0x00000005'
    Set-Itemproperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider' -Name 'Enabled' -value '0' 
    Restart-Service W32Time
    Start-Sleep -Seconds 5
    w32tm.exe /resync /rediscover
} else {
    w32tm.exe /unregister
    Start-Sleep -Seconds 30
    w32tm.exe /register
    Start-Sleep -Seconds 30
    Start-Service W32Time
    Start-Sleep -Seconds 5
    w32tm /config /syncfromflags:domhier /update
    Set-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config' -Name 'AnnounceFlags' -Value '0x0000000a'
    Set-Itemproperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider' -Name 'Enabled' -value '0' 
    Restart-Service W32Time
    Start-Sleep -Seconds 5
    w32tm.exe /resync /rediscover
}

#
