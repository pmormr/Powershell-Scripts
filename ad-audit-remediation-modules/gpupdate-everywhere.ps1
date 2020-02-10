
$dcs = Get-WinADDomainControllers

foreach ($dc in $dcs){
    Invoke-Command -ComputerName $dc.Hostname -ScriptBlock {
        gpupdate /force
    }
}

