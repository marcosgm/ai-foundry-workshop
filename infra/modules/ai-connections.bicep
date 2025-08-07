// AI Connections module
@description('AI Project name')
param aiProjectName string

@description('AI Search service name')
param aiSearchServiceName string

@description('Enable Bing Search connection')
param enableBingSearch bool

@description('Resource token for unique naming')
param resourceToken string

@description('Location for the connections')
param location string

// Reference to the AI Project
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-10-01' existing = {
  name: aiProjectName
}

// Reference to the AI Search service
resource aiSearchService 'Microsoft.Search/searchServices@2023-11-01' existing = {
  name: aiSearchServiceName
}

// Azure AI Search Connection
resource aiSearchConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-10-01' = {
  name: 'aisearch-connection-${resourceToken}'
  parent: aiProject
  properties: {
    category: 'CognitiveSearch'
    target: 'https://${aiSearchService.name}.search.windows.net'
    authType: 'ApiKey'
    credentials: {
      key: aiSearchService.listAdminKeys().primaryKey
    }
    metadata: {
      ApiType: 'Azure'
      ApiVersion: '2023-11-01'
      Location: location
    }
  }
}

// Bing Search Connection (conditional)
resource bingSearchConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-10-01' = if (enableBingSearch) {
  name: 'bing-connection-${resourceToken}'
  parent: aiProject
  properties: {
    category: 'BingLLMSearch'
    target: 'https://api.bing.microsoft.com/v7.0/search'
    authType: 'ApiKey'
    credentials: {
      key: 'YOUR_BING_SEARCH_API_KEY' // This needs to be manually configured after deployment
    }
    metadata: {
      ApiType: 'Bing'
      ApiVersion: 'v7.0'
      Location: location
    }
  }
}

// Outputs
output connectionNames object = {
  aiSearchConnection: aiSearchConnection.name
  bingSearchConnection: enableBingSearch ? bingSearchConnection.name : ''
}
