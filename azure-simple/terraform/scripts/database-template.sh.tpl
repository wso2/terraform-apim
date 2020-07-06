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

LOG_DIRECTORY='/tmp'

ADMIN_USER='mysqladmin@wso2apimdb'
ADMIN_PASSWORD='${db_admin_password}'
CONNECTION_STRING='${db_connection_strings}'
DB_HOME='/tmp/dbscripts'
USER_PASSWORD="BEstr11ng_#12"

mysql -s  <<EOF  > $LOG_DIRECTORY/query.log -h $CONNECTION_STRING -u mysqladmin@wso2apimdb -p$ADMIN_PASSWORD

CREATE DATABASE shared_db;
CREATE USER shared_user IDENTIFIED BY "$USER_PASSWORD";
GRANT ALL ON shared_db.* TO shared_user@'%' IDENTIFIED BY "$USER_PASSWORD";

CREATE DATABASE apim_db;
CREATE USER apim_user IDENTIFIED BY "$USER_PASSWORD";
GRANT ALL ON apim_db.* TO apim_user@'%' IDENTIFIED BY "$USER_PASSWORD";

FLUSH PRIVILEGES;
EOF

mysql -s  <<EOF  > $LOG_DIRECTORY/query.log -h $CONNECTION_STRING -u shared_user@wso2apimdb -p$USER_PASSWORD

USE shared_db;
SOURCE $DB_HOME/mysql-shared.sql

EOF

mysql -s  <<EOF  > $LOG_DIRECTORY/query.log -h $CONNECTION_STRING -u apim_user@wso2apimdb -p$USER_PASSWORD

USE apim_db;
SOURCE $DB_HOME/mysql-apim.sql

EOF
