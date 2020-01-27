import-module hyper-v

$NewVMParam = @{

  ComputerName = "ss-mobile-4"
  Name = 'test'
  Generation = 2
  MemoryStartUpBytes = 8GB
  Path = "F:\VMs"
  SwitchName =  "Nexus-Trunk-VL51Nat"
  NewVHDPath =  "F:\VMs\Virtual Hard Disks\text.vhdx"
  NewVHDSizeBytes =  200GB 
  ErrorAction =  'Stop'
  Verbose =  $True

  }

$VM = New-VM @NewVMParam

$SetVMParam = @{

  ProcessorCount =  4
  DynamicMemory =  $True
  MemoryMinimumBytes =  512MB
  MemoryMaximumBytes =  8Gb
  ErrorAction =  'Stop'
  PassThru =  $True
  Verbose =  $True

  }

$VM = $VM | Set-VM @SetVMParam

$VMDVDParam = @{

  VMName =  $VM.Name
  Path = 'F:\ISOs\CentOS-8-x86_64-1905-boot.iso'
  ErrorAction =  'Stop'
  Verbose =  $True

  }

Set-VMDvdDrive @VMDVDParam

$SetVMNICParam = @{

   

}

  # need to fix storage