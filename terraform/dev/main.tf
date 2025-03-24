locals {
  team     = "skylight" //Update this to match your chosen prefix
  project  = "dibbs"
  env      = "dev"
  location = "eastus" //Update this to match your chosen region
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

  dibbs_version = "3.0.0-beta"

  azure_storage_connection_string = module.foundations.azure_storage_connection_string
  azure_container_name            = module.foundations.azure_container_name

  nbs_public_key = <<EOT
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqjrH9PprQCB5dX15zYfd
S6K2ezNi/ZOu8vKEhQuLqwHACy1iUt1Yyp2PZLIV7FVDgBHMMVWPVx3GJ2wEyaJw
MHkv6XNpUpWLhbs0V1T7o/OZfEIqcNua07OEoBxX9vhKIHtaksWdoMyKRXQJz0js
oWpawfOWxETnLqGvybT4yvY2RJhquTXLcLu90L4LdvIkADIZshaOtAU/OwI5ATcb
fE3ip15E6jIoUm7FAtfRiuncpI5l/LJPP6fvwf8QCbbUJBZklLqcUuf4qe/L/nIq
pIONb8KZFWPhnGeRZ9bwIcqYWt3LAAshQLSGEYl2PGXaqbkUD2XLETSKDjisxd0g
9j8bIMPgBKi+dBYcmBZnR7DxJe+vEDDw8prHG/+HRy5fim/BcibTKnIl8PR5yqHa
mWQo7N+xXhILdD9e33KLRgbg97+erHqvHlNMdwDhAfrBT+W6GCdPwp3cePPsbhsc
oGSHOUDhzyAujr0J8h5WmZDGUNWjGzWqubNZD8dBXB8x+9dDoWhfM82nw0pvAeKf
wJodvn3Qo8/S5hxJ6HyGkUTANKN8IxWh/6R5biET5BuztZP6jfPEaOAnt6sq+C38
hR9rUr59dP2BTlcJ19ZXobLwuJEa81S5BrcbDwYNOAzC8jl2EV1i4bQIwJJaY27X
Iynom6unaheZpS4DFIh2w9UCAwEAAQ==
-----END PUBLIC KEY-----
          EOT

  nextauth_url = "https://<YOUR_GATEWAY_DOMAIN_HERE>/ecr_viewer/api/auth"

  key_vault_id = "<YOUR_KEY_VAULT_ID_HERE>" //Update this to match your target key vault.

  ecr_viewer_db_fqdn = "<YOUR_DATABASE_FQDN_HERE>" //Update this to match your target database server.

  use_ssl = true //Set this to false if you do not want to use SSL for the ACA gateway.

  user_assigned_identity_id = "" //Set to the ID of a user-assigned managed identity if you want to use one. If your Service Principal has Entra write access, you can leave this blank.
}