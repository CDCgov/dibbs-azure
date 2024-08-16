resource "azurerm_private_dns_zone" "aca" {
  name                = "${local.name}.privatelink.azurecontainer.io"
  resource_group_name = var.resource_group_name
}

resource "azurerm_public_ip" "aca_ingress" {
  name                = "${local.name}-aca-gateway-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  domain_name_label = local.name
}

resource "azurerm_user_assigned_identity" "gateway" {
  name                = "dibbs-${var.env}-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_application_gateway" "load_balancer" {
  name                = "${local.name}-app-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = var.autoscale_min
    max_capacity = var.autoscale_max
  }

  gateway_ip_configuration {
    name      = "${local.name}-gateway-ip-config"
    subnet_id = var.aca_subnet_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.gateway.id]
  }

  # ------- Backend Orchestration Endpoint -------------------------
  backend_address_pool {
    name         = local.orchestration_backend_pool
    fqdns        = [azurerm_container_app.aca_apps["orchestration"].latest_revision_fqdn] //HAS to be FQDN of the orchestration container.
    ip_addresses = var.orchestration_ip_addresses
  }

  backend_http_settings {
    name                                = local.orchestration_backend_http_setting
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "be-http"
  }

  backend_http_settings {
    name                                = local.orchestration_backend_https_setting
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "be-https"
  }

  probe {
    name                                      = "be-http"
    interval                                  = 10
    path                                      = "/actuator/health" //TODO: Change to Orchestration endpoint
    pick_host_name_from_backend_http_settings = true
    protocol                                  = "Http"
    timeout                                   = 10
    unhealthy_threshold                       = 3

    match {
      body        = "UP"
      status_code = [200]
    }
  }

