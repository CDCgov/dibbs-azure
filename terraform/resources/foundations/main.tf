resource "azurerm_resource_group" "rg" {
  name     = "${var.team}-${var.project}-${var.env}"
  location = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
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
}

resource "azurerm_container_registry" "acr" {
  location            = azurerm_resource_group.rg.location
  name                = "${var.team}${var.project}${var.env}acr"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_storage_account" "app" {
  account_replication_type         = "GRS" # Cross-regional redundancy
  account_tier                     = "Standard"
  account_kind                     = "StorageV2"
  name                             = "${var.team}${var.project}${var.env}sa"
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  https_traffic_only_enabled       = true
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
}

resource "azurerm_storage_container" "ecr_data" {
  name                  = "eCR_data"
  storage_account_name = azurerm_storage_account.app.name
  container_access_type = "private"
}