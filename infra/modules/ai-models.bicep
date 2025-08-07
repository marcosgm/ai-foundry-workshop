// AI Models deployment module for AI Foundry Project
@description('AI Project name')
param aiProjectName string

@description('Cognitive Services account name for connection')
param cognitiveServicesName string

@description('Resource token for unique naming')
param resourceToken string

@description('Location for deployments')
param location string

// Model deployment configurations for AI Foundry Project
var models = [
  {
    name: 'gpt-4o'
    deploymentName: 'gpt-4o-${resourceToken}'
    version: '2024-08-06'
    sku: {
      name: 'GlobalStandard'
      capacity: 150 // Set to max TPM to avoid issues with Agents notebooks
    }
  }
  {
    name: 'gpt-4o-mini'
    deploymentName: 'gpt-4o-mini-${resourceToken}'
    version: '2024-07-18'
    sku: {
      name: 'GlobalStandard'
      capacity: 150 // Set to max TPM to avoid issues with Agents notebooks
    }
  }
  {
    name: 'text-embedding-3-small'
    deploymentName: 'text-embedding-3-small-${resourceToken}'
    version: '1'
    sku: {
      name: 'Standard'
      capacity: 120
    }
  }
  {
    name: 'text-embedding-ada-002'
    deploymentName: 'text-embedding-ada-002-${resourceToken}'
    version: '2'
    sku: {
      name: 'Standard'
      capacity: 120
    }
  }
]

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

// Deploy models to Cognitive Services (they will be accessible through the AI Project via the connection)
@batchSize(1)
resource modelDeployments 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = [for model in models: {
  name: model.deploymentName
  parent: cognitiveServicesAccount
  properties: {
    model: {
      format: 'OpenAI'
      name: model.name
      version: model.version
    }
    raiPolicyName: null
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
  }
  sku: model.sku
}]

// Outputs
output openAIConnectionName string = openAIConnection.name
output cognitiveServicesEndpoint string = cognitiveServicesAccount.properties.endpoint
output modelDeploymentNames object = {
  'gpt-4o': models[0].deploymentName
  'gpt-4o-mini': models[1].deploymentName
  'text-embedding-3-small': models[2].deploymentName
  'text-embedding-ada-002': models[3].deploymentName
}

// Note: Models are deployed to the underlying Cognitive Services account
// but accessible through the AI Project via the OpenAI connection
// This allows the AI Foundry project to use the models seamlessly
