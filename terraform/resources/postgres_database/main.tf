resource "azurerm_postgresql_flexible_server" "ecr_viewer_db" {
  name                          = "ecr-viewer-${var.env}-flexible-db"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku_name                      = var.env == "prod" ? "MO_Standard_E2ds_v4" : "MO_Standard_E2ds_v4" # Lowering capacity for now, since eCR viewer is not a high-load service.
  version                       = "16"
  delegated_subnet_id           = var.db_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.default.id
  public_network_access_enabled = false


  administrator_login    = azurerm_key_vault_secret.ecr_viewer_db_username.value
  administrator_password = azurerm_key_vault_secret.ecr_viewer_db_password.value

  storage_mb                   = 524288 // 512 GB
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  //tags = var.tags

  # Time is Eastern
  maintenance_window {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }

  # Only activate high availability in production for now.
  dynamic "high_availability" {
    for_each = var.env == "prod" ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = 2
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ecr_viewer_db.id]
  }

  # See note at https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server#high_availability
  lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone,
      tags
    ]
  }
  depends_on = [azurerm_private_dns_zone_virtual_network_link.vnet_link]
}

resource "azurerm_postgresql_flexible_server_configuration" "ev-ossp" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.ecr_viewer_db.id
  value     = "UUID-OSSP"
}

resource "azurerm_postgresql_flexible_server_configuration" "ssl_off" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.ecr_viewer_db.id
  value     = "off"
}

resource "azurerm_postgresql_flexible_server_database" "ecr_viewer" {
  charset   = "UTF8"
  collation = "en_US.utf8"
  name      = var.ecr_viewer_db_name
  server_id = azurerm_postgresql_flexible_server.ecr_viewer_db.id
}

resource "azurerm_postgresql_flexible_server" "query_connector_db" {
  name                          = "query-connector-${var.env}-flexible-db"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku_name                      = var.env == "prod" ? "MO_Standard_E4ds_v4" : "MO_Standard_E2ds_v4"
  version                       = "16"
  delegated_subnet_id           = var.db_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.default.id
  public_network_access_enabled = false


  administrator_login    = azurerm_key_vault_secret.query_connector_db_username.value
  administrator_password = azurerm_key_vault_secret.query_connector_db_password.value

  storage_mb                   = 524288 // 512 GB
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  //tags = var.tags

  # Time is Eastern
  maintenance_window {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }

  # Only activate high availability in production for now.
  dynamic "high_availability" {
    for_each = var.env == "prod" ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = 2
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.query_connector_db.id]
  }

  # See note at https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server#high_availability
  lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone,
      tags
    ]
  }
  depends_on = [azurerm_private_dns_zone_virtual_network_link.vnet_link]
}

resource "azurerm_postgresql_flexible_server_configuration" "qc-ossp" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.query_connector_db.id
  value     = "UUID-OSSP"
}

resource "azurerm_postgresql_flexible_server_database" "query_connector" {
  charset   = "UTF8"
  collation = "en_US.utf8"
  name      = var.query_connector_db_name
  server_id = azurerm_postgresql_flexible_server.query_connector_db.id
}

resource "azurerm_private_dns_zone" "default" {
  name                = "privatelink.${var.env}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

# DNS/VNet linkage for Flexible DB functionality
# TODO: Import the existing links for each standing environment.
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "${var.env}-vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = var.db_vnet_id
}

resource "azurerm_user_assigned_identity" "ecr_viewer_db" {
  name                = "ecr-viewer-${var.env}-db-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_user_assigned_identity" "query_connector_db" {
  name                = "query-connector-${var.env}-db-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}