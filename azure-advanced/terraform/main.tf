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
  description = "APIM distributes setup with backend mysql database"
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
  address_prefixes     = [var.public_subnet_address.public_prefix_01]
  resource_group_name  = var.resource_group_name
}

resource "azurerm_subnet" "wso2_private_subnet" {
  depends_on           = ["azurerm_virtual_network.wso2_virtual_network"]
  virtual_network_name = var.virtual_network_name
  name                 = "private-subnet"
  address_prefixes     = [var.private_subnet_address.private_prefix_01]
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
  name                = var.rbdmz
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

  sku_name = var.db_sku_name

  administrator_login          = "mysqladmin"
  administrator_login_password = var.db_admin_password
  version                      = var.db_server_version
  storage_mb                   = "102400"
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
  vm_size                          = var.instance_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true


  storage_image_reference {
    id = var.apim_baseimage
  }

  storage_os_disk {
    name              = "bastion-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "bastion"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = base64encode(data.template_file.bastion_tempalte_script.rendered)

  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.wso2_tags
}

// Shared storage resources for Gateway
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
