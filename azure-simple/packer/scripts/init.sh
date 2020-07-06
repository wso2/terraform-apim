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

#Update the Centos 7 image
yum update -y
yum install -y -q epel-release cloud-init ansible nfs-utils ccze mysql

#Create synapse-configs shared directory
mkdir -p /mnt/sharedfs

#Disable the Firewall Daemon
systemctl stop firewalld.service
systemctl disable firewalld.service

#Disable the Selinux Security
sed -i 's/enforcing/disabled/g' /etc/selinux/config
