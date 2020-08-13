Included Packer configurations scripts to create the API Manager Azure machine image. Later this builds Packer image is been referred by the Terraform scripts for provision for API Manager pattern 2 setup.
Azure subscription details are included in "variables.json".

Packer Directories and Files
----------------
`ansible-apim/` -
    Included relevant terraform scripts of database server and databases creation for APIM product.

`scripts/` -
    Included relevant API Manager runtime configurations and clean up scripts.

`dbscripts/` -
    Included relevant API Manager database schemas and tables files.

`centos-base.json` -
    Included relevant packer configurations for build the Azure machine image.

`Vagrantfile` -
    Included relevant vagrant configurations for test the Ansible playbook changes in locally.
