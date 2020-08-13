#!/usr/bin/env bash
#----------------------------------------------------------------------------
#  Copyright (c) 2020 WSO2, Inc. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#----------------------------------------------------------------------------

set -e

yum update -y
yum install -y epel-release
yum install -y -q cloud-init ansible nfs-utils ccze mysql ccze tree

#Download wso2 GA packages
wget https://github.com/wso2/product-apim/releases/download/v3.1.0/wso2am-3.1.0.zip -P /tmp/ansible-apim/files/packs
wget https://github.com/wso2/product-apim/releases/download/v3.1.0/wso2am-analytics-3.1.0.zip -P  /tmp/ansible-apim/files/packs

#Create sharedfs directory
mkdir -p /mnt/sharedfs

systemctl stop firewalld.service
systemctl disable firewalld.service
sed -i 's/enforcing/disabled/g' /etc/selinux/config

