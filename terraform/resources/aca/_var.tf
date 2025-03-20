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
  default     = "ghcr.io/cdcgov/dibbs-ecr-viewer/"
}

variable "azure_storage_connection_string" {
  description = "The connection string for the Azure Storage account for eCR processing"
  type        = string
}

variable "azure_container_name" {
  description = "The name of the Azure Storage container for eCR processing"
  type        = string
}

variable "nbs_public_key" {
  description = "Public key to use for managing connections to NBS"
  type        = string
  default     = ""
}

variable "nextauth_url" {
  description = "The URL for the auth service"
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the key vault to use for secrets"
  type        = string
}

variable "ecr_viewer_db_fqdn" {
  description = "The fully qualified domain name of the database server"
  type        = string
}

variable "use_ssl" {
  description = "Boolean to determine if SSL should be used for the eCR Viewer resources. Required for Entra/Azure Active Directory use."
  type        = bool
  default     = false
}

variable "user_assigned_identity_id" {
  description = "The ID of the user-assigned managed identity to use for the ACA environment"
  type        = string
  default     = ""
}