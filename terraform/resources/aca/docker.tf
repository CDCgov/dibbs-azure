resource "time_static" "now" {}

resource "dockerless_remote_image" "dibbs" {
  for_each = local.building_block_definitions
  source   = "${var.ghcr_string}${each.key}:${each.value.app_version}"
  target   = "${var.acr_url}/${each.value.name}:${each.value.app_version}"
}

resource "dockerless_remote_image" "query_connector_aca_image" {
  source   = "${var.query_connector_ghcr_string}${var.query_connector_container_name}:${var.query_connector_version}"
  target   = "${var.acr_url}/${var.query_connector_container_name}:${var.query_connector_version}"
}

resource "dockerless_remote_image" "dibbs_site_aca_image" {
  //source   = "${var.dibbs_site_ghcr_string}${var.dibbs_site_container_name}:${var.dibbs_site_version}"
  source   = "${var.dibbs_site_ghcr_string}:${var.dibbs_site_version}"
  target   = "${var.acr_url}/${var.dibbs_site_container_name}:${var.dibbs_site_version}"
}