/* Azure Container Registry only (no RBAC here — role assignments live in main.bicep for clearer failures). */
targetScope = 'resourceGroup'

param location string

@description('Environment segment for naming.')
param environment string

// Must stay in sync with acrRegistryName in ../main.bicep.
var registryName = toLower('acrmcp${environment}${take(uniqueString(resourceGroup().id, environment), 11)}')

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: registryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

@description('Login server hostname for docker login / image references.')
output loginServer string = acr.properties.loginServer

output acrId string = acr.id
output acrName string = acr.name

