locals {
  tags = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "azure-microservices-demo"
  }
}
