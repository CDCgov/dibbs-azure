/*output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}*/

output "ecr_viewer_admin_app_role_id" {
  value = azuread_application.ecr_viewer.app_role_ids["ecrViewer.Admin"]
}

output "ecr_viewer_unprivilegedread_app_role_id" {
  value = azuread_application.ecr_viewer.app_role_ids["ecrViewer.ReadOnlyUnprivileged"]
}

output "ecr_viewer_privilegedread_app_role_id" {
  value = azuread_application.ecr_viewer.app_role_ids["ecrViewer.ReadOnlyPrivileged"]
}

output "ecr_viewer_service_principal_id" {
  value = azuread_service_principal.ecr_viewer.object_id
}