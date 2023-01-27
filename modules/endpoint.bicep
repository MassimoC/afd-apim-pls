// Parameters
@description('Required. Private endpoint name')
param name string

@description('Required. Specifies the name of the virtual network.')
param vnetName string

@description('Required. Specifies the name of the subnet which contains the private endpoint.')
param privateEndpointSubnetId string

@description('Required. Specifies the resource id of the Azure Storage Account.')
param apimResourceId string

@description('Optional. Specifies the location.')
param location string = resourceGroup().location

@description('Optional. Specifies the resource tags.')
param tags object = {}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnetName
}

// Virtual Network Links
resource apimPrivateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azure-api.net'
  location: 'global'

  resource privateDNSZoneNetworkLink 'virtualNetworkLinks@2020-06-01' = {
    name: 'link_to_${toLower(vnetName)}'
    location: 'global'
    properties:{
      registrationEnabled: false
      virtualNetwork:{
        id: vnet.id
      }
    }
  } 
}

// Private Endpoints
resource apimPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          privateLinkServiceId: apimResourceId
          groupIds: [
            'Gateway'
          ]
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnetId
    }
  }
}

// Private DNS Zone Group
resource apimPrivateDnsZoneGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
  parent: apimPrivateEndpoint
  name: 'PrivateDnsZoneGroupName'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: apimPrivateDNSZone.id
        }
      }
    ]
  }
}

output resourceId string = apimPrivateEndpoint.id
