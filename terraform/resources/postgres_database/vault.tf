#tfsec:ignore:azure-keyvault-specify-network-acl:exp:2024-12-01
locals {
  current_user_id = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.team}${var.project}${var.env}kv"
  location                    = var.location
  resource_group_name         = var.resource_group_name
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

resource azurerm_user_assigned_identity "ecr_viewer_db" {
  name                = "ecr-viewer-${var.env}-db-identity"
  resource_group_name = var.resource_group_name
  location = var.location
}

resource azurerm_user_assigned_identity "query_connector_db" {
  name                = "query-connector-${var.env}-db-identity"
  resource_group_name = var.resource_group_name
  location = var.location
}

resource "azurerm_role_assignment" "key_vault_administrator" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = local.current_user_id
}

resource "time_sleep" "wait_for_rbac_propagation" {
  depends_on      = [azurerm_role_assignment.key_vault_administrator]
  create_duration = "300s"
}

# Creates random password for the database
resource "azurerm_key_vault_secret" "ecr_viewer_db_username" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = "ecr-viewer-db-username"
  value        = var.ecr_viewer_db_username

  depends_on = [ time_sleep.wait_for_rbac_propagation ]
}

//TODO: Change this to use a TF-generated password, like db-password-no-phi. See #3673 for the additional work.
resource "azurerm_key_vault_secret" "ecr_viewer_db_password" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = "ecr-viewer-db-password"
  value = random_password.setup_rds_password[0].result

  depends_on = [ time_sleep.wait_for_rbac_propagation ]
}

# Create the no-PHI user
resource "azurerm_key_vault_secret" "query_connector_db_username" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = "query-connector-db-username"
  value        = var.query_connector_db_username

  depends_on = [ time_sleep.wait_for_rbac_propagation ]
}

resource "azurerm_key_vault_secret" "query_connector_db_password" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = "query-connector-db-password"
  value = random_password.setup_rds_password[0].result

  depends_on = [ time_sleep.wait_for_rbac_propagation ]
}

resource "random_password" "setup_rds_password" {
  count = 2
  length = 24

  # Character set that excludes problematic characters like quotes, backslashes, etc.
  override_special = "_!@#-$%^&*()[]{}"
}