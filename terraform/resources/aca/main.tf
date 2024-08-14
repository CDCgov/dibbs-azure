locals {
  name = "${var.team}-${var.project}-${var.env}"

  workload_profile = "dibbs-profile"

  registry = {
    server   = var.acr_url
    username = var.acr_username
    password = var.acr_password
  }

  building_block_definitions = {
    fhir-converter = {
      name        = "fhir-converter"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = false

      env_vars = []
    }
    ingestion = {
      name        = "ingestion"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = false

      env_vars = []
    }
    message-parser = {
      name        = "message-parser"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = false

      env_vars = []
    }
    orchestration = {
      name        = "orchestration"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = true

      env_vars = [
        {
          name  = "OTEL_METRICS",
          value = "none"
        },
        {
          name  = "OTEL_METRICS_EXPORTER",
          value = "none"
        },
        {
          name  = "INGESTION_URL",
          value = "http://ingestion.${azurerm_container_app_environment.ce_apps.default_domain}:8080"
        },
        {
          name  = "VALIDATION_URL",
          value = "http://validation.${azurerm_container_app_environment.ce_apps.default_domain}:8080"
        },
        {
          name  = "FHIR_CONVERTER_URL",
          value = "http://fhir-converter.${azurerm_container_app_environment.ce_apps.default_domain}:8080"
        },
        {
          name  = "ECR_VIEWER_URL",
          value = "http://ecr-viewer.${azurerm_container_app_environment.ce_apps.default_domain}:3000/ecr-viewer"
        },
        {
          name  = "MESSAGE_PARSER_URL",
          value = "http://message-parser.${azurerm_container_app_environment.ce_apps.default_domain}:8080"
        },
        {
          name  = "TRIGGER_CODE_REFERENCE_URL",
          value = "http://trigger-code-reference.${azurerm_container_app_environment.ce_apps.default_domain}:8080" //"http://trigger-code-reference:8080"
        }
      ]
    }
    validation = {
      name        = "validation"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = false

      env_vars = []
    }
    trigger-code-reference = {
      name        = "trigger-code-reference"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = false

      env_vars = []
    }
    ecr-viewer = {
      name        = "ecr-viewer"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = true

      env_vars = []
    }
    record-linkage = {
      name        = "record-linkage"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = false

      env_vars = []
    }
  }

  path_rules = [
    {
      name                       = "orchestration"
      paths                      = ["/api/*", "/api"]
      backend_address_pool_name  = local.orchestration_backend_pool
      backend_http_settings_name = local.orchestration_backend_https_setting
      // this is the default, why would we set it again?
      // because if we don't do this we get 404s on API calls
      rewrite_rule_set_name = "orchestration-routing"
    },
    {
      name                       = "ecr-viewer"
      paths                      = ["/api/*", "/api"]
      backend_address_pool_name  = local.ecr_viewer_pool
      backend_http_settings_name = local.ecr_viewer_https_setting
      // this is the default, why would we set it again?
      // because if we don't do this we get 404s on API calls
      rewrite_rule_set_name = "ecr-viewer-routing"
    }
  ]
}

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

  //Can create additional profiles for FHIR converter, etc.
  workload_profile {
    name                  = local.workload_profile
    workload_profile_type = "D4"
    maximum_count         = 10
    minimum_count         = 1
  }

  internal_load_balancer_enabled = true
}

resource "azurerm_container_app" "aca_apps" {
  for_each = local.building_block_definitions

  name                         = each.value.name
  container_app_environment_id = azurerm_container_app_environment.ce_apps.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  /*template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }*/

  template {
    container {
      name   = each.value.name
      image  = "${var.acr_url}/${var.ghcr_string}${each.value.name}:${each.value.app_version}"
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
    allow_insecure_connections = false
    external_enabled           = false
    target_port                = 8080
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
    //TODO: change the above to a key vault reference.
  }

  secret {
    name  = "acr-password-secret"
    value = "var.acr_password"
  } //TODO: Delete this in favor of key vault reference?

  workload_profile_name = local.workload_profile
}