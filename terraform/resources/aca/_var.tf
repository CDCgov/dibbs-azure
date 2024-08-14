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

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault to use for secrets management"
}

variable "aca_subnet_id" {
  type        = string
  description = "The ID of the subnet to connect the Azure Container Apps environment to"
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

variable "vnet_name" {
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

#-- Networking --#
variable "orchestration_ip_addresses" {
  type    = list(string)
  default = []
}

variable "ecr_viewer_ip_addresses" {
  type    = list(string)
  default = []
}

#--- Azure API Management ---#
variable "activate_apim" {
  description = "Flag to determine if Azure API Management should be provisioned"
  type        = bool
  default     = false
}
variable "apim_sku_name" {
  description = "The SKU of the API Management instance"
  type        = string
  default     = "Consumption_0"
}

variable "publisher_name" {
  description = "The name of the publisher for the API Management instance"
  type        = string
}

variable "publisher_email" {
  description = "The email address of the publisher for the API Management instance"
  type        = string
}

variable "dibbs_version" {
  description = "The version of the DIBBs services to deploy. Can be overridden if building blocks are on different versions."
  type        = string
}

variable "ghcr_string" {
  description = "The string to use for the source GitHub Container Registry"
  type        = string
  default = "ghcr.io/cdcgov/phdi/"
}

/*variable "service_data" {
  type = map(object({
    name    = string
    cpu     = number
    memory  = string
    image   = string
    is_public = bool
    path_rule = object({
      name                       = string
      paths                      = list(string)
      backend_address_pool_name  = string
      backend_http_settings_name = string
      rewrite_rule_set_name      = string
    })
  }))
  description = "Data for the DIBBs services to be deployed in the Azure Container Apps environment"
} */