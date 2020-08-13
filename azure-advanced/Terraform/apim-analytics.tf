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

// APIM Anaylicts loadbalacer resources
resource "azurerm_public_ip" "wso2_analytics_pip" {
  name                = "analytics-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_lb" "wso2_analytics_lb" {
  name                = "analytics-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "analyticslb-fip"
    public_ip_address_id = azurerm_public_ip.wso2_analytics_pip.id
  }
  tags = var.wso2_tags
}

resource "azurerm_lb_backend_address_pool" "wso2_analytics_pool" {
  name                = "analytics-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.wso2_analytics_lb.id
}

resource "azurerm_network_interface" "wso2_analytics_nic" {
  name                    = "analytics-nic"
  location                = var.location
  resource_group_name     = var.resource_group_name
  internal_dns_name_label = "analytics-nic"

  ip_configuration {
    name                          = "analytics-pip"
    subnet_id                     = azurerm_subnet.wso2_private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.wso2_tags
}

resource "azurerm_network_interface_backend_address_pool_association" "wso2_analytics_backend_address_pool_association" {
  network_interface_id    = azurerm_network_interface.wso2_analytics_nic.id
  ip_configuration_name   = "analytics-pip"
  backend_address_pool_id = azurerm_lb_backend_address_pool.wso2_analytics_pool.id
}

resource "azurerm_availability_set" "wso2_analytics_availability_set" {
  name                         = "analytics-availability-set"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_virtual_machine" "wso2_analytics_machine" {
  depends_on                       = ["azurerm_virtual_machine.wso2_bastion", "azurerm_virtual_machine.wso2_apim_machine", "azurerm_private_dns_zone.wso2_apim_private_zone"]
  count                            = 1
  name                             = "analytics-${format("%02d", count.index + 1)}"
  location                         = var.location
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [azurerm_network_interface.wso2_analytics_nic.id]
  availability_set_id              = azurerm_availability_set.wso2_analytics_availability_set.id
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = var.apim_baseimage
  }

  storage_os_disk {
    name              = "analytics-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = file("./keys/azure-key.pub")
    }
  }

  os_profile {
    computer_name  = "analytics-${format("%02d", count.index + 1)}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = base64encode(data.template_file.analytics_template.rendered)
  }

  tags = var.wso2_tags
}

resource "azurerm_lb_probe" "wso2_analytics_probe" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.wso2_analytics_lb.id
  name                = "analytics-probe"
  protocol            = "tcp"
  port                = "9646"
  interval_in_seconds = "5"
  number_of_probes    = "3"
}

resource "azurerm_lb_rule" "wso2_analytics_lb_public_rule_443" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.wso2_analytics_lb.id
  name                           = "analytics-rule-9646"
  protocol                       = "tcp"
  frontend_port                  = "443"
  backend_port                   = "9646"
  frontend_ip_configuration_name = "analyticslb-fip"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.wso2_analytics_pool.id
  idle_timeout_in_minutes        = 5
  load_distribution              = "SourceIPProtocol"

  probe_id   = azurerm_lb_probe.wso2_analytics_probe.id
  depends_on = [azurerm_lb_probe.wso2_analytics_probe]
}
