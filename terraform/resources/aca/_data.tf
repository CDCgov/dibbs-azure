data "azurerm_client_config" "current" {}

data "docker_registry_image" "ghcr_data" {
  for_each = local.building_block_definitions
  name     = "${var.ghcr_string}${each.key}:${each.value.app_version}"
}