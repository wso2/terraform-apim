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

// API Managerloadbalacer resources
resource "azurerm_public_ip" "wso2_apim_pip" {
  name                = "apim-public-loadlbalancer-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_lb" "wso2_apim_lb" {
  name                = "apim-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "apimlb-fip"
    public_ip_address_id = azurerm_public_ip.wso2_apim_pip.id
  }
  tags = var.wso2_tags
}

resource "azurerm_lb_backend_address_pool" "wso2_apim_pool" {
  name                = "apim-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.wso2_apim_lb.id
}

resource "azurerm_network_interface" "wso2_apim_nic" {
  count               = var.apim_nodes
  name                = "apim-nic-${format("%02d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "apim-pip-${format("%02d", count.index + 1)}"
    subnet_id                     = azurerm_subnet.wso2_private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.wso2_tags
}

resource "azurerm_network_interface_backend_address_pool_association" "wso2_backend_address_pool_association" {
  count                   = var.apim_nodes
  network_interface_id    = azurerm_network_interface.wso2_apim_nic[count.index].id
  ip_configuration_name   = "apim-pip-${format("%02d", count.index + 1)}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.wso2_apim_pool.id
}

resource "azurerm_availability_set" "wso2_apim_availability_set" {
  name                         = "apim-availability-set"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_virtual_machine" "wso2_apim_machine" {
  count                            = var.apim_nodes
  depends_on                       = ["azurerm_virtual_machine.wso2_bastion", "azurerm_mysql_server.wso2_mysql_instance", "azurerm_private_dns_zone.wso2_apim_private_zone"]
  name                             = "apim-${format("%02d", count.index + 1)}"
  location                         = var.location
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [azurerm_network_interface.wso2_apim_nic[count.index].id]
  availability_set_id              = azurerm_availability_set.wso2_apim_availability_set.id
  vm_size                          = var.instance_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = var.apim_baseimage
  }

  storage_os_disk {
    name              = "apim-osdisk"
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
    computer_name  = "apim-${format("%02d", count.index + 1)}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = base64encode(data.template_file.apim_template.rendered)
  }

  tags = var.wso2_tags
}

resource "azurerm_lb_probe" "wso2_apim_probe" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.wso2_apim_lb.id
  name                = "apim-probe"
  protocol            = "tcp"
  port                = "9443"
  interval_in_seconds = "5"
  number_of_probes    = "3"
}

resource "azurerm_lb_rule" "wso2_apim_lb_public_rule_443" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.wso2_apim_lb.id
  name                           = "apim-rule-9443"
  protocol                       = "tcp"
  frontend_port                  = "443"
  backend_port                   = "9443"
  frontend_ip_configuration_name = "apimlb-fip"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.wso2_apim_pool.id
  idle_timeout_in_minutes        = 5
  load_distribution              = "SourceIPProtocol"

  probe_id   = azurerm_lb_probe.wso2_apim_probe.id
  depends_on = [azurerm_lb_probe.wso2_apim_probe]
}
