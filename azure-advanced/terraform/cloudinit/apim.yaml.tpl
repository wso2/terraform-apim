#cloud-config

runcmd:
 - sed -i 's|CONNECTION_STRING|${db_connection_strings}|g' /tmp/ansible-apim/dev/group_vars/apim.yml
 - sed -i 's|HOST|apim_1|g' /tmp/ansible-apim/dev/inventory-apim
 - cd /tmp/ansible-apim && ansible-playbook -i dev/inventory-apim site.yml
