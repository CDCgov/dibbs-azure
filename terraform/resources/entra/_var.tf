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

variable "ecr_viewer_admin_app_role_id" {
  description = "The ID of the ECR Viewer Admin App Role"
  type        = string
}

variable "ecr_viewer_privilegedread_app_role_id" {
  description = "The ID of the ECR Viewer Privileged Read-only App Role"
  type        = string
}

variable "ecr_viewer_unprivilegedread_app_role_id" {
  description = "The ID of the ECR Viewer Unprivileged Read-only App Role"
  type        = string
}

variable "ecr_viewer_service_principal_id" {
  description = "The ID of the ECR Viewer Service Principal"
  type        = string
}