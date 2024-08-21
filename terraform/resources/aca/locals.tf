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
          value = "http://trigger-code-reference.${azurerm_container_app_environment.ce_apps.default_domain}:8080"
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

      env_vars = []

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
  /*
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
      backend_address_pool_name  = local.ecr_viewer_backend_pool
      backend_http_settings_name = local.ecr_viewer_backend_https_setting
      // this is the default, why would we set it again?
      // because if we don't do this we get 404s on API calls
      rewrite_rule_set_name = "ecr-viewer-routing"
    }
  ]*/

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

  #networkContributorRole         = "[concat('/subscriptions/', subscription().subscriptionId, '/providers/Microsoft.Authorization/roleDefinitions/', '4d97b98b-1d4f-4787-a291-c67834d212e7')]"
}