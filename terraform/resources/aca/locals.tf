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

      target_port = 8080
    }
    ingestion = {
      name        = "ingestion"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = false

      env_vars = []

      target_port = 8080
    }
    message-parser = {
      name        = "message-parser"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = false

      env_vars = []

      target_port = 8080
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
          value = "http://ingestion.internal.${azurerm_container_app_environment.ce_apps.default_domain}"
        },
        {
          name  = "VALIDATION_URL",
          value = "http://validation.internal.${azurerm_container_app_environment.ce_apps.default_domain}"
        },
        {
          name  = "FHIR_CONVERTER_URL",
          value = "http://fhir-converter.internal.${azurerm_container_app_environment.ce_apps.default_domain}"
        },
        {
          name  = "ECR_VIEWER_URL",
          value = "http://ecr-viewer.${azurerm_container_app_environment.ce_apps.default_domain}"
        },
        {
          name  = "MESSAGE_PARSER_URL",
          value = "http://message-parser.internal.${azurerm_container_app_environment.ce_apps.default_domain}"
        },
        {
          name  = "TRIGGER_CODE_REFERENCE_URL",
          value = "http://trigger-code-reference.internal.${azurerm_container_app_environment.ce_apps.default_domain}"
        }
      ]

      target_port = 8080
    }
    validation = {
      name        = "validation"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = false

      env_vars = []

      target_port = 8080
    }
    trigger-code-reference = {
      name        = "trigger-code-reference"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = false

      env_vars = []

      target_port = 8080
    }
    ecr-viewer = {
      name        = "ecr-viewer"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = true

      env_vars = [
        {
          name  = "AZURE_STORAGE_CONNECTION_STRING",
          value = var.azure_storage_connection_string
        },
        {
          name  = "AZURE_CONTAINER_NAME",
          value = var.azure_container_name
        }
      ]

      target_port = 3000
    }
    record-linkage = {
      name        = "record-linkage"
      cpu         = 0.5
      memory      = "1Gi"
      app_version = var.dibbs_version

      is_public = false

      env_vars = []

      target_port = 8080
    }
  }

  http_listener   = "${local.name}-http"
  https_listener  = "${local.name}-https"
  frontend_config = "${local.name}-config"
  redirect_rule   = "${local.name}-redirect"

  aca_backend_pool                    = "${local.name}-be-aca"
  aca_backend_http_setting            = "${local.name}-be-aca-http"
  orchestration_backend_pool          = "${local.name}-be-orchestration"
  orchestration_backend_http_setting  = "${local.name}-be-orchestration-http"
  orchestration_backend_https_setting = "${local.name}-be-orchestration-https"
  ecr_viewer_backend_pool             = "${local.name}-be-ecr_viewer"
  ecr_viewer_backend_http_setting     = "${local.name}-be-api-ecr_viewer-http"
  ecr_viewer_backend_https_setting    = "${local.name}-be-api-ecr_viewer-https"
}