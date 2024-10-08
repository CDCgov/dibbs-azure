locals {
  team     = "<insert>" // TODO: Change this to match your implementation team's name or internal asset code.
  project  = "dibbs"
  env      = "dev"    // TODO: Change this to match your desired environment (e.g., dev, test, prod). Make sure to vary this between environments.
  location = "eastus" // TODO: Change this to match your desired Azure region.
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

  aca_subnet_id   = module.networking.subnet_aca_id
  appgw_subnet_id = module.networking.subnet_appgw_id
  vnet_id         = module.networking.network.id

  acr_url      = module.foundations.acr_url
  acr_username = module.foundations.acr_admin_username
  acr_password = module.foundations.acr_admin_password

  dibbs_version = "v1.6.4"

  azure_storage_connection_string = module.foundations.azure_storage_connection_string
  azure_container_name            = module.foundations.azure_container_name
}