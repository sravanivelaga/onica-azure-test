resource "azurerm_monitor_autoscale_setting" "example" {
  name                = "${var.prefix}-autoscaling"
  location            = var.location
  resource_group_name = azurerm_resource_group.azure.name
  target_resource_id  = azurerm_virtual_machine_scale_set.azure.id

  profile {
    name = "${var.prefix}-profile"
    capacity {
      default = 2
      minimum = 2
      maximum = 4
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.azure.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 40
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.azure.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 10
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}

resource "azurerm_virtual_machine_scale_set" "azure" {
  name                = "${var.prefix}-scaleset1"
  location            = var.location
  resource_group_name = azurerm_resource_group.azure.name

  # automatic rolling upgrade
  automatic_os_upgrade = true
  upgrade_policy_mode  = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  # required when using rolling upgrade policy
  # health_probe_id = azurerm_lb_probe.azure.id

  zones = var.zones

  sku {
    name     = "Standard_A1_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "azure-instance"
    admin_username       = "onicaadmin"
    admin_password       = var.password
    custom_data = <<-EOF
      #!/bin/bash
      echo "Response from: $HOSTNAME" > index.html
      nohup busybox httpd -f -p 80 &
      EOF
  }

  network_profile {
    name                      = "${var.prefix}-network-profile"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.azure-instance.id

    ip_configuration {
      name                                   = "instance1"
      primary                                = true
      subnet_id                              = azurerm_subnet.azure-internal1.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]
    }
  }
}
