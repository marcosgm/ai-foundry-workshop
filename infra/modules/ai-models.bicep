// AI Models deployment module for AI Foundry Project
@description('AI Project name')
param aiProjectName string

@description('Cognitive Services account name for connection')
param cognitiveServicesName string

@description('Resource token for unique naming')
param resourceToken string

@description('Location for deployments')
param location string

// Reference to the AI Project (ML Workspace)
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-10-01' existing = {
  name: aiProjectName
}

// Reference to the Cognitive Services account for connection
resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: cognitiveServicesName
}

// Create a connection from AI Project to OpenAI
resource openAIConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-10-01' = {
  name: 'openai-connection-${resourceToken}'
  parent: aiProject
  properties: {
    category: 'AzureOpenAI'
    target: cognitiveServicesAccount.properties.endpoint
    authType: 'ApiKey'
    credentials: {
      key: cognitiveServicesAccount.listKeys().key1
    }
    metadata: {
      ApiType: 'Azure'
      ApiVersion: '2024-10-01'
      Location: location
    }
  }
}

// Create serverless endpoints for models in AI Project
// Note: Model deployments in AI Foundry are typically done through the portal or REST API
// For Bicep, we can create the connection and document the models to deploy manually

var modelsToDocument = [
  {
    name: 'gpt-4o'
    deploymentName: 'gpt-4o-${resourceToken}'
    description: 'GPT-4o model for chat completion'
  }
  {
    name: 'gpt-4o-mini'
    deploymentName: 'gpt-4o-mini-${resourceToken}'
    description: 'GPT-4o-mini model for chat completion'
  }
  {
    name: 'text-embedding-3-small'
    deploymentName: 'text-embedding-3-small-${resourceToken}'
    description: 'Text embedding model for vector search'
  }
  {
    name: 'text-embedding-ada-002'
    deploymentName: 'text-embedding-ada-002-${resourceToken}'
    description: 'Ada embedding model for vector search'
  }
]

// AI Models deployment module for AI Foundry Project
@description('AI Project name')
param aiProjectName string

@description('Cognitive Services account name for connection')
param cognitiveServicesName string

@description('Resource token for unique naming')
param resourceToken string

@description('Location for deployments')
param location string

// Reference to the AI Project (ML Workspace)
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-10-01' existing = {
  name: aiProjectName
}

// Reference to the Cognitive Services account for connection
resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: cognitiveServicesName
}

// Create a connection from AI Project to OpenAI
resource openAIConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-10-01' = {
  name: 'openai-connection-${resourceToken}'
  parent: aiProject
  properties: {
    category: 'AzureOpenAI'
    target: cognitiveServicesAccount.properties.endpoint
    authType: 'ApiKey'
    credentials: {
      key: cognitiveServicesAccount.listKeys().key1
    }
    metadata: {
      ApiType: 'Azure'
      ApiVersion: '2024-10-01'
      Location: location
    }
  }
}

// Outputs - connection name and suggested deployment names
output openAIConnectionName string = openAIConnection.name
output cognitiveServicesEndpoint string = cognitiveServicesAccount.properties.endpoint
output suggestedModelDeployments object = {
  'gpt-4o': 'gpt-4o-${resourceToken}'
  'gpt-4o-mini': 'gpt-4o-mini-${resourceToken}'
  'text-embedding-3-small': 'text-embedding-3-small-${resourceToken}'
  'text-embedding-ada-002': 'text-embedding-ada-002-${resourceToken}'
}

// Note: Model deployments in AI Foundry should be done through:
// 1. Azure AI Foundry portal (ai.azure.com)
// 2. Azure AI SDK
// 3. REST API calls
// 
// The models will be deployed as serverless endpoints within the AI Project
// using the OpenAI connection created above
