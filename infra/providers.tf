
terraform {
  required_version = ">= 1.9.0, < 2.0.0"
  backend "azurerm" {
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.50.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.7"
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

provider "helm" {
}
provider "cloudinit" {
}
