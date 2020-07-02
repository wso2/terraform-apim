#cloud-config

mounts:
 - [ "//apimstorageshare.file.core.windows.net/apimshare", /mnt/sharedfs, "cifs", "vers=3.0,username=apimstorageshare,password=${storage_access_key},dir_mode=0777,file_mode=0777,serverino", "0", "0"]

runcmd:
 - sed -i 's|CONNECTION_STRING|${db_connection_strings}|g' /tmp/ansible-apim/dev/group_vars/apim.yml
 - cd /tmp/ansible-apim && ansible-playbook -i dev/inventory site.yml
