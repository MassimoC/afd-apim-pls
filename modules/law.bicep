// Parameters
@description('Required. Specifies the name of the Log Analytics workspace.')
param name string

@description('Optional. Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB.')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param sku string = 'PerGB2018'

@description('Optional. Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus.')
param retentionInDays int = 60

@description('Optional. Specifies the location.')
param location string = resourceGroup().location

@description('Optional. Specifies the resource tags.')
param tags object = {}


// Resources
resource law 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: name
  tags: tags
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
  }
}


//Outputs
output id string = law.id
output name string = law.name
output customerId string = law.properties.customerId
