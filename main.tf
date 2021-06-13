provider "azurerm" {
  version = "=2.36.0"
  features {}
}

resource "azurerm_resource_group" "azure" {
  name     = "terraform-azure"
  location = var.location
  tags = {
    env = "network-security-group"
  }
}