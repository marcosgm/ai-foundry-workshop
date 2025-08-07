// Core AI Foundry infrastructure module
@description('Environment name')
param environmentName string

@description('Location for all resources')
param location string

@description('Resource token for unique naming')
param resourceToken string

@description('Tags to apply to all resources')
param tags object

@description('Abbreviations for resource names')
param abbrs object

@description('Tenant ID')
param tenantId string

@description('AI Search service SKU')
param searchServiceSku string

@description('Semantic search setting')
param semanticSearch string

// Generate unique names
var aiHubName = '${abbrs.machineLearningServicesWorkspaces}-hub-${environmentName}-${resourceToken}'
var aiProjectName = '${abbrs.machineLearningServicesWorkspaces}-proj-${environmentName}-${resourceToken}'
var cognitiveServicesName = '${abbrs.cognitiveServicesAccounts}-${environmentName}-${resourceToken}'
var aiSearchServiceName = '${abbrs.searchSearchServices}-${environmentName}-${resourceToken}'
var keyVaultName = '${abbrs.keyVaultVaults}-${environmentName}-${resourceToken}'
var storageAccountName = '${abbrs.storageStorageAccounts}${resourceToken}'
var applicationInsightsName = '${abbrs.insightsComponents}-${environmentName}-${resourceToken}'

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    networkAcls: {
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
  }
}

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: []
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: false
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: false
  }
}

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

// Cognitive Services (OpenAI)
resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: cognitiveServicesName
  location: location
  tags: tags
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: cognitiveServicesName
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
}

// AI Search Service
resource aiSearchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: aiSearchServiceName
  location: location
  tags: tags
  sku: {
    name: searchServiceSku
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    semanticSearch: semanticSearch
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
  }
}

// AI Hub (ML Workspace)
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: aiHubName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'AI Foundry Hub - ${environmentName}'
    description: 'AI Hub for ${environmentName} environment'
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: applicationInsights.id
    publicNetworkAccess: 'Enabled'
    v1LegacyMode: false
  }
  kind: 'Hub'
}

// AI Project (ML Workspace)
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: aiProjectName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'AI Foundry Project - ${environmentName}'
    description: 'AI Project for ${environmentName} environment'
    hubResourceId: aiHub.id
    publicNetworkAccess: 'Enabled'
    v1LegacyMode: false
  }
  kind: 'Project'
}

// Outputs
output aiHubName string = aiHub.name
output aiProjectName string = aiProject.name
output aiProjectConnectionString string = 'azureml://subscriptions/${subscription().subscriptionId}/resourcegroups/${resourceGroup().name}/providers/Microsoft.MachineLearningServices/workspaces/${aiProject.name}'
output aiSearchServiceName string = aiSearchService.name
output aiSearchEndpoint string = 'https://${aiSearchService.name}.search.windows.net'
output cognitiveServicesName string = cognitiveServices.name
output cognitiveServicesEndpoint string = cognitiveServices.properties.endpoint
output storageAccountName string = storageAccount.name
output keyVaultName string = keyVault.name
output applicationInsightsName string = applicationInsights.name
output cognitiveServicesId string = cognitiveServices.id
