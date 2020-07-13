Included Terraform scripts for complete infrastructure automation for API Manager node setup. Azure subscription details are included in `terraform.tfvars`.

Terraform Files
----------------
`datasources.tf`
    included relevant terraform scripts of database server and databases creation for API Manager product.
    
`main.tf`
    included network infrastructure creation including virtual network, subnets and security gourps for Azure VMs and Application Gateway with scalesets, storage accounts and storage containers for the VM scalesets.
    
`output.tf`
    included loab-balancer Public ip address to be needed to configure as host entry for access the API Manager web console. 