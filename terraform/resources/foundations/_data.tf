data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  count = var.resource_group_name != null ? 1 : 0
  name  = var.resource_group_name
}