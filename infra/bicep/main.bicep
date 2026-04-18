/* Deploy Phase 1 GitHub OIDC identity into an existing resource group (create RG with az first). */
targetScope = 'resourceGroup'

@description('Region for the managed identity; default matches resource group location.')
param location string = resourceGroup().location

@minLength(3)
@description('Environment: dev | prod')
@allowed(['dev', 'prod'])
param environment string

@minLength(1)
param githubOrg string

@minLength(1)
param githubRepo string

module githubOidc 'modules/managed-identity-github.bicep' = {
  name: 'githubOidc'
  params: {
    location: location
    environment: environment
    githubOrg: githubOrg
    githubRepo: githubRepo
  }
}

output clientId string = githubOidc.outputs.clientId
output principalId string = githubOidc.outputs.principalId
output managedIdentityName string = githubOidc.outputs.managedIdentityName
