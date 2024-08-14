resource "time_static" "now" {}

resource "docker_image" "ghcr_image" {
  for_each      = local.building_block_definitions
  name          = data.docker_registry_image.ghcr_data[each.key].name
  keep_locally  = true
  pull_triggers = [data.docker_registry_image.ghcr_data[each.key].sha256_digest, plantimestamp()]
  force_remove  = true
}

resource "docker_tag" "tag_for_azure" {
  for_each     = local.building_block_definitions
  source_image = docker_image.ghcr_image[each.key].name
  target_image = "${var.acr_url}/${docker_image.ghcr_image[each.key].name}"
  lifecycle {
    replace_triggered_by = [
      null_resource.docker_tag
    ]
  }
}

resource "docker_registry_image" "aca_image" {
  for_each = local.building_block_definitions
  name     = "${var.acr_url}/${docker_image.ghcr_image[each.key].name}"
  depends_on = [
    docker_image.ghcr_image,
    docker_tag.tag_for_azure
  ]
  keep_remotely = true

  triggers = {
    sha256_digest = data.docker_registry_image.ghcr_data[each.key].sha256_digest
  }
}

resource "null_resource" "docker_tag" {
  for_each = docker_image.ghcr_image
  triggers = {
    docker_image = each.value.id
  }
}
