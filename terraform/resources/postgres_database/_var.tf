variable "team" {
  description = "One-word identifier for this project's custodial team."
  type        = string
}

variable "project" {
  description = "One-word identifier or code name for this project."
  type        = string
}

variable "env" {
  description = "One-word identifier for the target environment (e.g. dev, test, prod)."
  type        = string
}

variable "location" {
  description = "The Azure region in which the associated resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy to"
  type        = string
}

variable "db_vnet_id" {
  description = "The ID of the VNet in which to deploy the database servers"
  type        = string
}

variable "aca_subnet_id" {
  description = "The ID of the subnet in which the Azure Container Apps environment is deployed"
  type        = string
}

variable "appgw_subnet_id" {
  description = "The ID of the subnet in which the App Gateway is deployed"
  type        = string
}

variable "db_subnet_id" {
  description = "The ID of the subnet in which to deploy the database servers"
  type        = string
}

variable "ecr_viewer_db_name" {
  type        = string
  description = "Name of RDS Instance"
  default     = "ecr-viewer-db"
}

variable "ecr_viewer_db_username" {
  type        = string
  description = "Username of RDS Instance"
  default     = "ecrViewerDbUser"
}

variable "query_connector_db_name" {
  type        = string
  description = "Name of RDS Instance"
  default     = "query-connector-db"
}

variable "query_connector_db_username" {
  type        = string
  description = "Username of RDS Instance"
  default     = "queryConnectorDbUser"
}

variable "key_permissions" {
  type        = list(string)
  description = "List of key permissions."
  default     = ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]
}

variable "secret_permissions" {
  type        = list(string)
  description = "List of secret permissions."
  default     = ["Set", "Get", "List"]
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault from which to retrieve the database credentials."
}