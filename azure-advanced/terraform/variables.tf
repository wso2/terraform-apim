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

# Define variables.
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "product" {
  default = "api-manager"
}

variable "product_name" {
  default = "wso2apim"
}

variable "rbdmz" {
  default = "dmz-route-table"
}

variable "resource_group_name" {
  default = "WSO2-installers"
}

variable "location" {
  default = "East US"
}

variable "virtual_network_name" {
  default = "wso2network"
}

variable "virtual_network_address_space" {
  default = ["10.0.0.0/16"]
}

variable "public_subnet_address" {
  type = "map"
  default = {
    public_prefix_01 = "10.0.250.0/24"
  }
}

variable "private_subnet_address" {
  type = "map"
  default = {
    private_prefix_01 = "10.0.1.0/24"
  }
}

variable "db_sku_name" {
  default = "GP_Gen5_2"
}

variable "db_server_version" {
  default = "5.7"
}

variable "loadbalancer_name" {
  default = "apimlb"
}

variable "instance_size" {
  default = "Standard_DS1_v2"
}

variable "instance_disksize" {
  default = "30"
}

variable "apim_baseimage" {
  default = "<AZURE-BASE-IMAGE>"
}

variable "admin_username" {
  default = "centos"
}

variable "admin_password" {
  default = "Password1234!"
}

variable "db_admin_password" {
  default = "H@Sh1CoR3!"
}

variable "apim_nodes" {
  default = 1
}

variable "ports" {
  default = [8280, 9443, 9099, 8099]
}

variable "keymanager_frontend_ports" {
  default = [443]
}

variable "keymanager_backend_ports" {
  default = [9443]
}
