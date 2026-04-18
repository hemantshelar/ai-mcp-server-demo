using '../main.bicep'

param environment = 'prod'
param githubOrg = 'YOUR_GITHUB_ORG'
param githubRepo = 'YOUR_REPO_NAME'

// Placeholder for first Bicep deploy; deploy-azure.yml can overwrite revisions (see docs/github-actions-setup.md).
param apiImage = 'gcr.io/google-samples/hello-app:1.0'
param mcpImage = 'gcr.io/google-samples/hello-app:1.0'
