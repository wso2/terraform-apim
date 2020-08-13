# WSO2 API Management Ansible scripts

This repository contains the Ansible scripts for installing and configuring WSO2 API Management.

## Supported Operating Systems

- Ubuntu 16.04 or higher
- CentOS 7

## Supported Ansible Versions

- Ansible 2.5 or higher

## Directory Structure
```
.
├── dev
│   ├── group_vars
│   │   ├── apim-analytics.yml
│   │   └── apim.yml
│   ├── host_vars
│   │   ├── apim_1.yml
│   │   ├── apim-analytics-dashboard_1.yml
│   │   ├── apim-analytics-worker_1.yml
│   │   ├── apim-gateway_1.yml
│   │   ├── apim-km_1.yml
│   └── inventory
├── docs
│   ├── images
│   │   ├── P-H-2.png
│   ├── Pattern_2.md
├── files
│   ├── lib
│   │   ├── amazon-corretto-8.242.08.1-linux-x64.tar.gz
│   │   ├── mysql-connector-java-5.1.48-bin.jar
│   └── packs
│   ├── system
│   │   └── etc
│   │       ├── security
│   │       │   └── limits.conf
│   │       └── sysctl.conf
│   └── misc
├── issue_template.md
├── LICENSE
├── pull_request_template.md
├── README.md
├── roles
│   ├── apim
│   │   ├── tasks
│   │   └── templates
│   ├── apim-analytics-dashboard
│   │   ├── tasks
│   │   └── templates
│   ├── apim-analytics-worker
│   │   ├── tasks
│   │   └── templates
│   ├── apim-gateway
│   │   ├── tasks
│   │   └── templates
│   ├── apim-km
│   │   ├── tasks
│   │   └── templates
│   └── common
│       └── tasks
├── scripts
│   ├── update.sh
│   └── update_README.md
└── site.yml

```

Packs could be either copied to a local directory, or downloaded from a remote location.

## Copying packs locally

Copy the following files to `files/packs` directory.

1. [WSO2 API Manager 3.1.0 package](https://wso2.com/api-management/install/)
2. [WSO2 API Manager Analytics 3.1.0 package](https://wso2.com/api-management/install/analytics/)
3. [WSO2 API Manager Identity Server as Key Manager 5.10.0 package](https://wso2.com/api-management/install/key-manager/)

Copy the following files to `files/lib` directory.

1. [Amazon Corretto for Linux x64 JDK](https://docs.aws.amazon.com/corretto/latest/corretto-8-ug/downloads-list.html)

Copy the miscellaneous files to `files/misc` directory. To enable file copying,  uncomment the `misc_file_list` in the yaml files under `group_vars` and add the miscellaneous files to the list.

## Downloading from remote location

In **group_vars**, change the values of the following variables in all groups:
1. The value of `pack_location` should be changed from "local" to "remote"
2. The value of `remote_jdk` should be changed to the URL in which the JDK should be downloaded from, and remove it as a comment.
3. The value of `remote_pack` should be changed to the URL in which the package should be downloaded from, and remove it as a comment.

##  WSO2 API Management Ansible scripts for provision 

### 1. Run the existing scripts without customization
The existing Ansible scripts contain the configurations to set-up a distributed WSO2 API Manager pattern 2. The `HOST` placeholder will replaced with the API Manager profiles.
```
[apim]
HOST ansible_host=localhost ansible_user=centos ansible_connection=local
```
If you need to alter the configurations given, please change the parameterized values in the yaml files under `group_vars` and `host_vars`.

### 2. Customize the WSO2 Ansible scripts

The templates that are used by the Ansible scripts are in j2 format in-order to enable parameterization.

The `deployment.toml.j2` file is added under `roles/apim/templates/carbon-home/repository/conf/`, in order to enable customizations. You can add any other customizations to `custom.yml` under tasks of each role as well.

Follow the steps mentioned under `docs` directory to customize/create new Ansible scripts and deploy the recommended patterns.

## Performance Tuning

System configurations can be changed through Ansible to optimize OS level performance. Performance tuning can be enabled by changing `enable_performance_tuning` in `dev/group_vars/apim.yml` to `true`.

System files that will be updated when performance tuning are enabled is available in `files/system`. Update the configuration values according to the requirements of your deployment.

## Previous versions of Ansible

The master branch of this repository contains the latest product version with the latest Ansible version. The Ansible resources for previous Ansible versions can be found in the branches. The following is an example.

#### Ansible resources for API Manager 3.1.0

Branch name: 3.1.x
