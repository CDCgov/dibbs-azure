output "ecr_viewer_db_server_name" {
  value = azurerm_postgresql_flexible_server.ecr_viewer_db.name
}

output "ecr_viewer_server_id" {
  value = azurerm_postgresql_flexible_server.ecr_viewer_db.id
}

output "ecr_viewer_server_fqdn" {
  value = azurerm_postgresql_flexible_server.ecr_viewer_db.fqdn
}

output "ecr_viewer_db_name" {
  value = azurerm_postgresql_flexible_server_database.ecr_viewer.name
}

output "query_connector_db_server_name" {
  value = azurerm_postgresql_flexible_server.query_connector_db.name
}

output "query_connector_server_id" {
  value = azurerm_postgresql_flexible_server.query_connector_db.id
}

output "query_connector_server_fqdn" {
  value = azurerm_postgresql_flexible_server.query_connector_db.fqdn
}

output "query_connector_db_name" {
  value = azurerm_postgresql_flexible_server_database.query_connector.name
}

output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}