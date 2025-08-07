// AI Models deployment module
@description('Cognitive Services account name')
param cognitiveServicesName string

@description('Resource token for unique naming')
param resourceToken string

// Model deployment configurations
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

// Reference to the Cognitive Services account
resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: cognitiveServicesName
}

// Deploy models
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
output modelDeploymentNames object = {
  'gpt-4o': models[0].deploymentName
  'gpt-4o-mini': models[1].deploymentName
  'text-embedding-3-small': models[2].deploymentName
  'text-embedding-ada-002': models[3].deploymentName
}
