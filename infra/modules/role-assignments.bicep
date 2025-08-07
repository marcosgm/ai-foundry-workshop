// Role assignments module
@description('Principal ID of the user to assign roles to')
param userPrincipalId string

@description('AI Project name')
param aiProjectName string

// Reference to the AI Project
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-10-01' existing = {
  name: aiProjectName
}

// Azure AI Developer role definition ID
var aiDeveloperRoleId = '64702f94-c441-49e6-a78b-ef80e0188fee' // Azure AI Developer

// Assign Azure AI Developer role to the user on the AI Project
resource aiDeveloperRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiProject.id, userPrincipalId, aiDeveloperRoleId)
  scope: aiProject
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', aiDeveloperRoleId)
    principalId: userPrincipalId
    principalType: 'User'
  }
}

// Cognitive Services User role for AI services access
var cognitiveServicesUserRoleId = 'a97b65f3-24c7-4388-baec-2e87135dc908' // Cognitive Services User

resource cognitiveServicesUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, userPrincipalId, cognitiveServicesUserRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesUserRoleId)
    principalId: userPrincipalId
    principalType: 'User'
  }
}

// Search Index Data Contributor role for AI Search access
var searchIndexDataContributorRoleId = '8ebe5a00-799e-43f5-93ac-243d3dce84a7' // Search Index Data Contributor

resource searchIndexDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, userPrincipalId, searchIndexDataContributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchIndexDataContributorRoleId)
    principalId: userPrincipalId
    principalType: 'User'
  }
}

// Search Service Contributor role for AI Search management
var searchServiceContributorRoleId = '7ca78c08-252a-4471-8644-bb5ff32d4ba0' // Search Service Contributor

resource searchServiceContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, userPrincipalId, searchServiceContributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchServiceContributorRoleId)
    principalId: userPrincipalId
    principalType: 'User'
  }
}

// Outputs
output roleAssignments object = {
  aiDeveloper: aiDeveloperRoleAssignment.name
  cognitiveServicesUser: cognitiveServicesUserRoleAssignment.name
  searchIndexDataContributor: searchIndexDataContributorRoleAssignment.name
  searchServiceContributor: searchServiceContributorRoleAssignment.name
}
