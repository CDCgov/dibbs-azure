data "azurerm_client_config" "current" {}

data "azurerm_key_vault_secret" "ecr_viewer_db_username" {
  name         = "ecr-viewer-db-username"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "ecr_viewer_db_password" {
  name         = "ecr-viewer-db-password"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "ecr_viewer_client_id" {
    name         = "ecr-viewer-client-id"
    key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "ecr_viewer_client_secret" {
  name         = "ecr-viewer-client-secret"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "ecr_viewer_nextauth_secret" {
  name         = "ecr-viewer-nextauth-secret"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "azuread_tenant_id" {
  name         = "ecr-viewer-azuread-tenant-id"
  key_vault_id = var.key_vault_id
}