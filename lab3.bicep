
param location string = resourceGroup().location
param deploymentSuffix int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))
var customerCode = 'labz'


var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', 'vnet-${customerCode}', 'apim')

module apim 'modules/apim.bicep' = {
  name: '${customerCode}-${deploymentSuffix}-apim'
  params: {
    name: 'apim-${customerCode}'
    location:location
    publicNetworkStatus: 'Disabled'
    virtualNetworkType: 'External'
    subnetResourceId: subnetRef
  }
}
