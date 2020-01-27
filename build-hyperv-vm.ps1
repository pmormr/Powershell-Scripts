[String]$HypervisorHost = "ss-mobile-4.lab.pmormr.com"
[String]$VMName = 'ELS-I02'
[String]$VMStoragePath = 'F:\VMs'
[String]$VHDStoragePath = 'F:\VMs\Virtual Hard Disks\ELS-I02.vhdx'
[String]$InstallISOPath = 'F:\ISOs\CentOS-8-x86_64-1905-dvd1.iso'
[Switch]$Cluster = $false
[String]$VMSwitchName = 'Nexus-Trunk-VL51Nat'
[Uint64]$StartupMemory = 2GB
[Uint64]$MinimumMemory = 1GB
[Uint64]$MaximumMemory = 8GB
[Uint64]$VHDXSizeBytes = 200GB
[Uint64]$VMProcessorCount = 4
[Uint32]$VLAN = 800

#Configure the VM




Import-Module Hyper-V
$VM = New-VM -ComputerName $HypervisorHost -Name $VMName -MemoryStartupBytes $StartupMemory -SwitchName $VMSwitchName -Path $VMStoragePath -Generation 2 -NoVHD
Set-VMMemory -VM $VM -DynamicMemoryEnabled $true -MinimumBytes $MinimumMemory -MaximumBytes $MaximumMemory
Set-VMProcessor -VM $VM -Count $VMProcessorCount
Start-VM -VM $VM
Stop-VM -VM $VM -Force
New-VHD -ComputerName $HypervisorHost -Path $VHDStoragePath -SizeBytes $VHDXSizeBytes -Dynamic -BlockSizeBytes 1MB
$VMVHD = Add-VMHardDiskDrive -VM $VM -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0 -Path $VHDStoragePath -Passthru
$VMDVDDrive = Add-VMDvdDrive -VM $VM -ControllerNumber 0 -ControllerLocation 1 -Passthru
$VMNetAdapter = Get-VMNetworkAdapter -VM $VM
Set-VMNetworkAdapter -VMNetworkAdapter $VMNetAdapter -StaticMacAddress ($VMNetAdapter.MacAddress)
Set-VMNetworkAdapterVlan -VM $VM -Access -VlanId $VLAN
Set-VMFirmware -VM $VM -BootOrder $VMDVDDrive, $VMVHD, $VMNetAdapter -EnableSecureBoot On -SecureBootTemplate 'MicrosoftUEFICertificateAuthority'
Set-VMDvdDrive  -VMDvdDrive $VMDVDDrive -Path $InstallISOPath
Set-VM -VM $VM -AutomaticStartAction Start -AutomaticStartDelay 300 -AutomaticStopAction ShutDown

if($Cluster)
{
    Add-ClusterVirtualMachineRole -ComputerName $HypervisorHost -VMName $VMName
}



# need to clean up storage
