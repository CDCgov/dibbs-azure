resource "azurerm_private_dns_zone" "aca_zone" {
  name                = azurerm_container_app_environment.ce_apps.default_domain
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_a_record" "aca_record" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.aca_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_container_app_environment.ce_apps.static_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "aca_vnet_link" {
  name                = "${local.name}-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aca_zone.name
  virtual_network_id    = var.vnet_id
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
    subnet_id = var.appgw_subnet_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.gateway.id]
  }

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

  # --- Container Environment Pool

  backend_address_pool {
    name         = local.aca_backend_pool
    ip_addresses = [azurerm_container_app_environment.ce_apps.static_ip_address]
  }

  backend_http_settings {
    name                  = local.aca_backend_http_setting
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    host_name             = azurerm_container_app_environment.ce_apps.default_domain
  }

  # --- Orchestration Settings

  backend_address_pool {
    name = local.orchestration_backend_pool
    fqdns = [azurerm_container_app.aca_apps["orchestration"].latest_revision_fqdn]
  }

  backend_http_settings {
    name                  = local.orchestration_backend_http_setting
    cookie_based_affinity = "Disabled"
    path = "/orchestration/"
    port            = 80
    protocol        = "Http"
    request_timeout = 60
    host_name       = azurerm_container_app.aca_apps["orchestration"].latest_revision_fqdn
    probe_name      = "orchestration-probe"
  }

  probe {
    host                = azurerm_container_app.aca_apps["orchestration"].latest_revision_fqdn
    name                = "orchestration-probe"
    protocol            = "Http"
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3

    match {
      status_code = ["200"]
    }

  }

  # --- eCR Viewer Settings

  backend_address_pool {
    name = local.ecr_viewer_backend_pool
    fqdns = [azurerm_container_app.aca_apps["ecr-viewer"].latest_revision_fqdn]
  }

  backend_http_settings {
    name                  = local.ecr_viewer_backend_http_setting
    cookie_based_affinity = "Disabled"
    path                  = "/api" //disable to add rewrite rule
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    host_name             = azurerm_container_app.aca_apps["ecr-viewer"].latest_revision_fqdn
    probe_name            = "ecr-viewer-probe"
  }

  probe {
    host                = azurerm_container_app.aca_apps["ecr-viewer"].latest_revision_fqdn
    name                = "ecr-viewer-probe"
    protocol            = "Http"
    path                = "/api"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3

    match {
      status_code = ["200"]
    }

  }

  # ------- Routing -------------------------

  request_routing_rule {
    name                       = "${local.name}-routing-http"
    priority                   = 200
    rule_type                  = "PathBasedRouting"
    http_listener_name         = local.http_listener
    backend_address_pool_name  = local.aca_backend_pool
    backend_http_settings_name = local.aca_backend_http_setting
    url_path_map_name          = "${local.name}-urlmap"
  }

  url_path_map {
    name                               = "${local.name}-urlmap"
    default_backend_address_pool_name  = local.aca_backend_pool
    default_backend_http_settings_name = local.aca_backend_http_setting


    path_rule {
      name                       = "orchestration"
      paths                      = ["/orchestration/*", "/orchestration"]
      backend_address_pool_name  = local.orchestration_backend_pool
      backend_http_settings_name = local.orchestration_backend_http_setting
      // this is the default, why would we set it again?
      // because if we don't do this we get 404s on API calls
      //rewrite_rule_set_name = "orchestration-routing"
    }

    path_rule {
      name                       = "ecr-viewer"
      paths                      = ["/ecr-viewer/*", "/ecr-viewer"]
      backend_address_pool_name  = local.ecr_viewer_backend_pool
      backend_http_settings_name = local.ecr_viewer_backend_http_setting
      // Uncomment below to turn on rewrite functionality, if needed
      //rewrite_rule_set_name = "ecr-viewer-routing"
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
        pattern     = ".*orchestration/(.*)"
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
    name = "ecr-viewer-routing"

    rewrite_rule {
      name          = "ecr-viewer-wildcard"
      rule_sequence = 100
      condition {
        ignore_case = true
        negate      = false
        pattern     = ".*/ecr-viewer(.*)"
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

