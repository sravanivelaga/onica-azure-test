resource "azurerm_virtual_network" "azure" {
  name                = "${var.prefix}-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.azure.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "azure-internal1" {
  name                 = "${var.prefix}-internal1"
  resource_group_name  = azurerm_resource_group.azure.name
  virtual_network_name = azurerm_virtual_network.azure.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "azure-instance" {
  name                = "${var.prefix}-instance-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.azure.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
