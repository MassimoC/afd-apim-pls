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

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

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
  }
}

output resourceId string = apim.id
output hostname string = apim.properties.hostnameConfigurations[0].hostName
