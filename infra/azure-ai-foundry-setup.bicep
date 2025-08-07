targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string = 'eastus'

@description('Resource group name. If empty, a new one will be created.')
param resourceGroupName string = ''

@description('Principal ID of the user who will be assigned the Azure AI Developer role')
param userPrincipalId string

@description('Tenant ID for the subscription')
param tenantId string = tenant().tenantId

@description('Enable Bing Search connection (requires additional setup)')
param enableBingSearch bool = true

@description('SKU for the AI Search service')
@allowed([
  'free'
  'basic'
  'standard'
  'standard2'
  'standard3'
  'storage_optimized_l1'
  'storage_optimized_l2'
])
param searchServiceSku string = 'basic'

@description('Enable semantic search for AI Search')
@allowed([
  'disabled'
  'free'
  'standard'
])
param semanticSearch string = 'free'

// Variables
var abbrs = {
  resourcesResourceGroups: 'rg'
  machineLearningServicesWorkspaces: 'mlw'
  cognitiveServicesAccounts: 'cog'
  searchSearchServices: 'srch'
  keyVaultVaults: 'kv'
  storageStorageAccounts: 'st'
  insightsComponents: 'appi'
}

var tags = {
  'azd-env-name': environmentName
  project: 'ai-foundry-workshop'
}

var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}-${environmentName}-${resourceToken}'
  location: location
  tags: tags
}

// Deploy core AI infrastructure
module aiFoundryInfra 'modules/ai-foundry-core.bicep' = {
  name: 'ai-foundry-infrastructure'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
    tags: tags
    abbrs: abbrs
    tenantId: tenantId
    searchServiceSku: searchServiceSku
    semanticSearch: semanticSearch
  }
}

// Deploy AI models
module aiModels 'modules/ai-models.bicep' = {
  name: 'ai-models-deployment'
  scope: rg
  params: {
    cognitiveServicesName: aiFoundryInfra.outputs.cognitiveServicesName
    resourceToken: resourceToken
  }
}

// Deploy connections (Bing Search and AI Search)
module connections 'modules/ai-connections.bicep' = {
  name: 'ai-connections'
  scope: rg
  params: {
    aiProjectName: aiFoundryInfra.outputs.aiProjectName
    aiSearchServiceName: aiFoundryInfra.outputs.aiSearchServiceName
    enableBingSearch: enableBingSearch
    resourceToken: resourceToken
    location: location
  }
}

// Assign Azure AI Developer role to the user
module roleAssignments 'modules/role-assignments.bicep' = {
  name: 'role-assignments'
  scope: rg
  params: {
    userPrincipalId: userPrincipalId
    aiProjectName: aiFoundryInfra.outputs.aiProjectName
  }
}

// Outputs
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenantId
output AZURE_RESOURCE_GROUP string = rg.name
output AI_HUB_NAME string = aiFoundryInfra.outputs.aiHubName
output AI_PROJECT_NAME string = aiFoundryInfra.outputs.aiProjectName
output AI_PROJECT_CONNECTION_STRING string = aiFoundryInfra.outputs.aiProjectConnectionString
output AI_SEARCH_SERVICE_NAME string = aiFoundryInfra.outputs.aiSearchServiceName
output AI_SEARCH_ENDPOINT string = aiFoundryInfra.outputs.aiSearchEndpoint
output COGNITIVE_SERVICES_ENDPOINT string = aiFoundryInfra.outputs.cognitiveServicesEndpoint
output STORAGE_ACCOUNT_NAME string = aiFoundryInfra.outputs.storageAccountName
output KEY_VAULT_NAME string = aiFoundryInfra.outputs.keyVaultName
output APPLICATION_INSIGHTS_NAME string = aiFoundryInfra.outputs.applicationInsightsName
output MODEL_DEPLOYMENT_NAMES object = aiModels.outputs.modelDeploymentNames
output CONNECTION_NAMES object = connections.outputs.connectionNames
