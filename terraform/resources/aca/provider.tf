terraform {
  required_providers {
    dockerless = {
      source  = "nullstone-io/dockerless"
      version = "~> 0.1.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
    }
  }
}

provider "dockerless" {
  registry_auth = {
    "${var.acr_url}" = {
      username = var.acr_username
      password = var.acr_password
    }
  }
}

provider "azuread" {

}