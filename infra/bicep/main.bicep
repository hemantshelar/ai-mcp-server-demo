/* Phase 1: GitHub OIDC UAMI. Phase 2: ACR + Container Apps (Api + McpServer). */
targetScope = 'resourceGroup'

@description('Region for resources; default matches resource group location.')
param location string = resourceGroup().location

@minLength(3)
@description('Environment: dev | prod')
@allowed(['dev', 'prod'])
param environment string

@minLength(1)
param githubOrg string

@minLength(1)
param githubRepo string

@description('Full image reference for Api container (ACR or public registry).')
param apiImage string

@description('Full image reference for McpServer container.')
param mcpImage string

// Must stay in sync with modules/acr.bicep (used for RBAC resource refs evaluable at deploy start).
var acrRegistrySuffix = take(replace(guid(resourceGroup().id, environment), '-', ''), 11)
var acrRegistryName = toLower('acrmcp${environment}${acrRegistrySuffix}')

module githubOidc 'modules/managed-identity-github.bicep' = {
  name: 'githubOidc'
  params: {
    location: location
    environment: environment
    githubOrg: githubOrg
    githubRepo: githubRepo
  }
}

module acr 'modules/acr.bicep' = {
  name: 'acr'
  params: {
    location: location
    environment: environment
  }
}

var acrPushRoleDefinitionId = '8313e01d-4867-4548-9f17-63e7d96a1134'

resource acrForRbac 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrRegistryName
}

resource acrPushForGithubActions 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId, resourceGroup().id, acrRegistryName, acrPushRoleDefinitionId, 'github-actions-acrpush')
  scope: acrForRbac
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPushRoleDefinitionId)
    principalId: githubOidc.outputs.principalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    acr
  ]
}

module containerApps 'modules/container-apps.bicep' = {
  name: 'containerApps'
  params: {
    location: location
    environment: environment
    acrId: acr.outputs.acrId
    apiImage: apiImage
    mcpImage: mcpImage
  }
  dependsOn: [
    acrPushForGithubActions
  ]
}

output clientId string = githubOidc.outputs.clientId
output principalId string = githubOidc.outputs.principalId
output managedIdentityName string = githubOidc.outputs.managedIdentityName

output acrLoginServer string = acr.outputs.loginServer
output acrName string = acr.outputs.acrName
output apiFqdn string = containerApps.outputs.apiFqdn
output mcpFqdn string = containerApps.outputs.mcpFqdn
output pullIdentityId string = containerApps.outputs.pullIdentityId

