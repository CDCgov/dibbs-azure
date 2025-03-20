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

data "azurerm_key_vault_secret" "ecr_viewer_nextauth_secret" {
  name         = "ecr-viewer-nextauth-secret"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "ecr_viewer_client_secret" {
  name         = "ecr-viewer-client-secret"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_certificate" "dibbs_site_cert" {
  count        = var.use_ssl ? 1 : 0
  name         = "dibbs-site-cert"
  key_vault_id = ""
}

data "azuread_client_config" "current" {}