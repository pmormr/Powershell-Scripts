# fix time sync settings

$dcs = Get-WinADDomainControllers

foreach ($dc in $dcs){
    Invoke-Command -ComputerName $dc.Hostname -ScriptBlock {
        $testpdc = Get-ADDomainController
        if($testpdc.OperationMasterRoles -contains 'PDCEmulator'){
            
            Write-Host "Working on "$testpdc.Hostname". This is the PDC."
            Write-Host "Unregistering W32Time Service"
            w32tm.exe /unregister
            Start-Sleep -Seconds 5
            taskkill /F /FI "SERVICES EQ W32Time"
            Start-Sleep -Seconds 10
            Write-Host "Registering W32Time Service"
            w32tm.exe /register
            Start-Sleep -Seconds 30
            Write-Host "Starting W32Time Service"
            Start-Service W32Time
            Start-Sleep -Seconds 5
            Write-Host "Configuring manual NTP peer list and special AnounceFlags, because this server is PDC."
            w32tm.exe /config /manualpeerlist:"0.us.pool.ntp.org,0x1 1.us.pool.ntp.org,0x1 2.us.pool.ntp.org,0x1 3.us.pool.ntp.org,0x1" /syncfromflags:ALL /reliable:YES /update
            Set-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config' -Name 'AnnounceFlags' -Value '0x00000005'
            Write-Host "Disabling VMICTimeProvider registry entry."
            Set-Itemproperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider' -Name 'Enabled' -value '0' 
            Write-Host "Restarting W32Time Service"
            Restart-Service W32Time
            Start-Sleep -Seconds 5
            Write-Host "Forcing resync and rediscovery for W32Time"
            w32tm.exe /resync /rediscover
            Write-Host "Process has completed for domain controler "$testpdc.Hostname"."
            Write-Host "Good luck!"
        } else {
            Write-Host "Working on "$testpdc.Hostname". This is NOT the PDC."
            Write-Host "Unregistering W32Time Service"
            w32tm.exe /unregister
            Start-Sleep -Seconds 5
            taskkill /F /FI "SERVICES EQ W32Time"
            Start-Sleep -Seconds 10
            Write-Host "Registering W32Time Service"
            w32tm.exe /register
            Start-Sleep -Seconds 30
            Write-Host "Starting W32Time Service"
            Start-Service W32Time
            Start-Sleep -Seconds 5
            Write-Host "Configuring this server to use the domain heirarchy for time synchronization."
            w32tm /config /syncfromflags:domhier /update
            Set-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config' -Name 'AnnounceFlags' -Value '0x0000000a'
            Write-Host "Disabling VMICTimeProvider registry entry."
            Set-Itemproperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider' -Name 'Enabled' -value '0' 
            Write-Host "Restarting W32Time Service"
            Restart-Service W32Time
            Start-Sleep -Seconds 5
            Write-Host "Forcing resync and rediscovery for W32Time"
            w32tm.exe /resync /rediscover
            Write-Host "Process has completed for domain controler "$testpdc.Hostname"."
            Write-Host "Good luck!"
        }
    }
}


#
