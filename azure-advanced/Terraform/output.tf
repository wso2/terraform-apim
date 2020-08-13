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

output README {
  value = "Please add listed host entries to '/etc/hosts' file to access the WSO2 APIM portal. \n\n ${azurerm_public_ip.wso2_bastion_pip.ip_address} bastion.wso2test.com \n ${azurerm_public_ip.wso2_apim_pip.ip_address} apim.wso2test.com \n ${azurerm_public_ip.wso2_gateway_pip.ip_address} gateway.wso2test.com \n ${azurerm_public_ip.wso2_analytics_pip.ip_address} analytics.wso2test.com \n\n * Use the listed url for access the api console urls \n\n https://apim.wso2test.com \n https://analytics.wso2test.com/analytics-dashboard \n"
}

