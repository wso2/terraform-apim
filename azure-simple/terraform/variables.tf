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

variable "route_table_name" {
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

variable "subnet_address_space_mapping" {
  type = "map"
  default = {
    public_prefix_01 = "10.0.0.0/24"
    public_prefix_02 = "10.0.1.0/24"
  }
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

variable "baseimage" {
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

