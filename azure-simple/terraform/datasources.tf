data "template_file" "bastion_tempalte_script" {
  template = file("scripts/database-template.sh.tpl")

  vars = {
    db_admin_password     = var.db_admin_password
    db_connection_strings = azurerm_mysql_server.wso2_mysql_instance.fqdn
  }

}

data "template_file" "compute_template_script" {
  template = file("cloudinit/compute-template.yaml.tpl")

  vars = {
    db_connection_strings = azurerm_mysql_server.wso2_mysql_instance.fqdn
    storage_access_key    = azurerm_storage_account.wso2_storage_account.primary_access_key
  }

}


