
param location string = resourceGroup().location
param deploymentSuffix int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))
var customerCode = 'labz'

module law 'modules/law.bicep' = {
  name: '${customerCode}-${deploymentSuffix}-law'
  params:{
    name: 'law-${customerCode}'
    location:location
  }
}

module vnet 'modules/network.bicep' = {
  name: '${customerCode}-${deploymentSuffix}-vnet'
  params: {
    name: 'vnet-${customerCode}'
    location:location
  }
}

module bastion 'modules/bastion.bicep' = {
  name: '${customerCode}-${deploymentSuffix}-bastion'
  params: {
    name: 'bastion-${customerCode}'
    location: location
    subnetId: vnet.outputs.bastion_subnetId
  }
}

module jumpbox 'modules/jumpbox.bicep' = {
  name: '${customerCode}-${deploymentSuffix}-jumpbox'
  params: {
    name: 'jumpbox-${customerCode}'
    location:location
    subnetId: vnet.outputs.data_subnetId
  }
}

module apim 'modules/apim.bicep' = {
  name: '${customerCode}-${deploymentSuffix}-apim'
  params: {
    name: 'apim-${customerCode}'
    location:location
    publicNetworkStatus: 'Disabled'
  }
}

module privateendpoint 'modules/endpoint.bicep' = {
  name: '${customerCode}-${deploymentSuffix}-pep'
  params:{
    name: 'pep-${customerCode}'
    apimResourceId: apim.outputs.resourceId
    vnetName: vnet.outputs.name
    location:location
    privateEndpointSubnetId:vnet.outputs.pls_subnetId
  }
}

module afd 'modules/afd.bicep' = {
  name: '${customerCode}-${deploymentSuffix}-afd'
  params: {
    name: 'afd-${customerCode}'
    originHostName: apim.outputs.hostname
    skuName: 'Premium_AzureFrontDoor'
    privateEndpointResourceId: apim.outputs.resourceId
    privateLinkResourceType: 'Gateway'
    privateEndpointLocation: 'westeurope'
  }
}
