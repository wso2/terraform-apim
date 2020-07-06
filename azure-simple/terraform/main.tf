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

# Configure the Azure Resource Manager Provider
provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  features {}
  tenant_id = var.tenant_id
}

variable "wso2_tags" {
  description = "Two node APIM Manager setup with MySql database backend"
  type        = map

  default = {
    environment = "wso2apim"
  }
}

resource "azurerm_virtual_network" "wso2_virtual_network" {
  name                = var.virtual_network_name
  address_space       = var.virtual_network_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    product = var.product_name
  }
}

resource "azurerm_subnet" "wso2_public_subnet" {
  depends_on           = ["azurerm_virtual_network.wso2_virtual_network"]
  virtual_network_name = var.virtual_network_name
  name                 = "public-subnet"
  address_prefixes     = ["10.0.250.0/24"]
  resource_group_name  = var.resource_group_name
}

resource "azurerm_subnet" "wso2_private_subnet" {
  depends_on           = ["azurerm_virtual_network.wso2_virtual_network"]
  virtual_network_name = var.virtual_network_name
  name                 = "private-subnet"
  address_prefixes     = ["10.0.1.0/24"]
  resource_group_name  = var.resource_group_name
}


resource "azurerm_network_security_group" "wso2_bastion_nsg" {
  name                = "bastion-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-ssh-traffic"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

}

resource "azurerm_route_table" "wso2_routetb" {
  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name           = "External"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  route {
    name           = "Local"
    address_prefix = "10.0.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  tags = {
    product = var.product_name
  }
}

// Bastion server resources

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  number  = false
}

resource "azurerm_public_ip" "wso2_bastion_pip" {
  name                = "bastion-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = "${random_string.fqdn.result}-ssh"
  tags                = var.wso2_tags
}

resource "azurerm_network_interface" "wso2_bastion_nic" {
  name                = "bastion-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "bastion-pip"
    subnet_id                     = azurerm_subnet.wso2_public_subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.wso2_bastion_pip.id
  }

  tags = var.wso2_tags
}

// MySql server resources

resource "azurerm_mysql_server" "wso2_mysql_instance" {
  name                = "wso2apimdb"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "B_Gen5_2"

  administrator_login          = "mysqladmin"
  administrator_login_password = var.db_admin_password
  version                      = var.db_server_version
  storage_mb                   = "10240"
  ssl_enforcement_enabled      = false
}

resource "azurerm_mysql_firewall_rule" "wso2_mysql_firewall_rule" {
  depends_on          = ["azurerm_mysql_server.wso2_mysql_instance"]
  name                = "local-connection-rule"
  resource_group_name = var.resource_group_name
  server_name         = "wso2apimdb"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

// Bastion instance resources
resource "azurerm_virtual_machine" "wso2_bastion" {
  depends_on                       = ["azurerm_mysql_server.wso2_mysql_instance"]
  name                             = "bastion"
  location                         = var.location
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [azurerm_network_interface.wso2_bastion_nic.id]
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true


  storage_image_reference {
    id = var.baseimage
  }

  storage_os_disk {
    name              = "bastion-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "wso2-bastion"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = base64encode(data.template_file.bastion_tempalte_script.rendered)

  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.wso2_tags
}

// Shared storage resources
resource "azurerm_storage_account" "wso2_storage_account" {
  name                     = "apimstorageshare"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.wso2_tags

}

resource "azurerm_storage_share" "wso2_storage_share" {
  name                 = "apimshare"
  storage_account_name = azurerm_storage_account.wso2_storage_account.name
  quota                = 20
}

// APIM loadbalacer resources

resource "azurerm_public_ip" "wso2_loadbalacer_pip" {
  depends_on          = ["azurerm_virtual_machine_scale_set.wso2_scale_set"]
  name                = "wso2apim-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_lb" "wso2_lb" {
  name                = var.loadbalancer_name
  location            = var.location
  resource_group_name = var.resource_group_name


  frontend_ip_configuration {
    name                 = "apimlb-fip"
    public_ip_address_id = azurerm_public_ip.wso2_loadbalacer_pip.id
  }

  tags = var.wso2_tags

}

resource "azurerm_lb_backend_address_pool" "wso2_address_pool" {
  name                = "apimlb-instance-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.wso2_lb.id
}

resource "azurerm_virtual_machine_scale_set" "wso2_scale_set" {
  depends_on          = ["azurerm_virtual_machine.wso2_bastion", "azurerm_storage_share.wso2_storage_share", "azurerm_lb.wso2_lb"]
  name                = "apim-scaleset"
  location            = var.location
  resource_group_name = var.resource_group_name
  upgrade_policy_mode = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  health_probe_id = azurerm_lb_probe.wso2_lb_probe.id

  sku {
    name     = var.instance_size
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    id = var.baseimage
  }


  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name_prefix = "apim"
    admin_username       = var.admin_username
    admin_password       = var.admin_password
    custom_data          = base64encode(data.template_file.compute_template_script.rendered)
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = file("./keys/azure-key.pub")
    }
  }

  network_profile {
    name    = "apim-scaleset-nps"
    primary = true

    ip_configuration {
      name                                   = "apim-scaleset-ips"
      subnet_id                              = azurerm_subnet.wso2_private_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.wso2_address_pool.id]
      primary                                = true
    }
  }

  tags = var.wso2_tags
}

resource "azurerm_lb_probe" "wso2_lb_probe" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.wso2_lb.id
  name                = "https-probe"
  protocol            = "tcp"
  port                = "9443"
  interval_in_seconds = "5"
  number_of_probes    = "3"
}

resource "azurerm_lb_rule" "wso2_lb_portal_rule" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.wso2_lb.id
  name                           = "portal-rule"
  protocol                       = "tcp"
  frontend_port                  = "9443"
  backend_port                   = "9443"
  frontend_ip_configuration_name = "apimlb-fip"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.wso2_address_pool.id
  idle_timeout_in_minutes        = 5
  load_distribution              = "SourceIPProtocol"

  probe_id   = azurerm_lb_probe.wso2_lb_probe.id
  depends_on = [azurerm_lb_probe.wso2_lb_probe]
}

resource "azurerm_lb_rule" "wso2_lb_gateway_rule" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.wso2_lb.id
  name                           = "gateway-rule"
  protocol                       = "tcp"
  frontend_port                  = "8243"
  backend_port                   = "8243"
  frontend_ip_configuration_name = "apimlb-fip"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.wso2_address_pool.id
  idle_timeout_in_minutes        = 5
  load_distribution              = "SourceIPProtocol"
}
