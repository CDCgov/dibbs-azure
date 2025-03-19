resource "azurerm_log_analytics_workspace" "aca_analytics" {
  name                = "${local.name}-aca-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  daily_quota_gb = 5
}

resource "azurerm_container_app_environment" "ce_apps" {
  name                       = "${local.name}-apps"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca_analytics.id

  infrastructure_resource_group_name = "${local.name}-apps-rg"
  infrastructure_subnet_id           = var.aca_subnet_id

  /*
   * Can create additional profiles for FHIR converter, etc. if needed.
   * Be sure to adjust the value for workload_profile_type if your building blocks
   * hit the resource cap.
   */
  workload_profile {
    name                  = local.workload_profile
    workload_profile_type = "D4"
    maximum_count         = 10
    minimum_count         = 1
  }

  internal_load_balancer_enabled = true
}

/*
 * Due to internal timings within Azure, the container registry needs extra time to process the presence
 * of the images before they are available to be read by the Azure Container Apps environment.
 */
resource "time_sleep" "wait_for_app_images" {
  depends_on      = [dockerless_remote_image.dibbs]
  create_duration = "60s"
}

resource "azurerm_container_app" "aca_apps" {
  for_each = local.building_block_definitions

  name                         = each.value.name
  container_app_environment_id = azurerm_container_app_environment.ce_apps.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = each.value.name
      image  = "${var.acr_url}/${each.value.name}:${each.value.app_version}"
      cpu    = each.value.cpu
      memory = each.value.memory

      dynamic "env" {
        for_each = each.value.env_vars

        content {
          name  = env.value.name
          value = env.value.value
        }
      }
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = each.value.is_public
    target_port                = each.value.target_port
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server               = var.acr_url
    username             = var.acr_username
    password_secret_name = "acr-password-secret"
  }

  secret {
    name  = "acr-password-secret"
    value = var.acr_password
  }

  workload_profile_name = local.workload_profile

  depends_on = [time_sleep.wait_for_app_images]
}

resource "time_sleep" "wait_for_query_images" {
  depends_on      = [dockerless_remote_image.query_connector_aca_image]
  create_duration = "60s"
}
resource "time_sleep" "wait_for_site_images" {
  depends_on      = [dockerless_remote_image.dibbs_site_aca_image]
  create_duration = "60s"
}

resource "azurerm_container_app" "query_connector" {
  name                         = var.query_connector_container_name
  container_app_environment_id = azurerm_container_app_environment.ce_apps.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = var.query_connector_container_name
      image  = "${var.acr_url}/${var.query_connector_container_name}:${var.query_connector_version}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "NODE_ENV"
        value = "production"
      }
      env {
        name  = "DATABASE_URL"
        value = "postgres://${data.azurerm_key_vault_secret.query_connector_db_username.value}:${urlencode(data.azurerm_key_vault_secret.query_connector_db_password.value)}@${var.query_connector_db_fqdn}:${var.query_connector_db_port}/${var.query_connector_db_name}"
      }
      env {
        name  = "FLYWAY_URL"
        value = "jdbc:postgresql://${var.query_connector_db_fqdn}:${var.query_connector_db_port}/${var.query_connector_db_name}"
      }
      env {
        name  = "FLYWAY_USER"
        value = data.azurerm_key_vault_secret.query_connector_db_username.value
      }
      env {
        name  = "FLYWAY_PASSWORD"
        value = data.azurerm_key_vault_secret.query_connector_db_password.value
      }
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 3000
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server               = var.acr_url
    username             = var.acr_username
    password_secret_name = "acr-password-secret"
  }

  secret {
    name  = "acr-password-secret"
    value = var.acr_password
  }

  workload_profile_name = local.workload_profile

  depends_on = [time_sleep.wait_for_query_images]
}

resource "azurerm_container_app" "dibbs_site" {
  name                         = var.dibbs_site_container_name
  container_app_environment_id = azurerm_container_app_environment.ce_apps.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = var.dibbs_site_container_name
      image  = "${var.acr_url}/${var.dibbs_site_container_name}:${var.dibbs_site_version}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "NODE_ENV"
        value = "production"
      }
      env {
        name  = "NEXT_TELEMETRY_DISABLED"
        value = 1
      }
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 3000
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server               = var.acr_url
    username             = var.acr_username
    password_secret_name = "acr-password-secret"
  }

  secret {
    name  = "acr-password-secret"
    value = var.acr_password
  }

  workload_profile_name = local.workload_profile

  depends_on = [time_sleep.wait_for_site_images]
}