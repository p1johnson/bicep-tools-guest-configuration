targetScope = 'resourceGroup'

@description('Location for resources.')
param location string = resourceGroup().location
@description('Name of virtual machine.')
param virtualMachineName string = 'guestconfig'
@description('Size for virtual machine.')
param virtualMachineSize string = 'Standard_D2s_v3'
@secure()
@minLength(1)
@maxLength(20)
@description('Virtual machine administrator user name. Minimum length 1, maximum length 20')
param adminUsername string
@secure()
@minLength(12)
@maxLength(123)
@description('Virtual machine administrator password. Minimum length 12, maximum length 123')
param adminPassword string
@description('Publisher of virtual machine image.')
param imagePublisher string = 'MicrosoftWindowsServer'
@description('Offer for virtual machine image.')
param imageOffer string = 'WindowsServer'
@description('SKU of virtual machine image.')
param imageSku string = '2019-Datacenter'
@description('Version of virtual machine image.')
param imageVersion string = 'latest'
@description('Name of operating system managed disk.')
param osDiskName string = 'mdk-guestconfig-os'
@description('Storage type of managed disk.')
param osDiskType string = 'StandardSSD_LRS'
@description('Name of network interface.')
param networkInterfaceName string = 'nic-guestconfig'
@description('Name of virtual network.')
param virtualNetworkName string = 'vnet-guestconfig'
@description('Array of adddresses for virtual network.')
param virtualNetworkAddresses array = [
  '10.0.0.0/16'
]
@description('Array of DNS server addresses for virtual network. Leave blank to use Azure default.')
param virtualNetworkDnsServers array = []
@description('Name of virtual network subnet.')
param subnetName string = 'snet-guestconfig'
@description('Address for virtual network subnet.')
param subnetAddress string = '10.0.0.0/24'
@description('Array of URLs of script files to download to virtual machine.')
param scriptExtensionFileUris array = [
  'https://raw.githubusercontent.com/p1johnson/bicep-tools-guest-configuration/main/scripts/Configure.ps1'
  'https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi'
]
@description('Command to execute by script extension')
param scriptExtensionCommandToExecute string = 'powershell Configure.ps1'

param scriptExtensionTimestamp string = '${utcNow()}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: virtualNetworkAddresses
    }
    dhcpOptions: {
      dnsServers: virtualNetworkDnsServers
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddress
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${virtualNetwork.id}/subnets/${subnetName}'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {}
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: imageVersion
      }
      osDisk: {
        createOption: 'FromImage'
        name: osDiskName
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
    }
  }
}

resource scriptExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'configure'
  location: location
  parent: virtualMachine
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      timestamp: scriptExtensionTimestamp
    }
    protectedSettings: {
      commandToExecute: scriptExtensionCommandToExecute
      fileUris: scriptExtensionFileUris
    }
  }
}
