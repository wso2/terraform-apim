Included Terraform scripts for complete infrastructure automation for API Manager Pattern 2 setup. Azure subscription details are included in `terraform.tfvars`.

Terraform Files
----------------
 
`apim.tf`
    - Included API Manager instances creation including  public load balancers, load-balaner health probes, instance pool and load balaner rules.   
 
`main.tf`
    - Included network infrastructure creation including virtual network, subnets and security gourps for Azure VMs, MySql DB instance and Bastion instance.
    
`apim-keymanager.tf`
    - Included API Key Manager instances creation including  privave/public load-balancer, load-balaner health probe and load-balaner rules.   
 
`apim-analytics`
    - Included API Analytics instances creation including public load-balancer, load-balaner health probes, instance pool and load-balaner rules.   

`datasources.tf`
    - Included relevant terraform scripts of database server and databases creation for API Manager product.
  
`apim-dns.tf`
    - Included Private DNS creation including Key Manager, Gatway private load-balancer names.  
 
`output.tf`
    - Included hosts entries to access the APIM dashboard and Bastion instance address.
    