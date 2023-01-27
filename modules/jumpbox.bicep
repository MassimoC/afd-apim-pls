
@description('Required. Name of jumpbox VM.')
param name string

@description('Required. SubnetId')
param subnetId string

@description('Optional. VM user')
param adminUser string = 'massimoc'

@description('Optional. VM Password')
@secure()
param adminPassword string = '12Hol@..34'

@description('Optional. VM init command')
param cloudInit string = '''
#cloud-config

packages:
 - build-essential
 - procps
 - file
 - linuxbrew-wrapper
 - docker.io

runcmd:
 - curl -sL https://aka.ms/InstallAzureCLIDeb | bash
 - az aks install-cli
 - systemctl start docker
 - systemctl enable docker
 
final_message: "cloud init was here"

'''

param location string = resourceGroup().location

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${name}-nic'
  location: location
  properties:{
    ipConfigurations:[
      {
        name: 'ipConfig'
        properties:{
          subnet:{
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}


resource jumpbox 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: name
  location: location
  properties: {
    hardwareProfile:{
      vmSize: 'Standard_B1ms'
    }
    storageProfile:{
      imageReference:{
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk:{
        createOption: 'FromImage'
        managedDisk:{
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    osProfile: {
      computerName: name
      adminUsername: adminUser
      adminPassword: adminPassword
      linuxConfiguration:{
        disablePasswordAuthentication: false
      }
      customData: base64(cloudInit)
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: nic.id
          properties:{
            primary: true
          }
        }
      ]
    }
  }
}
