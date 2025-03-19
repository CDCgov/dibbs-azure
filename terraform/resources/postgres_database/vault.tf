# Creates random password for the database
resource "azurerm_key_vault_secret" "ecr_viewer_db_username" {
  key_vault_id = var.key_vault_id
  name         = "ecr-viewer-db-username"
  value        = var.ecr_viewer_db_username
}

//TODO: Change this to use a TF-generated password, like db-password-no-phi. See #3673 for the additional work.
resource "azurerm_key_vault_secret" "ecr_viewer_db_password" {
  key_vault_id = var.key_vault_id
  name         = "ecr-viewer-db-password"
  value        = random_password.setup_rds_password[0].result
}

# Create the no-PHI user
resource "azurerm_key_vault_secret" "query_connector_db_username" {
  key_vault_id = var.key_vault_id
  name         = "query-connector-db-username"
  value        = var.query_connector_db_username
}

resource "azurerm_key_vault_secret" "query_connector_db_password" {
  key_vault_id = var.key_vault_id
  name         = "query-connector-db-password"
  value        = random_password.setup_rds_password[0].result
}

resource "random_password" "setup_rds_password" {
  count  = 2
  length = 24

  # Character set that excludes problematic characters like quotes, backslashes, etc.
  override_special = "_!@#-$%^&*()[]{}"
}