probe {
    name                                      = "be-https"
    interval                                  = 10
    path                                      = "/actuator/health"
    pick_host_name_from_backend_http_settings = true
    protocol                                  = "Https"
    timeout                                   = 10
    unhealthy_threshold                       = 3

    match {
      body        = "UP"
      status_code = [200]
    }
  }

  # ------- Backend ecr_viewer App ------------------------- ECR VIEWER
  backend_address_pool {
    name         = local.ecr_viewer_pool
    fqdns        = [azurerm_container_app.aca_apps["ecr-viewer"].latest_revision_fqdn] //HAS to be the fqdn of the ecr viewer.
    ip_addresses = var.ecr_viewer_ip_addresses
  }

  backend_http_settings {
    name                                = local.ecr_viewer_http_setting
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                                = local.ecr_viewer_https_setting
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
  }

  # ------- Listeners -------------------------

  frontend_ip_configuration {
    name                 = local.frontend_config
    public_ip_address_id = azurerm_public_ip.aca_ingress.id
  }

  # --- HTTP Listener
  frontend_port {
    name = local.http_listener
    port = 80
  }

  http_listener {
    name                           = local.http_listener
    frontend_ip_configuration_name = local.frontend_config
    frontend_port_name             = local.http_listener
    protocol                       = "Http"
  }

  # --- HTTPS Listener ---

  frontend_port {
    name = local.https_listener
    port = 443
  }

  http_listener {
    name                           = local.https_listener
    frontend_ip_configuration_name = local.frontend_config
    frontend_port_name             = local.https_listener
    protocol                       = "Https"
    ssl_certificate_name           = data.azurerm_key_vault_certificate.wildcard_simplereport_gov.name
  }

  
  ssl_certificate {
    name                = data.azurerm_key_vault_certificate.wildcard_simplereport_gov.name
    key_vault_secret_id = data.azurerm_key_vault_certificate.wildcard_simplereport_gov.secret_id
  }

  ssl_policy {
    policy_name = "AppGwSslPolicy20170401S"
    policy_type = "Predefined"
  }

  # ------- Routing -------------------------
  # HTTP -> HTTPS redirect
  request_routing_rule {
    name                        = local.redirect_rule
    priority                    = 100
    rule_type                   = "Basic"
    http_listener_name          = "${local.name}-http"
    redirect_configuration_name = local.redirect_rule
  }

  redirect_configuration {
    name = local.redirect_rule

    include_path         = true
    include_query_string = true
    redirect_type        = "Permanent"
    target_listener_name = local.https_listener
  }

  # HTTPS path-based routing
  request_routing_rule {
    name                       = "${local.name}-routing-https"
    priority                   = 200
    rule_type                  = "PathBasedRouting"
    http_listener_name         = local.https_listener
    backend_address_pool_name  = local.orchestration_backend_pool
    backend_http_settings_name = local.orchestration_backend_https_setting
    url_path_map_name          = "${local.name}-urlmap"
  }

  //Should we default to orchestrator for the static pool?
  url_path_map {
    name                               = "${local.name}-urlmap"
    default_backend_address_pool_name  = local.orchestration_backend_pool
    default_backend_http_settings_name = local.orchestration_backend_https_setting
    default_rewrite_rule_set_name      = "ecr-viewer-routing"

    path_rule {
      name                       = "orchestration"
      paths                      = ["/api/*", "/api"]
      backend_address_pool_name  = local.orchestration_backend_pool
      backend_http_settings_name = local.orchestration_backend_https_setting
      // this is the default, why would we set it again?
      // because if we don't do this we get 404s on API calls
      rewrite_rule_set_name = "orchestration-routing"
    }

    path_rule {
      name                       = "ecr-viewer"
      paths                      = ["/api/*", "/api"]
      backend_address_pool_name  = local.ecr_viewer_pool
      backend_http_settings_name = local.ecr_viewer_https_setting
      // this is the default, why would we set it again?
      // because if we don't do this we get 404s on API calls
      rewrite_rule_set_name = "ecr-viewer-routing"
    }
  }

  rewrite_rule_set {
    name = "ecr-viewer-routing"

    rewrite_rule {
      name          = "ecr-viewer-wildcard"
      rule_sequence = 100
      condition {
        ignore_case = true
        negate      = false
        pattern     = ".*/ecr_viewer(.*)"
        variable    = "var_uri_path"
      }

      url {
        path    = "/{var_uri_path_1}"
        reroute = false
        # Per documentation, we should be able to leave this pass-through out. See however
        # https://github.com/terraform-providers/terraform-provider-azurerm/issues/11563
        query_string = "{var_query_string}"
      }
    }
  }

  rewrite_rule_set {
    name = "orchestration-routing"

    rewrite_rule {
      name          = "orchestration-wildcard"
      rule_sequence = 100
      condition {
        ignore_case = true
        negate      = false
        pattern     = ".*/orchestration(.*)"
        variable    = "var_uri_path"
      }

      url {
        path    = "/{var_uri_path_1}"
        reroute = false
        # Per documentation, we should be able to leave this pass-through out. See however
        # https://github.com/terraform-providers/terraform-provider-azurerm/issues/11563
        query_string = "{var_query_string}"
      }
    }
  }

  depends_on = [
    azurerm_public_ip.aca_ingress,
    azurerm_key_vault_access_policy.gateway
  ]

  firewall_policy_id = azurerm_web_application_firewall_policy.aca_waf_policy.id

  //tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_key_vault_access_policy" "gateway" {
  key_vault_id = var.key_vault_id
  object_id    = azurerm_user_assigned_identity.gateway.principal_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = ["Get"]
}


// Gateway analytics
resource "azurerm_monitor_diagnostic_setting" "logs_metrics" {
  name                       = "${local.name}-gateway-logs-metrics"
  target_resource_id         = azurerm_application_gateway.load_balancer.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca_analytics.id

  dynamic "enabled_log" {
    for_each = [
      "ApplicationGatewayAccessLog",
      "ApplicationGatewayPerformanceLog",
      "ApplicationGatewayFirewallLog",
    ]
    content {
      category = enabled_log.value

      retention_policy {
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = [
      "AllMetrics",
    ]
    content {
      category = metric.value

      retention_policy {
        enabled = false
      }
    }
  }
}

