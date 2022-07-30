#Use the Azure Resource Manager Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.15.1"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {
  }
}

#Create a new Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "DemoTFResourceGroup"
  location = "AustraliaEast"
}

#Create a new Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "azcrtfdemo1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

#Create an App Service plan with Linux
resource "azurerm_service_plan" "ASP-DemoTFResourceGroup" {
  name                = "${azurerm_resource_group.rg.name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  #Choose SKU size
  os_type  = "Linux"
  sku_name = "F1"
}

#Create an Azure Web App for Container in the above App Service Plan
resource "azurerm_linux_web_app" "serviandockerapp" {
  name                = "${azurerm_resource_group.rg.name}-serviandockerapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.ASP-DemoTFResourceGroup.id

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = false
    "DOCKER_REGISTRY_SERVER_URL"          = "https://azcrtfdemo1.azurecr.io"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = "azcrtfdemo1"
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = "null"

  }

  # Configure Docker Image to load on start
  site_config {
    #set to false as using a free tier
    always_on = "false"    

    application_stack {
      docker_image     = "azcrtfdemo1.azurecr.io/servianapp"
      docker_image_tag = "latest"
    }

  }

  identity {
    type = "SystemAssigned"
  }
}
