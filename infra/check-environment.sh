#!/bin/bash

# Azure AI Foundry Workshop - Environment Info Script
# This script helps gather information needed for the workshop

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                Azure AI Foundry Workshop                      ║${NC}"
    echo -e "${CYAN}║                   Environment Information                      ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_section() {
    echo -e "${BLUE}▶ $1${NC}"
    echo "─────────────────────────────────────────────────────────────────"
}

print_info() {
    echo -e "${GREEN}$1:${NC} $2"
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING:${NC} $1"
}

print_error() {
    echo -e "${RED}✗ ERROR:${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_section "Prerequisites Check"
    
    # Check Azure CLI
    if command -v az &> /dev/null; then
        AZ_VERSION=$(az --version | head -n1 | cut -d' ' -f2)
        print_info "Azure CLI" "✓ Installed (version $AZ_VERSION)"
    else
        print_error "Azure CLI not found. Please install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        return 1
    fi
    
    # Check login status
    if az account show &> /dev/null; then
        ACCOUNT_NAME=$(az account show --query name -o tsv)
        print_info "Azure Login" "✓ Logged in to: $ACCOUNT_NAME"
    else
        print_error "Not logged in to Azure. Run: az login"
        return 1
    fi
    
    # Check Python
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        print_info "Python" "✓ Installed (version $PYTHON_VERSION)"
    else
        print_warning "Python 3 not found. Required for the workshop."
    fi
    
    echo
}

# Get Azure account information
get_azure_info() {
    print_section "Azure Account Information"
    
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
    TENANT_ID=$(az account show --query tenantId -o tsv)
    USER_ID=$(az ad signed-in-user show --query id -o tsv 2>/dev/null || echo "Not available")
    USER_NAME=$(az ad signed-in-user show --query userPrincipalName -o tsv 2>/dev/null || echo "Not available")
    
    print_info "Subscription ID" "$SUBSCRIPTION_ID"
    print_info "Subscription Name" "$SUBSCRIPTION_NAME"
    print_info "Tenant ID" "$TENANT_ID"
    print_info "User Principal ID" "$USER_ID"
    print_info "User Name" "$USER_NAME"
    
    echo
}

# Get deployment information
get_deployment_info() {
    print_section "Recent AI Foundry Deployments"
    
    # Look for recent deployments
    DEPLOYMENTS=$(az deployment sub list --query "[?contains(name, 'ai-foundry')].{name:name, state:properties.provisioningState, timestamp:properties.timestamp}" -o table 2>/dev/null || echo "No deployments found")
    
    if [ "$DEPLOYMENTS" != "No deployments found" ]; then
        echo "$DEPLOYMENTS"
    else
        print_warning "No AI Foundry deployments found in this subscription"
    fi
    
    echo
}

# Generate .env file template
generate_env_template() {
    print_section "Environment File Template"
    
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    TENANT_ID=$(az account show --query tenantId -o tsv)
    
    cat > .env.generated << EOF
# Azure AI Foundry Workshop Environment Variables
# Generated on $(date)

# Azure Configuration
AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
AZURE_TENANT_ID=$TENANT_ID
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
EOF
    
    print_info "Template created" ".env.generated"
    print_warning "Update the placeholders after running the deployment script"
    
    echo
}

# Provide next steps
show_next_steps() {
    print_section "Next Steps"
    
    echo "1. 📋 Review the information above"
    echo "2. 🚀 Deploy infrastructure:"
    echo "   ./deploy.sh --environment \"my-ai-workshop\""
    echo "3. 📝 Update .env file with deployment outputs"
    echo "4. 🧪 Test the setup by running the introduction notebooks"
    echo "5. 📚 Follow the workshop guide in ../README.md"
    
    echo
    print_section "Quick Deploy Command"
    echo -e "${CYAN}./deploy.sh --environment \"ai-foundry-$(date +%Y%m%d)\" --location \"eastus\"${NC}"
    echo
}

# Main execution
print_header

if check_prerequisites; then
    get_azure_info
    get_deployment_info
    generate_env_template
    show_next_steps
else
    print_error "Prerequisites check failed. Please address the issues above."
    exit 1
fi
