# 🚀 Azure AI Foundry Workshop - Infrastructure Automation

I've created a comprehensive Bicep script and deployment automation to handle all the Azure AI Foundry setup requirements you specified. Here's what I've built for you:

## 📁 Files Created

### 🏗️ Core Infrastructure
- **`azure-ai-foundry-setup.bicep`** - Main Bicep template (subscription-scoped)
- **`azure-ai-foundry-setup.parameters.json`** - Parameters template
- **`.env.template`** - Environment variables template

### 🧩 Modular Components (`modules/` directory)
- **`ai-foundry-core.bicep`** - Core infrastructure (Hub, Project, Storage, etc.)
- **`ai-models.bicep`** - AI model deployments (GPT-4o, embeddings)
- **`ai-connections.bicep`** - Service connections (AI Search, Bing)
- **`role-assignments.bicep`** - RBAC role assignments

### 🤖 Deployment Scripts
- **`deploy.sh`** - Bash deployment script (Linux/macOS)
- **`deploy.ps1`** - PowerShell deployment script (Windows)
- **`check-environment.sh`** - Environment check script (Bash)
- **`check-environment.ps1`** - Environment check script (PowerShell)

### 📚 Documentation
- **`README.md`** - Comprehensive deployment guide

## 🎯 What This Automates

### ✅ Infrastructure Deployment
- ✅ AI Hub and Project creation
- ✅ Storage Account, Key Vault, Application Insights
- ✅ Cognitive Services (OpenAI) account
- ✅ Azure AI Search service with semantic search

### ✅ Model Deployments
- ✅ **GPT-4o** (TPM set to max: 150k)
- ✅ **GPT-4o-mini** (TPM set to max: 150k)
- ✅ **text-embedding-3-small** (120k TPM)
- ✅ **text-embedding-ada-002** (120k TPM)
- ✅ All models deployed in `Global-Standard` or `DataZone-Standard`

### ✅ Service Connections
- ✅ Azure AI Search connection (automated)
- ✅ Bing Search connection (requires manual API key configuration)

### ✅ Role Assignments
- ✅ **Azure AI Developer** role on the AI Project
- ✅ **Cognitive Services User** role for model access
- ✅ **Search Index Data Contributor** for AI Search
- ✅ **Search Service Contributor** for search management

## 🚀 Quick Start

### Option 1: Automated Deployment (Recommended)

**Windows Users:**
```powershell
cd infra
.\check-environment.ps1  # Check prerequisites
.\deploy.ps1 -EnvironmentName "my-ai-workshop"
```

**Linux/macOS Users:**
```bash
cd infra
chmod +x *.sh
./check-environment.sh  # Check prerequisites
./deploy.sh --environment "my-ai-workshop"
```

### Option 2: Manual Deployment

```bash
az deployment sub create \
  --name "ai-foundry-deployment" \
  --location "eastus" \
  --template-file "azure-ai-foundry-setup.bicep" \
  --parameters \
    environmentName="my-workshop" \
    userPrincipalId="$(az ad signed-in-user show --query id -o tsv)" \
    tenantId="$(az account show --query tenantId -o tsv)"
```

## ⚙️ Customization Options

The deployment supports various configurations:

```bash
# Example with custom settings
./deploy.sh \
  --environment "production-ai" \
  --location "westeurope" \
  --search-sku "standard" \
  --no-bing  # Skip Bing Search connection
```

## 📋 Post-Deployment Steps

1. **Update Environment Variables:**
   - Copy deployment outputs to your `.env` file
   - Use the generated `.env.template` as a starting point

2. **Configure Bing Search (if enabled):**
   - Get a Bing Search API key from Azure portal
   - Update the connection in Azure AI Foundry

3. **Verify Setup:**
   - Visit [Azure AI Foundry](https://ai.azure.com)
   - Confirm your project and models are available
   - Test the connections

## 🎯 Key Features

### 🔐 Security Best Practices
- RBAC-based access control
- Secure credential storage in Key Vault
- Managed identities for service authentication

### 📈 Production Ready
- Proper resource naming with unique tokens
- Comprehensive monitoring with Application Insights
- Scalable architecture with modular design

### 🛠️ Developer Friendly
- One-command deployment
- Comprehensive error handling
- Detailed logging and output

### 💰 Cost Optimized
- Default to cost-effective SKUs
- Optional components (e.g., Bing Search)
- Configurable capacity settings

## 🔧 Advanced Configuration

### Custom Model Deployments
Modify `modules/ai-models.bicep` to add or change models:

```bicep
{
  name: 'gpt-4-turbo'
  deploymentName: 'gpt-4-turbo-${resourceToken}'
  version: '2024-04-09'
  sku: {
    name: 'Standard'
    capacity: 100
  }
}
```

### Additional Connections
Extend `modules/ai-connections.bicep` for more integrations:

```bicep
// Custom API connection example
resource customApiConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-10-01' = {
  name: 'custom-api-connection'
  parent: aiProject
  properties: {
    category: 'CustomKeys'
    target: 'https://api.example.com'
    authType: 'ApiKey'
    credentials: {
      key: 'your-api-key'
    }
  }
}
```

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure AI Foundry Hub                    │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   AI Project    │    │ Cognitive Svcs  │                │
│  │                 │    │   (OpenAI)      │                │
│  │ ┌─────────────┐ │    │                 │                │
│  │ │   Models    │ │    │ • GPT-4o        │                │
│  │ │             │ │    │ • GPT-4o-mini   │                │
│  │ │ • Chat      │ │    │ • Embeddings    │                │
│  │ │ • Embedding │ │    │                 │                │
│  │ └─────────────┘ │    └─────────────────┘                │
│  └─────────────────┘                                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   AI Search     │    │   Connections   │                │
│  │                 │    │                 │                │
│  │ • Vector Search │    │ • Bing Search   │                │
│  │ • Semantic      │    │ • AI Search     │                │
│  │ • Full Text     │    │                 │                │
│  └─────────────────┘    └─────────────────┘                │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │    Storage      │    │   Monitoring    │                │
│  │                 │    │                 │                │
│  │ • Blob Storage  │    │ • App Insights  │                │
│  │ • Key Vault     │    │ • Metrics       │                │
│  │                 │    │ • Logs          │                │
│  └─────────────────┘    └─────────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

## 🎉 Success!

You now have a complete, production-ready Azure AI Foundry infrastructure that automatically handles:

- ✅ **Resource Creation**: All required Azure resources
- ✅ **Model Deployment**: GPT and embedding models with max TPM
- ✅ **Service Integration**: AI Search and optional Bing Search
- ✅ **Security Setup**: Proper RBAC and access controls
- ✅ **Workshop Ready**: Everything needed for the AI Foundry workshop

The infrastructure is designed to be:
- **Scalable**: Easy to modify and extend
- **Secure**: Following Azure security best practices  
- **Cost-effective**: Optimized default configurations
- **Maintainable**: Modular and well-documented

Ready to deploy your Azure AI Foundry workshop environment! 🚀
