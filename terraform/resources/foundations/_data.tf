data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = "<YOUR_RESOURCE_GROUP_NAME>"
}