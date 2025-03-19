locals {
  team     = "skylight"
  project  = "dibbs"
  env      = "dev"
  location = "eastus2"
}

module "foundations" {
  source   = "../resources/foundations"
  team     = local.team
  project  = local.project
  env      = local.env
  location = local.location
}

module "networking" {
  source              = "../resources/networking"
  team                = local.team
  project             = local.project
  env                 = local.env
  location            = local.location
  resource_group_name = module.foundations.resource_group_name

  //These can be configured to match your network requirements.
  //We recommend /24 at minumum for the network address space,
  //and /25 for the ACA subnet. (Allows for 58 individual nodes)
  network_address_space               = ["10.30.0.0/24"]
  aca_subnet_address_prefixes         = ["10.30.0.0/25"]
  app_gateway_subnet_address_prefixes = ["10.30.0.128/26"]
  db_subnet_address_prefixes          = ["10.30.0.192/27"]
}

module "db" {
  source              = "../resources/postgres_database"
  team                = local.team
  project             = local.project
  env                 = local.env
  location            = local.location
  resource_group_name = module.foundations.resource_group_name

  db_vnet_id      = module.networking.network.id
  aca_subnet_id   = module.networking.subnet_aca_id
  appgw_subnet_id = module.networking.subnet_appgw_id
  db_subnet_id    = module.networking.subnet_db_id

  //tags = local.management_tags

  key_vault_id = module.foundations.key_vault_id
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
  acr_username = module.foundations.acr_admin_username //TODO: Change to an ACA-specific password
  acr_password = module.foundations.acr_admin_password //TODO: Change to an ACA-specific password

  dibbs_version           = "v2.0.0-beta"
  query_connector_version = "main"
  dibbs_site_version      = "next-cd205c5"

  ecr_viewer_db_fqdn      = module.db.ecr_viewer_server_fqdn
  ecr_viewer_db_name      = module.db.ecr_viewer_db_name
  query_connector_db_fqdn = module.db.query_connector_server_fqdn
  query_connector_db_name = module.db.query_connector_db_name

  azure_storage_connection_string = module.foundations.azure_storage_connection_string
  azure_container_name            = module.foundations.azure_container_name

  key_vault_id = module.foundations.key_vault_id
}


module "entra" {
  source   = "../resources/entra"
  team     = local.team
  project  = local.project
  env      = local.env
  location = local.location

  ecr_viewer_admin_app_role_id            = module.container_apps.ecr_viewer_admin_app_role_id
  ecr_viewer_privilegedread_app_role_id   = module.container_apps.ecr_viewer_privilegedread_app_role_id
  ecr_viewer_unprivilegedread_app_role_id = module.container_apps.ecr_viewer_unprivilegedread_app_role_id
  ecr_viewer_service_principal_id         = module.container_apps.ecr_viewer_service_principal_id
}