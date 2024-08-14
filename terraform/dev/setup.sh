export DOCKER_DEFAULT_PLATFORM=linux/amd64

terraform apply -target=module.foundations -target=module.networking
terraform apply -target=module.container_apps