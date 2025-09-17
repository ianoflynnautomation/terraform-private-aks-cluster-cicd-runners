
terraform {
  required_version = ">= 1.9.0, < 2.0.0"
  backend "azurerm" {
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.6.1"
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

