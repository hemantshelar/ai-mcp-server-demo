/* Creates rg-ai-mcp-server-demo-{env} and deploys Phase 1 + Phase 2 (UAMI, ACR, Container Apps). */
targetScope = 'subscription'

@description('Azure region for the resource group and resources.')
param location string = 'australiaeast'

@allowed(['dev', 'prod'])
param environment string

@minLength(1)
param githubOrg string

@minLength(1)
param githubRepo string

@description('Full image reference for Api container.')
param apiImage string

@description('Full image reference for McpServer container.')
param mcpImage string

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
    apiImage: apiImage
    mcpImage: mcpImage
  }
}

output resourceGroupName string = rg.name
output clientId string = phase1.outputs.clientId
output principalId string = phase1.outputs.principalId
output managedIdentityName string = phase1.outputs.managedIdentityName
output acrLoginServer string = phase1.outputs.acrLoginServer
output acrName string = phase1.outputs.acrName
output apiFqdn string = phase1.outputs.apiFqdn
output mcpFqdn string = phase1.outputs.mcpFqdn
output pullIdentityId string = phase1.outputs.pullIdentityId
