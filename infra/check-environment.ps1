# Azure AI Foundry Workshop - Environment Info Script (PowerShell)
# This script helps gather information needed for the workshop

function Write-Header {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                Azure AI Foundry Workshop                      ║" -ForegroundColor Cyan
    Write-Host "║                   Environment Information                      ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Section {
    param([string]$Title)
    Write-Host "▶ $Title" -ForegroundColor Blue
    Write-Host "─────────────────────────────────────────────────────────────────"
}

function Write-Info {
    param([string]$Label, [string]$Value)
    Write-Host "$Label" -ForegroundColor Green -NoNewline
    Write-Host ": $Value"
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ WARNING: $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ ERROR: $Message" -ForegroundColor Red
}

# Check prerequisites
function Test-Prerequisites {
    Write-Section "Prerequisites Check"
    
    $allGood = $true
    
    # Check Azure CLI
    try {
        $azVersion = (az --version | Select-String "azure-cli").ToString().Split()[1]
        Write-Info "Azure CLI" "✓ Installed (version $azVersion)"
    } catch {
        Write-Error "Azure CLI not found. Please install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        $allGood = $false
    }
    
    # Check login status
    try {
        $accountName = az account show --query name -o tsv
        Write-Info "Azure Login" "✓ Logged in to: $accountName"
    } catch {
        Write-Error "Not logged in to Azure. Run: az login"
        $allGood = $false
    }
    
    # Check PowerShell version
    $psVersion = $PSVersionTable.PSVersion.ToString()
    Write-Info "PowerShell" "✓ Version $psVersion"
    
    # Check Python
    try {
        $pythonVersion = python --version 2>$null
        if ($pythonVersion) {
            Write-Info "Python" "✓ $pythonVersion"
        } else {
            Write-Warning "Python not found. Required for the workshop."
        }
    } catch {
        Write-Warning "Python not found. Required for the workshop."
    }
    
    Write-Host ""
    return $allGood
}

# Get Azure account information
function Get-AzureInfo {
    Write-Section "Azure Account Information"
    
    $subscriptionId = az account show --query id -o tsv
    $subscriptionName = az account show --query name -o tsv
    $tenantId = az account show --query tenantId -o tsv
    
    try {
        $userId = az ad signed-in-user show --query id -o tsv 2>$null
        $userName = az ad signed-in-user show --query userPrincipalName -o tsv 2>$null
    } catch {
        $userId = "Not available"
        $userName = "Not available"
    }
    
    Write-Info "Subscription ID" $subscriptionId
    Write-Info "Subscription Name" $subscriptionName
    Write-Info "Tenant ID" $tenantId
    Write-Info "User Principal ID" $userId
    Write-Info "User Name" $userName
    
    Write-Host ""
}

# Get deployment information
function Get-DeploymentInfo {
    Write-Section "Recent AI Foundry Deployments"
    
    try {
        $deployments = az deployment sub list --query "[?contains(name, 'ai-foundry')].{name:name, state:properties.provisioningState, timestamp:properties.timestamp}" -o table 2>$null
        
        if ($deployments) {
            Write-Host $deployments
        } else {
            Write-Warning "No AI Foundry deployments found in this subscription"
        }
    } catch {
        Write-Warning "Could not retrieve deployment information"
    }
    
    Write-Host ""
}

# Generate .env file template
function New-EnvTemplate {
    Write-Section "Environment File Template"
    
    $subscriptionId = az account show --query id -o tsv
    $tenantId = az account show --query tenantId -o tsv
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $envContent = @"
# Azure AI Foundry Workshop Environment Variables
# Generated on $timestamp

# Azure Configuration
AZURE_SUBSCRIPTION_ID=$subscriptionId
AZURE_TENANT_ID=$tenantId
AZURE_RESOURCE_GROUP=<UPDATE_AFTER_DEPLOYMENT>

# AI Project Configuration
PROJECT_CONNECTION_STRING=<UPDATE_AFTER_DEPLOYMENT>
AI_PROJECT_NAME=<UPDATE_AFTER_DEPLOYMENT>

# Model Deployments (update these with your actual deployment names)
MODEL_DEPLOYMENT_NAME=<UPDATE_AFTER_DEPLOYMENT>
EMBEDDING_MODEL_DEPLOYMENT_NAME=<UPDATE_AFTER_DEPLOYMENT>
SERVERLESS_MODEL_NAME=<UPDATE_AFTER_DEPLOYMENT>

# Service Endpoints
AI_SEARCH_ENDPOINT=<UPDATE_AFTER_DEPLOYMENT>
COGNITIVE_SERVICES_ENDPOINT=<UPDATE_AFTER_DEPLOYMENT>

# Connection Names
BING_CONNECTION_NAME=<UPDATE_AFTER_DEPLOYMENT>
AI_SEARCH_CONNECTION_NAME=<UPDATE_AFTER_DEPLOYMENT>

# Storage and Security
STORAGE_ACCOUNT_NAME=<UPDATE_AFTER_DEPLOYMENT>
KEY_VAULT_NAME=<UPDATE_AFTER_DEPLOYMENT>
APPLICATION_INSIGHTS_NAME=<UPDATE_AFTER_DEPLOYMENT>
"@
    
    $envContent | Out-File -FilePath ".env.generated" -Encoding UTF8
    
    Write-Info "Template created" ".env.generated"
    Write-Warning "Update the placeholders after running the deployment script"
    
    Write-Host ""
}

# Show next steps
function Show-NextSteps {
    Write-Section "Next Steps"
    
    Write-Host "1. 📋 Review the information above"
    Write-Host "2. 🚀 Deploy infrastructure:"
    Write-Host "   .\deploy.ps1 -EnvironmentName `"my-ai-workshop`""
    Write-Host "3. 📝 Update .env file with deployment outputs"
    Write-Host "4. 🧪 Test the setup by running the introduction notebooks"
    Write-Host "5. 📚 Follow the workshop guide in ..\README.md"
    
    Write-Host ""
    Write-Section "Quick Deploy Command"
    $envName = "ai-foundry-$(Get-Date -Format 'yyyyMMdd')"
    Write-Host ".\deploy.ps1 -EnvironmentName `"$envName`" -Location `"eastus`"" -ForegroundColor Cyan
    Write-Host ""
}

# Main execution
Write-Header

if (Test-Prerequisites) {
    Get-AzureInfo
    Get-DeploymentInfo
    New-EnvTemplate
    Show-NextSteps
} else {
    Write-Error "Prerequisites check failed. Please address the issues above."
    exit 1
}
