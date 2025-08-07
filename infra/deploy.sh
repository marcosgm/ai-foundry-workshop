#!/bin/bash

# Azure AI Foundry Setup Deployment Script
# This script deploys the Azure AI Foundry infrastructure using Bicep

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default values
ENVIRONMENT_NAME="ai-foundry-dev"
LOCATION="eastus"
RESOURCE_GROUP_NAME=""
ENABLE_BING_SEARCH=true
SEARCH_SERVICE_SKU="basic"
SEMANTIC_SEARCH="free"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT_NAME="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -g|--resource-group)
            RESOURCE_GROUP_NAME="$2"
            shift 2
            ;;
        --no-bing)
            ENABLE_BING_SEARCH=false
            shift
            ;;
        --search-sku)
            SEARCH_SERVICE_SKU="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -e, --environment NAME    Environment name (default: ai-foundry-dev)"
            echo "  -l, --location LOCATION   Azure region (default: eastus)"
            echo "  -g, --resource-group NAME Resource group name (optional)"
            echo "  --no-bing                Disable Bing Search connection"
            echo "  --search-sku SKU          AI Search service SKU (default: basic)"
            echo "  -h, --help                Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option $1"
            exit 1
            ;;
    esac
done

print_status "Starting Azure AI Foundry deployment..."
print_status "Environment: $ENVIRONMENT_NAME"
print_status "Location: $LOCATION"
print_status "Bing Search: $ENABLE_BING_SEARCH"
print_status "Search SKU: $SEARCH_SERVICE_SKU"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    print_error "You are not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Get current user information
CURRENT_USER=$(az ad signed-in-user show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

if [ -z "$CURRENT_USER" ]; then
    print_error "Could not get current user principal ID"
    exit 1
fi

print_status "Current user principal ID: $CURRENT_USER"
print_status "Tenant ID: $TENANT_ID"

# Deploy the Bicep template
print_status "Deploying Azure AI Foundry infrastructure..."

DEPLOYMENT_NAME="ai-foundry-deployment-$(date +%s)"

az deployment sub create \
    --name "$DEPLOYMENT_NAME" \
    --location "$LOCATION" \
    --template-file "azure-ai-foundry-setup.bicep" \
    --parameters \
        environmentName="$ENVIRONMENT_NAME" \
        location="$LOCATION" \
        resourceGroupName="$RESOURCE_GROUP_NAME" \
        userPrincipalId="$CURRENT_USER" \
        tenantId="$TENANT_ID" \
        enableBingSearch="$ENABLE_BING_SEARCH" \
        searchServiceSku="$SEARCH_SERVICE_SKU" \
        semanticSearch="$SEMANTIC_SEARCH"

if [ $? -eq 0 ]; then
    print_success "Deployment completed successfully!"
    
    # Get deployment outputs
    print_status "Retrieving deployment outputs..."
    
    OUTPUTS=$(az deployment sub show --name "$DEPLOYMENT_NAME" --query properties.outputs -o json)
    
    if [ -n "$OUTPUTS" ]; then
        print_success "Deployment Outputs:"
        echo "$OUTPUTS" | jq '.'
        
        # Extract important values
        AI_PROJECT_NAME=$(echo "$OUTPUTS" | jq -r '.AI_PROJECT_NAME.value // empty')
        AI_PROJECT_CONNECTION_STRING=$(echo "$OUTPUTS" | jq -r '.AI_PROJECT_CONNECTION_STRING.value // empty')
        RESOURCE_GROUP=$(echo "$OUTPUTS" | jq -r '.AZURE_RESOURCE_GROUP.value // empty')
        
        if [ -n "$AI_PROJECT_NAME" ] && [ -n "$RESOURCE_GROUP" ]; then
            print_success "Key Information:"
            echo "  - Resource Group: $RESOURCE_GROUP"
            echo "  - AI Project Name: $AI_PROJECT_NAME"
            echo "  - Project Connection String: $AI_PROJECT_CONNECTION_STRING"
        fi
    fi
    
    print_warning "Post-deployment steps:"
    echo "1. If you enabled Bing Search, manually configure the Bing Search API key in the connection"
    echo "2. Update your .env file with the deployment outputs"
    echo "3. Test the connections in Azure AI Foundry portal"
    
else
    print_error "Deployment failed. Check the error messages above."
    exit 1
fi
