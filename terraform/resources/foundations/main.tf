resource "azurerm_resource_group" "rg" {
  count    = var.resource_group_name == null ? 1 : 0
  name     = "${var.team}-${var.project}-${var.env}"
  location = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_container_registry" "acr" {
  location            = var.resource_group_name != null ? data.azurerm_resource_group.rg[0].location : azurerm_resource_group.rg[0].location
  name                = "${var.team}${var.project}${var.env}acr"
  resource_group_name = var.resource_group_name != null ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_storage_account" "app" {
  account_replication_type         = "GRS" # Cross-regional redundancy
  account_tier                     = "Standard"
  account_kind                     = "StorageV2"
  name                             = "${var.team}${var.project}${var.env}sa"
  resource_group_name              = var.resource_group_name != null ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
  location                         = var.resource_group_name != null ? data.azurerm_resource_group.rg[0].location : azurerm_resource_group.rg[0].location
  https_traffic_only_enabled       = true
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
}

resource "azurerm_storage_container" "ecr_data" {
  name                  = "ecr-data"
  storage_account_name  = azurerm_storage_account.app.name
  container_access_type = "private"
}