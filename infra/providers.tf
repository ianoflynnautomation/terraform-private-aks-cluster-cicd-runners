
terraform {
  required_version = ">= 1.9.0, < 2.0.0"
  backend "azurerm" {
  }
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "2.0.0-preview3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.42.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.6.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
provider "azapi" {
}

provider "random" {
}

provider "azurecaf" {
}