terraform {
  backend "azurerm" {
    resource_group_name  = "shanice-new-ecrv"
    storage_account_name = "shanicestorageaccount"
    container_name       = "ce-tfstate"
    key                  = "test/terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"
    }
  }
  required_version = "~> 1.7.4"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}