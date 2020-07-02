output "README" {
  value = "Please add this '${azurerm_public_ip.wso2_loadbalacer_pip.ip_address} apim.wso2test.com' to '/etc/hosts' file for access the WSO2 APIM portal."
}

