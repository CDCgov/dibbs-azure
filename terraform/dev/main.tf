locals {
  team     = "new" //Update this to match your chosen prefix
  project  = "testecrv"
  env      = "test"
  location = "eastus" //Update this to match your chosen region
}

module "foundations" {
  source   = "../resources/foundations"
  team     = local.team
  project  = local.project
  env      = local.env
  location = local.location
  resource_group_name = "shanice-new-ecrv"
}

module "networking" {
  source              = "../resources/networking"
  team                = local.team
  project             = local.project
  env                 = local.env
  location            = local.location
  resource_group_name = "shanice-new-ecrv"

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
  resource_group_name = "shanice-new-ecrv"

  aca_subnet_id   = module.networking.subnet_aca_id
  appgw_subnet_id = module.networking.subnet_appgw_id
  vnet_id         = module.networking.network.id

  acr_url      = module.foundations.acr_url
  acr_username = module.foundations.acr_admin_username
  acr_password = module.foundations.acr_admin_password

  dibbs_version = "8.5.0"

  azure_storage_connection_string = module.foundations.azure_storage_connection_string
  azure_container_name            = module.foundations.azure_container_name

  ecr_viewer_mode = "AZURE_SQLSERVER_DUAL"

  nbs_public_key = <<EOT
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAnlA1YmmbydxQdBh7DAq0
wUfsjR25eWZOB995mHclT3C46oLat3YLu70akLfoMXd9YcJe0d4q3sP7tS1J4QDO
IkfapvK3ClDJR2VUERTzR9yQ+1B1Sd+MSful/V3aP9L6wPRAJmsmziizUBz+X0oN
WTkGP/xi0F/IlyBfh2sk89JKKmgXSFbgDTD7+8L5WeRY5koR0KfDJLBcyerrcIPW
1FyD8RbkUH78yJXc+/ThXKBNpsDTvV0k/4zqLSADIEmhQFkW8oYOfF4ufBGSnGdZ
gPoWbKHtlK+m1sFWMq0hAtJsNKsJQocPAEO2NIxRCX4k6X9HfvCYVniDI4OdVz0V
jTF+galQDAybgtYc9ZN8ROpePDVkCANHzniBJFOwzv2yekreqdX7M399uLB+ztDX
Iz2RpZbGkgspl4TWvvB+eN64DJykmExImIw1nFc/6AVd3jhKSnCrckpGV3XaF8lW
WMA6au0RXjmRa4YxO/uQbFZeFkM7aQtQK/CxqdBfG0SACcIMwU2S7Kb5+c9Hs687
LI8j7j0oVyCiAyJ44Mi70i4A2GedyM6kzdixTmszin+c4tT8mYjmEMpJle6GLBIa
aqEy3CVEqecFIo4ypfoo4GjTqvv/JjtxwBl1FPC+HzFkOjSoLbrDmn64NnQhXlC9
kd+ONf43CmqDSTa3atSFq4sCAwEAAQ==
-----END PUBLIC KEY-----
          EOT

  nbs_api_public_key = <<EOT
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAnlA1YmmbydxQdBh7DAq0
wUfsjR25eWZOB995mHclT3C46oLat3YLu70akLfoMXd9YcJe0d4q3sP7tS1J4QDO
IkfapvK3ClDJR2VUERTzR9yQ+1B1Sd+MSful/V3aP9L6wPRAJmsmziizUBz+X0oN
WTkGP/xi0F/IlyBfh2sk89JKKmgXSFbgDTD7+8L5WeRY5koR0KfDJLBcyerrcIPW
1FyD8RbkUH78yJXc+/ThXKBNpsDTvV0k/4zqLSADIEmhQFkW8oYOfF4ufBGSnGdZ
gPoWbKHtlK+m1sFWMq0hAtJsNKsJQocPAEO2NIxRCX4k6X9HfvCYVniDI4OdVz0V
jTF+galQDAybgtYc9ZN8ROpePDVkCANHzniBJFOwzv2yekreqdX7M399uLB+ztDX
Iz2RpZbGkgspl4TWvvB+eN64DJykmExImIw1nFc/6AVd3jhKSnCrckpGV3XaF8lW
WMA6au0RXjmRa4YxO/uQbFZeFkM7aQtQK/CxqdBfG0SACcIMwU2S7Kb5+c9Hs687
LI8j7j0oVyCiAyJ44Mi70i4A2GedyM6kzdixTmszin+c4tT8mYjmEMpJle6GLBIa
aqEy3CVEqecFIo4ypfoo4GjTqvv/JjtxwBl1FPC+HzFkOjSoLbrDmn64NnQhXlC9
kd+ONf43CmqDSTa3atSFq4sCAwEAAQ==
-----END PUBLIC KEY-----
          EOT

  nextauth_url = "https://${local.team}-${local.project}-${local.env}.${local.location}.cloudapp.azure.com/ecr-viewer/api/auth"

  key_vault_id = "/subscriptions/6848426c-8ca8-4832-b493-fed851be1f95/resourceGroups/shanice-new-ecrv/providers/Microsoft.KeyVault/vaults/shanice-keyvault-ecrv" //Update this to match your target key vault. Follows the longform format: "/subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.KeyVault/vaults/{key-vault-name}"

  ecr_viewer_db_fqdn = "ecrv-test-server.database.windows.net" //Update this to match your target database server. Omit the protocol and port number.

  ecr_viewer_db_name = "ecrv2-db" //Update this to match the name of your desired database on the SQL instance.

  use_ssl = true //Set this to false if you do not want to use SSL for the ACA gateway.

  pre_assigned_identity_id = "/subscriptions/6848426c-8ca8-4832-b493-fed851be1f95/resourceGroups/shanice-new-ecrv/providers/Microsoft.ManagedIdentity/userAssignedIdentities/test-ecrv" //Set to the ID of a user-assigned managed identity for your gateway if you want to use one. Follows the longform format: "/subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identity-name}"
}