using '../main.bicep'

param environment = 'dev'
param githubOrg = 'hemantshelar'
param githubRepo = 'ai-mcp-server-demo'

param apiImage = 'gcr.io/google-samples/hello-app:1.0'
param mcpImage = 'gcr.io/google-samples/hello-app:1.0'
