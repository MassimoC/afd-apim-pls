@description('Required. The name of the API Management service instance')
param name string

@description('Optional. The email address of the owner of the service')
@minLength(1)
param publisherEmail string='massimo.crippa@codit.eu'

@description('Optional. The name of the owner of the service')
@minLength(1)
param publisherName string = 'hello-apim'

@description('Optional. The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('Optional. The instance size of this API Management service.')
@allowed([
  1
  2
])
param skuCount int = 1

@description('Optional. The type of VPN in which API Management service needs to be configured in. None is the default Value.')
@allowed([
  'None'
  'External'
  'Internal'
])
param virtualNetworkType string = 'None'

@description('Optional. The full resource ID of a subnet in a virtual network to deploy the API Management service in.')
param subnetResourceId string = ''

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Set "Disabled" to disable the public access .')
param publicNetworkStatus string = ''

var isPublicNetworkDisabled = (publicNetworkStatus != '')


resource apim 'Microsoft.ApiManagement/service@2022-04-01-preview' = {
  name: name
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    publicNetworkAccess: isPublicNetworkDisabled ? 'Disabled' : null
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: !empty(subnetResourceId) ? json('{"subnetResourceId": "${subnetResourceId}"}') : null
  }
}

output resourceId string = apim.id
output hostname string = apim.properties.hostnameConfigurations[0].hostName
