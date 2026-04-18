using '../subscription.bicep'

param environment = 'prod'
param githubOrg = 'YOUR_GITHUB_ORG'
param githubRepo = 'YOUR_REPO_NAME'

param apiImage = 'gcr.io/google-samples/hello-app:1.0'
param mcpImage = 'gcr.io/google-samples/hello-app:1.0'
