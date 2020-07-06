
## Installation

### Prerequisites


* Install and set up Packer ( version > v1.4.0 )
* Install and set up Terraform ( version > v0.12.00 )


### Instructions:

1. Download the WSO2 API Manager terraform resource.

2. Build the API manager custom image. 

**Note:**  If you have an Azure subscription, update user variables in ‘centos-base.json’  file using your subscription credentials. The WSO2 API Manager 3.1.0 distribution needs to download into the  ‘ansible-apim/files/packs’ directory. If you do not have a WSO2 subscription account, you can sign up for a free trial here. 

```bash
$ packer build centos-base.json 
```


3. Update the build image-id in terraform ‘variables.tf’ file and ‘terraform.tfvars’ maintains the Azure subscription credentials. 

```bash
$ terraform apply
```  
   
**Note:**  Add the host entry in  ‘/etc/hosts’ file with <PUBLIC-IP> apim.wso2test.com’  to access the  API Manager console. 

4. Try navigating to the following consoles from your favorite browser.

*https://apim.wso2test.com*
