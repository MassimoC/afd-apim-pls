
@description('Required. Name of the Bastion host.')
param name string

@description('Required. Bastion subnet Id.')
param subnetId string

param location string = resourceGroup().location

resource bastionpip 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${name}-pip'
  location: location
  properties:{
    publicIPAllocationMethod: 'Static'
  }
  sku:{
    name: 'Standard'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: name
  location: location
  properties: {
   ipConfigurations: [
     {
        name: 'ipconfig1'
        properties:{
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: bastionpip.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }      
     }
   ] 
  }
}
