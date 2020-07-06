Included Packer configurations scripts to create the API Manager Azure machine image. Later this builds Packer image is been referred by the Terraform scripts for provision for API Manager 2 node setup.
Azure subscription details are included in "variables.json".


Packer Directories and Files
----------------

- ansible-apim/
    included relevant terraform scripts of database server and databases creation for APIM product.
- scripts/
    included relevant API Manager runtime configurations and clean up scripts
- dbscripts/
    included relevant API Manager database schemas and tables files
- centos-base.json
    contained relavant packer configurations for build the Azure machine image
- Vagrantfile
    contained relavant vagrant configurations for test the Ansible playbook changes in locally


Please follow the documentation [1] for more information.

[1] https://docs.google.com/a/wso2.com/document/d/1imXDoWZHbTAyNVE8uTD6UEsTiUi9h-Yp216HxCbJRzI/edit?usp=sharing

