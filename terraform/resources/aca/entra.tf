locals {
  ecr_viewer_base_address = "http://${azurerm_public_ip.aca_ingress.fqdn}/ecr_viewer"
}

resource "random_uuid" "ecr_viewer_unprivileged_read_scope_id" {}
resource "random_uuid" "ecr_viewer_privileged_read_scope_id" {}
resource "random_uuid" "ecr_viewer_privileged_write_scope_id" {}
resource "random_uuid" "ecr_viewer_admin_app_role_id" {}
resource "random_uuid" "ecr_viewer_unprivileged_reader_app_role_id" {}
resource "random_uuid" "ecr_viewer_privileged_reader_app_role_id" {}

resource "azuread_application" "ecr_viewer" {
  display_name     = "DIBBs eCR Viewer"
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allows access to read all unprivileged records"
      admin_consent_display_name = "unprivileged.read"
      enabled                    = true
      id                         = random_uuid.ecr_viewer_unprivileged_read_scope_id.result
      type                       = "Admin"
      user_consent_description   = "Allows access to read all unprivileged records"
      user_consent_display_name  = "unprivileged.read"
      value                      = "unprivileged.read"
    }

    oauth2_permission_scope {
      admin_consent_description  = "Allows access to read all privileged records"
      admin_consent_display_name = "unprivileged.read"
      enabled                    = true
      id                         = random_uuid.ecr_viewer_privileged_read_scope_id.result
      type                       = "Admin"
      user_consent_description   = "Allows access to read all privileged records"
      user_consent_display_name  = "privileged.read"
      value                      = "privileged.read"
    }

    oauth2_permission_scope {
      admin_consent_description  = "Allows write access to records"
      admin_consent_display_name = "privileged.write"
      enabled                    = true
      id                         = random_uuid.ecr_viewer_privileged_write_scope_id.result
      type                       = "User"
      user_consent_description   = "Allows write access to records"
      user_consent_display_name  = "privileged.write"
      value                      = "privileged.write"
    }
  }

  app_role {
    allowed_member_types = ["User", "Application"]
    description          = "Admins can manage roles and perform all task actions"
    display_name         = "Admin"
    enabled              = true
    id                   = random_uuid.ecr_viewer_admin_app_role_id.result
    value                = "ecrViewer.Admin"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Unprivileged ReadOnly roles can only read unprivileged records"
    display_name         = "Unprivileged ReadOnly"
    enabled              = true
    id                   = random_uuid.ecr_viewer_unprivileged_reader_app_role_id.result
    value                = "ecrViewer.ReadOnlyUnprivileged"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Privileged ReadOnly roles can read privileged records"
    display_name         = "Privileged ReadOnly"
    enabled              = true
    id                   = random_uuid.ecr_viewer_privileged_reader_app_role_id.result
    value                = "ecrViewer.ReadOnlyPrivileged"
  }

  web {
    homepage_url  = local.ecr_viewer_base_address
    logout_url    = "${local.ecr_viewer_base_address}/logout"
    redirect_uris = ["${local.ecr_viewer_base_address}/process_zip"]
  }
}

resource "azuread_service_principal" "ecr_viewer" {
  client_id = azuread_application.ecr_viewer.client_id
}

/*
resource "azuread_app_role_assignment" "ecr_viewer_admin" {
  app_role_id = azuread_service_principal.ecr_viewer.app_role_ids[ecrViewer.Admin]
  resource_object_id = azuread_application.ecr_viewer.object_id
  principal_object_id
}
*/