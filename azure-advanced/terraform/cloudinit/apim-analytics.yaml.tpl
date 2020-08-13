#cloud-config

runcmd:
 - sed -i 's|CONNECTION_STRING|${db_connection_strings}|g' /tmp/ansible-apim/dev/group_vars/apim-analytics.yml
 - cd /tmp/ansible-apim && ansible-playbook -i dev/inventory-analytics site.yml
