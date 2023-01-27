@description('Required. Name of the VNET')
param name string

@description('Optional. VNET prefix')
param vnetPrefix string = '10.0.0.0/8'

@description('Optional. Resource location')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01'= {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    subnets:[
      {
        name: 'pls'
        properties: {
          addressPrefix: '10.0.1.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }    
      }
      {
        name: 'apim'
        properties: {
          addressPrefix: '10.0.2.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }    
      }
      {
        name: 'data'
        properties: {
          addressPrefix: '10.0.3.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }    
      }
      {
        name: 'AzureBastionSubnet'
        properties:{
          addressPrefix: '10.0.4.0/24'
        }
      }
    ]
  }
  
}

output pls_subnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', name, 'pls')
output apim_subnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', name, 'apim')
output data_subnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', name, 'data')
output bastion_subnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', name, 'AzureBastionSubnet')
output vnetId string = vnet.id
output name string = vnet.name
