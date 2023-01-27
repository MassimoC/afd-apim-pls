@description('Required. Frontdoor endpoint name')
param name string

@description('The host name that should be used when connecting to the origin.')
param originHostName string

@description('The path that should be used when connecting to the origin.')
param originPath string = ''


@description('The name of the SKU to use when creating the Front Door profile. If you use Private Link this must be set to `Premium_AzureFrontDoor`.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param skuName string

@description('Optiona. The protocol to be used when connecting from Front Door to the origin.')
@allowed([
  'HttpOnly'
  'HttpsOnly'
  'MatchRequest'
])
param originForwardingProtocol string = 'HttpsOnly'

@description('resource ID of the resource to be access via private link.')
param privateEndpointResourceId string = ''

@description('Private Link resource type.')
param privateLinkResourceType string = ''

@description('location of the Private Link resource.')
param privateEndpointLocation string = ''

var isPrivateLinkOrigin = (privateEndpointResourceId != '')
var privateLinkOriginDetails = {
  privateLink: {
    id: privateEndpointResourceId
  }
  groupId: (privateLinkResourceType != '') ? privateLinkResourceType : null
  privateLinkLocation: privateEndpointLocation
  requestMessage: 'Please approve the PrivateLink connection.'
}

var originGroupName = 'afd-apim-backends'
var originName = 'afd-api-management'
var routeName = 'afd-route-to-apim'

resource profile 'Microsoft.Cdn/profiles@2020-09-01' = {
  name: name
  location: 'global'
  sku: {
    name: skuName
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2020-09-01' = {
  name: name
  parent: profile
  location: 'global'
  properties: {
    originResponseTimeoutSeconds: 240
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2020-09-01' = {
  name: originGroupName
  parent: profile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/status-0123456789abcdef'
      probeRequestType: 'GET'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 30
    }
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2020-09-01' = {
  name: originName
  parent: originGroup
  properties: {
    hostName: originHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostName
    priority: 1
    weight: 1000
    sharedPrivateLinkResource: isPrivateLinkOrigin ? privateLinkOriginDetails : null
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2020-09-01' = {
  name: routeName
  parent: endpoint
  dependsOn: [
    origin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: originGroup.id
    }
    originPath: originPath != '' ? originPath : null
    supportedProtocols: [
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    compressionSettings: {
      contentTypesToCompress: [
        'image/svg+xml'
        'text/css'
        'text/csv'
        'text/html'
        'text/javascript'
        'text/plain'
        'text/richtext'
        'text/tab-separated-values'
        'text/xml'
      ]
      isCompressionEnabled: true
    }
    queryStringCachingBehavior: 'IgnoreQueryString'
    forwardingProtocol: originForwardingProtocol
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output frontDoorEndpointHostName string = endpoint.properties.hostName
output frontDoorId string = profile.properties.frontdoorId
