# Scenario

Simple lab to secure the APIM origin with Private Link in Front Door Premium

**Outcomes** : 
- Origin support for direct private endpoint connectivity is currently limited to Storage (Blob), App Services, ILB.
- When you connect AFT to the private endpoint of APIM the health probe do not work anymore.

**Resources** : 
- https://learn.microsoft.com/en-us/azure/frontdoor/private-link
- https://learn.microsoft.com/en-us/azure/api-management/private-endpoint

# Deployment

Overview of the Azure resources deployed

![](imgs/resources.jpg)

## LAB1

In the LAB1 we do not link AFD origin to the APIM private link

```
az account set --subscription c1537527-abcd-abcd-abcd-abcdabcdabcd

az deployment  group create --resource-group codit-afd-apim-pep --template-file lab1.bicep
```

The private endpoint is configured for APIM

![](imgs/apim-pep-net.jpg)

Get the gateway IP over the private link

![](imgs/apim-pep-nslookup.jpg)

The AFD probe is working as expected and we can reach APIM via AFD.

```
# probe endpoint
curl -v https://apim-labz.azure-api.net/status-0123456789abcdef

# apim public endpoint
curl -v "https://apim-labz.azure-api.net/echo/resource?param1=sample&subscription-key=e3a02410591b45988bf4089fa1f23bc7"

# afd public endpoint
curl -v "https://afd-labz.z01.azurefd.net/echo/resource?param1=sample&subscription-key=e3a02410591b45988bf4089fa1f23bc7"

```


## LAB2

With the LAB2 we connect AFD to the private endpoint of APIM

![](imgs/lab2.jpg)

As result the AFD probe is not healthy anymore.

![](imgs/lab2-activated.jpg)

Note that Azure Portal do not allow to enable the private link for API Management.

![](imgs/privatelink-notavailable.jpg)

Get the origin details via REST API : https://learn.microsoft.com/en-us/rest/api/frontdoor/azurefrontdoorstandardpremium/afd-origins/get

![](imgs/restapi-origins-get.jpg)