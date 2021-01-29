#requires -Version 1 -Modules ActiveDirectory

Get-ADObject -Filter * -SearchBase 'OU=Computer-OU,DC=company,DC=org' | where-object {$_.ObjectClass -like "organizationalUnit"} |
ForEach-Object -Process {
    Set-ADObject -ProtectedFromAccidentalDeletion $true -Identity $_ 
}



$DaysInactive = 732

$time = (Get-Date).Adddays(-($DaysInactive))

Get-ADComputer -searchbase "CN=Computers,DC=company,DC=org" -Filter {LastLogonTimeStamp -lt $time} -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem, SamAccountName, DistinguishedName | remove-adcomputer