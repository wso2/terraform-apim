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

# Remove Linux headers
yum -y remove gcc kernel-devel kernel-headers perl cpp
yum -y clean all

# Cleanup log files
find /var/log -type f | while read f; do echo -ne '' > $f; done;

# remove under tmp directory
#rm -rf /tmp/*
