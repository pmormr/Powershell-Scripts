# fix replication frequency to 15 minutes for any that aren't 15

Get-ADReplicationSiteLink -Filter "ReplicationFrequencyInMinutes -ne 15" -Properties ReplicationFrequencyInMinutes | ForEach-Object {Set-ADReplicationSiteLink $_ -ReplicationFrequencyInMinutes 15}

# Turn on notifications for the site links

Get-ADReplicationsitelink -filter "*" | ForEach-Object {Set-ADReplicationSiteLink $_ -Add @{options=1}}

# Turn on notifications for the replication connections

$connections = Get-ADReplicationConnection -filter * 
foreach($connection in $connections){
    Set-ADReplicationConnection $connection -Replace @{options=9}
}
