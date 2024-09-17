terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  # Note: Terraform will automatically communicate with the local 
  # Docker daemon using the default Unix socket. Change this only if your
  # worker machine or deployment agent runs docker in another location. 
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address  = var.acr_url
    username = var.acr_username
    password = var.acr_password
  }
}