# fix default users and computers containers

redircmp "OU=Computers-Workstations,DC=lab,DC=pmormr,DC=com"
redirusr "OU=Users-Admin,DC=lab,DC=pmormr,DC=com"

# enable ad recycle bin

Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target "lab.pmormr.com"