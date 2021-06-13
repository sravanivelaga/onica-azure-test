output "load_balancer_ip" {
  value = "${azurerm_public_ip.azure.fqdn}"
}
