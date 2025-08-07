# Azure AI Foundry Setup Deployment Script (PowerShell)
# This script deploys the Azure AI Foundry infrastructure using Bicep

param(
    [string]$EnvironmentName = "ai-foundry-dev",
    [string]$Location = "canadacentral",
    [string]$ResourceGroupName = "",
    [switch]$NoBing,
    [string]$SearchServiceSku = "basic",
    [string]$SemanticSearch = "free",
    [switch]$Help
)

# Colors for output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

if ($Help) {
    Write-Host "Usage: .\deploy.ps1 [OPTIONS]"
    Write-Host "Options:"
    Write-Host "  -EnvironmentName NAME    Environment name (default: ai-foundry-dev)"
    Write-Host "  -Location LOCATION       Azure region (default: eastus)"
    Write-Host "  -ResourceGroupName NAME  Resource group name (optional)"
    Write-Host "  -NoBing                  Disable Bing Search connection"
    Write-Host "  -SearchServiceSku SKU    AI Search service SKU (default: basic)"
    Write-Host "  -Help                    Show this help message"
    exit 0
}

$EnableBingSearch = -not $NoBing

Write-Status "Starting Azure AI Foundry deployment..."
Write-Status "Environment: $EnvironmentName"
Write-Status "Location: $Location"
Write-Status "Bing Search: $EnableBingSearch"
Write-Status "Search SKU: $SearchServiceSku"

# Check if Azure CLI is installed
try {
    az --version | Out-Null
} catch {
    Write-Error "Azure CLI is not installed. Please install it first."
    exit 1
}

# Check if user is logged in
try {
    az account show | Out-Null
} catch {
    Write-Error "You are not logged in to Azure. Please run 'az login' first."
    exit 1
}

# Get current user information
$CurrentUser = az ad signed-in-user show --query id -o tsv
$TenantId = az account show --query tenantId -o tsv

if (-not $CurrentUser) {
    Write-Error "Could not get current user principal ID"
    exit 1
}

Write-Status "Current user principal ID: $CurrentUser"
Write-Status "Tenant ID: $TenantId"

# Deploy the Bicep template
Write-Status "Deploying Azure AI Foundry infrastructure..."

$DeploymentName = "ai-foundry-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')"

$result = az deployment sub create `
    --name $DeploymentName `
    --location $Location `
    --template-file "azure-ai-foundry-setup.bicep" `
    --parameters `
        environmentName=$EnvironmentName `
        location=$Location `
        resourceGroupName=$ResourceGroupName `
        userPrincipalId=$CurrentUser `
        tenantId=$TenantId `
        enableBingSearch=$EnableBingSearch `
        searchServiceSku=$SearchServiceSku `
        semanticSearch=$SemanticSearch

if ($LASTEXITCODE -eq 0) {
    Write-Success "Deployment completed successfully!"
    
    # Get deployment outputs
    Write-Status "Retrieving deployment outputs..."
    
    $Outputs = az deployment sub show --name $DeploymentName --query properties.outputs -o json | ConvertFrom-Json
    
    if ($Outputs) {
        Write-Success "Deployment Outputs:"
        $Outputs | ConvertTo-Json -Depth 10 | Write-Host
        
        # Extract important values
        $AIProjectName = $Outputs.AI_PROJECT_NAME.value
        $AIProjectConnectionString = $Outputs.AI_PROJECT_CONNECTION_STRING.value
        $ResourceGroup = $Outputs.AZURE_RESOURCE_GROUP.value
        
        if ($AIProjectName -and $ResourceGroup) {
            Write-Success "Key Information:"
            Write-Host "  - Resource Group: $ResourceGroup"
            Write-Host "  - AI Project Name: $AIProjectName"
            Write-Host "  - Project Connection String: $AIProjectConnectionString"
        }
    }
    
    Write-Warning "Post-deployment steps:"
    Write-Host "1. If you enabled Bing Search, manually configure the Bing Search API key in the connection"
    Write-Host "2. Update your .env file with the deployment outputs"
    Write-Host "3. Test the connections in Azure AI Foundry portal"
    
} else {
    Write-Error "Deployment failed. Check the error messages above."
    exit 1
}
