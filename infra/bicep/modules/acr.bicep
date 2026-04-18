/* Azure Container Registry + AcrPush for the GitHub deployment managed identity. */
targetScope = 'resourceGroup'

param location string

@description('Environment segment for naming.')
param environment string

@description('Principal (object) id of MI_ai-mcp-server-demo-{env} — allows CI to push images.')
param githubActionsPrincipalId string

var registryName = toLower('acrmcp${environment}${take(uniqueString(resourceGroup().id, environment), 11)}')
// ACR: lowercase alphanumeric only; uniqueString can emit uppercase.

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

var acrPushRoleDefinitionId = '8313e01d-4867-4548-9f17-63e7d96a1134'

resource acrPushForGithubActions 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, githubActionsPrincipalId, acrPushRoleDefinitionId)
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPushRoleDefinitionId)
    principalId: githubActionsPrincipalId
    principalType: 'ServicePrincipal'
  }
}

@description('Login server hostname for docker login / image references.')
output loginServer string = acr.properties.loginServer

output acrId string = acr.id
output acrName string = acr.name

