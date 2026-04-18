using '../subscription.bicep'

param environment = 'dev'
param githubOrg = 'hemantshelar'
param githubRepo = 'ai-mcp-server-demo'

// Placeholder: listens on 8080; replace with ${acrLoginServer}/api:tag after push.
param apiImage = 'gcr.io/google-samples/hello-app:1.0'
param mcpImage = 'gcr.io/google-samples/hello-app:1.0'
