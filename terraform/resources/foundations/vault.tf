#tfsec:ignore:azure-keyvault-specify-network-acl:exp:2024-12-01
locals {
  current_user_id = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.team}${var.project}${var.env}kv"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  enable_rbac_authorization = true

  //It's recommended to set an access control list for the key vault. The network_acls block can be removed if your needs require it.
  /*network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    virtual_network_subnet_ids = [var.aca_subnet_id, var.appgw_subnet_id]
  }*/
}

/*

resource "azurerm_key_vault_access_policy" "ecr-viewer-db" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.ecr_viewer_db.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_access_policy" "query-connector-db" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.query_connector_db.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_access_policy" "tf-user" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = local.current_user_id

  secret_permissions = var.secret_permissions
}
*/

resource "azurerm_role_assignment" "key_vault_administrator" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = local.current_user_id
}

resource "time_sleep" "wait_for_rbac_propagation" {
  depends_on      = [azurerm_role_assignment.key_vault_administrator]
  create_duration = "300s"
}

resource "azurerm_key_vault_secret" "acr_admin_username" {
  name         = "acr-admin-username"
  value        = azurerm_container_registry.acr.admin_username
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_rbac_propagation]
}

resource "azurerm_key_vault_secret" "acr_admin_password" {
  name         = "acr-admin-password"
  value        = azurerm_container_registry.acr.admin_password
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_rbac_propagation]
}

resource "azurerm_key_vault_secret" "ecr_viewer_nextauth_secret" {
  name         = "ecr-viewer-nextauth-secret"
  value        = random_bytes.ecr_viewer_nextauth_secret.base64
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_rbac_propagation]
}

resource "random_bytes" "ecr_viewer_nextauth_secret" {
  length = 32
}