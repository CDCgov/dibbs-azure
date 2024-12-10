data "azurerm_client_config" "current" {}

data "azurerm_key_vault_secret" "ecr_viewer_db_username" {
  name         = "ecr-viewer-db-username"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "ecr_viewer_db_password" {
  name         = "ecr-viewer-db-password"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "query_connector_db_username" {
  name         = "query-connector-db-username"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "query_connector_db_password" {
  name         = "query-connector-db-password"
  key_vault_id = var.key_vault_id
}