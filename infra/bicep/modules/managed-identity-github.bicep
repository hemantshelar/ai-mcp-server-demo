/* Phase 1: user-assigned MI + GitHub Actions OIDC federated credential + Contributor on this resource group. */
targetScope = 'resourceGroup'

@description('Azure region for the managed identity (use australiaeast per plan).')
param location string

@description('Environment segment: dev | prod — used in resource names and FIC subject.')
@allowed(['dev', 'prod'])
param environment string

@description('GitHub organization or user name (subject: repo:org/repo:environment:env).')
param githubOrg string

@description('GitHub repository name (subject: repo:org/repo:environment:env).')
param githubRepo string

var managedIdentityName = 'MI_ai-mcp-server-demo-${environment}'
var federatedCredentialName = 'github-actions-${environment}'
var contributorRoleDefinitionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

resource federatedCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: managedIdentity
  name: federatedCredentialName
  properties: {
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:${githubOrg}/${githubRepo}:environment:${environment}'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

resource contributorOnResourceGroup 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, managedIdentityName, contributorRoleDefinitionId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

@description('Use as GitHub Environment variable AZURE_CLIENT_ID for this stack.')
output clientId string = managedIdentity.properties.clientId

@description('Object (principal) id of the managed identity.')
output principalId string = managedIdentity.properties.principalId

output managedIdentityId string = managedIdentity.id
output managedIdentityName string = managedIdentity.name
