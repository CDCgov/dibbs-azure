locals {
  name = "${var.team}-${var.project}-${var.env}"

  domain_name = data.azuread_domains.default.domains.0.domain_name
}

# Create test users
resource "azuread_user" "ecr_viewer_admin_user" {
  display_name        = "DIBBs eCR Viewer Admin User"
  user_principal_name = "${var.team}-${var.project}-${var.env}-ecr-viewer-admin@${local.domain_name}"
  mail_nickname       = "ecr-viewer-admin"
  password            = "P@ssw0rd"
}

resource "azuread_user" "ecr_viewer_privileged_readonly_user" {
  display_name        = "DIBBs eCR Viewer Privileged Read-only User"
  user_principal_name = "${var.team}-${var.project}-${var.env}-ecr-viewer-privilegedreadonly@${local.domain_name}"
  mail_nickname       = "ecr-viewer-privilegedreadonly"
  password            = "P@ssw0rd"
}

resource "azuread_user" "ecr_viewer_unprivileged_readonly_user" {
  display_name        = "DIBBs eCR Viewer Unprivileged Read-only User"
  user_principal_name = "${var.team}-${var.project}-${var.env}-ecr-viewer-unprivilegedreadonly@${local.domain_name}"
  mail_nickname       = "ecr-viewer-unprivilegedreadonly"
  password            = "P@ssw0rd"
}

# Assign roles to test users
resource "azuread_app_role_assignment" "ecr_viewer_admin_app_role_assignment" {
  app_role_id         = var.ecr_viewer_admin_app_role_id
  principal_object_id = azuread_user.ecr_viewer_admin_user.id
  resource_object_id  = var.ecr_viewer_service_principal_id
}

resource "azuread_app_role_assignment" "ecr_viewer_privileged_readonly_app_role_assignment" {
  app_role_id         = var.ecr_viewer_privilegedread_app_role_id
  principal_object_id = azuread_user.ecr_viewer_privileged_readonly_user.id
  resource_object_id  = var.ecr_viewer_service_principal_id
}

resource "azuread_app_role_assignment" "ecr_viewer_unprivileged_readonly_app_role_assignment" {
  app_role_id         = var.ecr_viewer_unprivilegedread_app_role_id
  principal_object_id = azuread_user.ecr_viewer_unprivileged_readonly_user.id
  resource_object_id  = var.ecr_viewer_service_principal_id
}