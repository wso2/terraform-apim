#----------------------------------------------------------------------------
#  Copyright (c) 2020 WSO2, Inc. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#----------------------------------------------------------------------------

// WSO2 Keymanager loadbalacer resources
resource "azurerm_public_ip" "wso2_keymanager_pip" {
  name                = "keymanager-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_lb" "wso2_keymanager_public_lb" {
  name                = "keymanager-public-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "keymanager-pip"
    public_ip_address_id = azurerm_public_ip.wso2_keymanager_pip.id
  }

  tags = var.wso2_tags
}

resource "azurerm_lb" "wso2_keymanager_private_lb" {
  name                = "keymanager-private-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "keymanagerlb-private-fip"
    subnet_id                     = azurerm_subnet.wso2_private_subnet.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
  }

  tags = var.wso2_tags
}

resource "azurerm_lb_backend_address_pool" "wso2_public_keymanager_pool" {
  name                = "keymanager-public-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.wso2_keymanager_public_lb.id
}

resource "azurerm_lb_backend_address_pool" "wso2_private_keymanager_pool" {
  name                = "keymanager-private-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.wso2_keymanager_private_lb.id
}

resource "azurerm_virtual_machine_scale_set" "wso2_keymanager_scaleset" {
  depends_on          = ["azurerm_virtual_machine.wso2_bastion", "azurerm_virtual_machine.wso2_apim_machine", "azurerm_private_dns_zone.wso2_apim_private_zone"]
  name                = "keymanager-scaleset"
  location            = var.location
  resource_group_name = var.resource_group_name
  upgrade_policy_mode = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  health_probe_id = azurerm_lb_probe.wso2_keymanager_public_probe.id

  sku {
    name     = var.instance_size
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    id = var.apim_baseimage
  }

  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name_prefix = "keymanager"
    admin_username       = var.admin_username
    admin_password       = var.admin_password
    custom_data          = base64encode(data.template_file.keymanager_template.rendered)
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = file("./keys/azure-key.pub")
    }
  }

  network_profile {
    name    = "keymanager-nps"
    primary = true

    ip_configuration {
      name                                   = "keymanager-ips"
      subnet_id                              = azurerm_subnet.wso2_private_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.wso2_public_keymanager_pool.id, azurerm_lb_backend_address_pool.wso2_private_keymanager_pool.id]
      primary                                = true
    }
  }

  tags = var.wso2_tags
}

resource "azurerm_lb_probe" "wso2_keymanager_public_probe" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.wso2_keymanager_public_lb.id
  name                = "keymanager-probe"
  protocol            = "tcp"
  port                = "9443"
  interval_in_seconds = "5"
  number_of_probes    = "3"
}

resource "azurerm_lb_rule" "wso2_keymanager_lb_public_rule_9443" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.wso2_keymanager_public_lb.id
  name                           = "keymanager-rule-9443"
  protocol                       = "tcp"
  frontend_port                  = "9443"
  backend_port                   = "9443"
  frontend_ip_configuration_name = "keymanager-pip"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.wso2_public_keymanager_pool.id
  idle_timeout_in_minutes        = 5
  load_distribution              = "SourceIPProtocol"

  probe_id   = azurerm_lb_probe.wso2_keymanager_public_probe.id
  depends_on = [azurerm_lb_probe.wso2_keymanager_public_probe]
}

resource "azurerm_lb_probe" "wso2_keymanager_private_probe" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.wso2_keymanager_private_lb.id
  name                = "keymanager-private-probe"
  protocol            = "tcp"
  port                = "9443"
  interval_in_seconds = "5"
  number_of_probes    = "3"
}

resource "azurerm_lb_rule" "wso2_keymanager_private_lb_rules" {
  count                          = 1
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.wso2_keymanager_private_lb.id
  name                           = "keymanager-private-rule-${count.index + 1}"
  protocol                       = "tcp"
  frontend_port                  = element(var.keymanager_frontend_ports, count.index)
  backend_port                   = element(var.keymanager_backend_ports, count.index)
  frontend_ip_configuration_name = "keymanagerlb-private-fip"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.wso2_private_keymanager_pool.id
  idle_timeout_in_minutes        = 5
  load_distribution              = "SourceIPProtocol"
}
