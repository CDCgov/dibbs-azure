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

variable "aca_subnet_id" {
  type        = string
  description = "The ID of the subnet to connect the Azure Container Apps environment to"
}

variable "appgw_subnet_id" {
  type        = string
  description = "The ID of the subnet to connect the App Gateway to"
}

variable "acr_url" {
  description = "The URL of the Azure Container Registry"
  type        = string
}

variable "acr_username" {
  description = "The username for the Azure Container Registry"
  type        = string
}

variable "acr_password" {
  description = "The password for the Azure Container Registry"
  type        = string
}

variable "vnet_id" {
  description = "The name of the virtual network to which the ACA gateway will be assigned"
  type        = string
}

variable "autoscale_min" {
  description = "Value for the minimum number of load balancer instances to run."
  default     = 0
}
variable "autoscale_max" {
  description = "Value for the maximum number of load balancer instances to run."
  default     = 4
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "dibbs_version" {
  description = "The version of the DIBBs services to deploy. Can be overridden if building blocks are on different versions."
  type        = string
}

variable "ghcr_string" {
  description = "The string to use for the source GitHub Container Registry"
  type        = string
  default     = "ghcr.io/cdcgov/phdi/"
}

variable "azure_storage_connection_string" {
  description = "The connection string for the Azure Storage account for eCR processing"
  type        = string
}

variable "azure_container_name" {
  description = "The name of the Azure Storage container for eCR processing"
  type        = string
}

variable "query_connector_version" {
  description = "The version of the Query Connector to deploy."
  type        = string
}

variable "dibbs_site_version" {
  description = "The version of the DIBBs public information site to deploy."
  type        = string
}

variable "query_connector_ghcr_string" {
  description = "The string to use for the source GitHub Container Registry for images needed to construct the Query Connector pipeline"
  type        = string
  default     = "ghcr.io/cdcgov/dibbs-query-connector/"
}

variable "dibbs_site_ghcr_string" {
  description = "The string to use for the source GitHub Container Registry for images needed to construct the DIBBs public information site pipeline"
  type        = string
  default     = "ghcr.io/cdcgov/dibbs-site"
}

variable "query_connector_container_name" {
  description = "The name of the Query Connector container to use in sourcing docker images and constructing Container App assets"
  type        = string
  default     = "query-connector"
}

variable "dibbs_site_container_name" {
  description = "The name of the DIBBs site container to use in sourcing docker images and constructing Container App assets"
  type        = string
  default     = "dibbs-site"
}

variable "ecr_viewer_db_fqdn" {
  description = "The fully qualified domain name of the eCR Viewer database"
  type        = string
}

variable "query_connector_db_fqdn" {
  description = "The fully qualified domain name of the Query Connector database"
  type        = string
}

variable "ecr_viewer_db_name" {
  description = "The name of the eCR Viewer database"
  type        = string
}

variable "query_connector_db_name" {
  description = "The name of the Query Connector database"
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the key vault from which to retrieve the database credentials"
  type        = string
}

variable "ecr_viewer_db_port" {
  type        = number
  description = "Port for the eCR Viewer RDS Instance"
  default     = 5432
}

variable "query_connector_db_port" {
  type        = number
  description = "Port for the Query Connector RDS Instance"
  default     = 5432
}