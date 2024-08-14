locals {
  team     = "dibbs"
  project  = "ce"
  env      = "dev"
  location = "eastus"
}

module "foundations" {
  source   = "../resources/foundations"
  team     = local.team
  project  = local.project
  env      = local.env
  location = local.location
}

module "networking" {
  source                = "../resources/networking"
  team                  = local.team
  project               = local.project
  env                   = local.env
  location              = local.location
  resource_group_name   = module.foundations.resource_group_name
  network_address_space = "10.30.0.0/16"
}

module "container_apps" {
  source              = "../resources/aca"
  team                = local.team
  project             = local.project
  env                 = local.env
  location            = local.location
  resource_group_name = module.foundations.resource_group_name

  publisher_name  = "" # Add the missing attribute "publisher_name" here
  publisher_email = "" # Add the missing attribute "publisher_email" here

  key_vault_id = module.foundations.key_vault_id

  aca_subnet_id = module.networking.subnet_aca_id
  vnet_name     = module.networking.network.name

  acr_url      = module.foundations.acr_url
  acr_username = module.foundations.acr_admin_username //TODO: Change to an ACA-specific password
  acr_password = module.foundations.acr_admin_password //TODO: Change to an ACA-specific password
}