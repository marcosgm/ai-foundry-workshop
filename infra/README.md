# Azure AI Foundry Infrastructure Deployment

This directory contains Bicep templates and deployment scripts to automatically set up the Azure AI Foundry infrastructure for the workshop.

## 🚀 Quick Start

### Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in
- An Azure subscription with sufficient permissions to create resources
- PowerShell (for Windows) or Bash (for Linux/macOS)

### Option 1: One-Click Deployment (Recommended)

**For Windows (PowerShell):**
```powershell
cd infra
.\deploy.ps1 -EnvironmentName "my-ai-workshop"
```

**For Linux/macOS (Bash):**
```bash
cd infra
chmod +x deploy.sh
./deploy.sh --environment "my-ai-workshop"
```

### Option 2: Manual Deployment

1. **Get your User Principal ID:**
   ```bash
   az ad signed-in-user show --query id -o tsv
   ```

2. **Get your Tenant ID:**
   ```bash
   az account show --query tenantId -o tsv
   ```

3. **Deploy the template:**
   ```bash
   az deployment sub create \
     --name "ai-foundry-deployment" \
     --location "eastus" \
     --template-file "azure-ai-foundry-setup.bicep" \
     --parameters \
       environmentName="my-ai-workshop" \
       userPrincipalId="YOUR_USER_PRINCIPAL_ID" \
       tenantId="YOUR_TENANT_ID"
   ```

## 📋 What Gets Deployed

The Bicep template creates the following resources:

### Core Infrastructure
- **Resource Group**: Container for all resources
- **AI Hub**: Central hub for AI projects and model management
- **AI Project**: Project workspace for development
- **Cognitive Services (OpenAI)**: For GPT and embedding models
- **Azure AI Search**: For vector search and retrieval
- **Storage Account**: For data and model storage
- **Key Vault**: For secure credential storage
- **Application Insights**: For monitoring and telemetry

### AI Models Deployed
- **GPT-4o**: Latest GPT-4 model for chat completion
- **GPT-4o-mini**: Lightweight version for faster responses
- **text-embedding-3-small**: Small embedding model for vector search
- **text-embedding-ada-002**: Alternative embedding model

### Connections Configured
- **Azure AI Search Connection**: For search and retrieval operations
- **Bing Search Connection**: For grounding with web search (optional)

### Role Assignments
- **Azure AI Developer**: Full access to AI resources
- **Cognitive Services User**: Access to AI models
- **Search Index Data Contributor**: Manage search indexes
- **Search Service Contributor**: Manage search service

## ⚙️ Configuration Options

### Deployment Script Parameters

**PowerShell (deploy.ps1):**
```powershell
.\deploy.ps1 `
  -EnvironmentName "my-workshop" `
  -Location "eastus" `
  -ResourceGroupName "my-rg" `
  -NoBing `
  -SearchServiceSku "standard" `
  -SemanticSearch "standard"
```

**Bash (deploy.sh):**
```bash
./deploy.sh \
  --environment "my-workshop" \
  --location "eastus" \
  --resource-group "my-rg" \
  --no-bing \
  --search-sku "standard"
```

### Available Parameters

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `environmentName` | Unique name for your environment | `ai-foundry-dev` | Any valid string |
| `location` | Azure region for deployment | `eastus` | Any Azure region |
| `resourceGroupName` | Resource group name (optional) | Auto-generated | Any valid RG name |
| `enableBingSearch` | Enable Bing search connection | `true` | `true`, `false` |
| `searchServiceSku` | AI Search service tier | `basic` | `free`, `basic`, `standard`, etc. |
| `semanticSearch` | Semantic search capability | `free` | `disabled`, `free`, `standard` |

## 📁 File Structure

```
infra/
├── azure-ai-foundry-setup.bicep           # Main Bicep template
├── azure-ai-foundry-setup.parameters.json # Parameters file (template)
├── deploy.sh                              # Bash deployment script
├── deploy.ps1                             # PowerShell deployment script
├── README.md                              # This file
└── modules/                               # Bicep modules
    ├── ai-foundry-core.bicep              # Core infrastructure
    ├── ai-models.bicep                    # AI model deployments
    ├── ai-connections.bicep               # Service connections
    └── role-assignments.bicep             # RBAC assignments
```

## 🔧 Post-Deployment Steps

After successful deployment:

1. **Configure Bing Search (if enabled):**
   - Get a Bing Search API key from Azure portal
   - Update the Bing Search connection in AI Foundry with the API key

2. **Update Environment Variables:**
   ```bash
   # Copy the deployment outputs to your .env file
   PROJECT_CONNECTION_STRING=<AI_PROJECT_CONNECTION_STRING>
   MODEL_DEPLOYMENT_NAME=<GPT_MODEL_NAME>
   EMBEDDING_MODEL_DEPLOYMENT_NAME=<EMBEDDING_MODEL_NAME>
   # ... other outputs
   ```

3. **Verify Deployment:**
   - Visit [Azure AI Foundry](https://ai.azure.com)
   - Ensure your project appears and models are deployed
   - Test the connections in the AI Foundry portal

## 🛠️ Troubleshooting

### Common Issues

**1. Permission Errors:**
```
Error: You do not have permission to create resources
```
- Ensure you have Contributor role on the subscription
- Contact your Azure administrator

**2. Model Deployment Failures:**
```
Error: Model deployment quota exceeded
```
- Try a different region with available quota
- Use smaller model capacities
- Check [model availability by region](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models#model-summary-table-and-region-availability)

**3. Resource Name Conflicts:**
```
Error: Resource name already exists
```
- Use a different `environmentName` parameter
- The template generates unique names using resource tokens

### Cleanup

To remove all deployed resources:

```bash
# Get the resource group name from deployment outputs
az group delete --name "<RESOURCE_GROUP_NAME>" --yes --no-wait
```

## 🔗 Next Steps

Once deployment is complete:

1. Follow the [Quick Start Guide](../README.md#-quick-start) in the main README
2. Configure your development environment
3. Start with the introduction notebooks in `1-introduction/`

## 📚 Additional Resources

- [Azure AI Foundry Documentation](https://learn.microsoft.com/en-us/azure/ai-studio/)
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/)
- [Workshop Main README](../README.md)
