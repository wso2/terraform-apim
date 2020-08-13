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

// APIM DNS records for private resources
resource "azurerm_private_dns_zone" "wso2_apim_private_zone" {
  name                = "wso2test.local"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "apim_private_dns_virtual_link" {
  name                  = "apim-private-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.wso2_apim_private_zone.name
  virtual_network_id    = azurerm_virtual_network.wso2_virtual_network.id
}

resource "azurerm_private_dns_a_record" "apim_gateway_private_record" {
  name                = "gateway"
  zone_name           = azurerm_private_dns_zone.wso2_apim_private_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_lb.wso2_gateway_private_lb.private_ip_address]
}

resource "azurerm_private_dns_a_record" "apim_kemanager_cname_resourse" {
  name                = "keymanager"
  zone_name           = azurerm_private_dns_zone.wso2_apim_private_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_lb.wso2_keymanager_private_lb.private_ip_address]
}
