/* Creates rg-ai-mcp-server-demo-{env} and deploys Phase 1 (UAMI + FIC + RBAC) into it. */
targetScope = 'subscription'

@description('Azure region for the resource group and managed identity.')
param location string = 'australiaeast'

@allowed(['dev', 'prod'])
param environment string

@minLength(1)
param githubOrg string

@minLength(1)
param githubRepo string

var rgName = 'rg-ai-mcp-server-demo-${environment}'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
}

module phase1 'main.bicep' = {
  name: 'phase1-${environment}'
  scope: rg
  params: {
    location: location
    environment: environment
    githubOrg: githubOrg
    githubRepo: githubRepo
  }
}

output resourceGroupName string = rg.name
output clientId string = phase1.outputs.clientId
output principalId string = phase1.outputs.principalId
output managedIdentityName string = phase1.outputs.managedIdentityName
