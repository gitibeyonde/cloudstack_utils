#!/bin/bash

set -x

cd /imports/4.5

#nohup ./client/target/generated-webapp/WEB-INF/classes/scripts/storage/secondary/cloud-install-sys-tmplt -m /exports/sec1 -u http://packages.shapeblue.com/systemvmtemplate/4.5/systemvm64template-4.5-xen.vhd.bz2 -h xenserver -F &

mvn clean install -P developer,systemvm -o -DskipTests=true

mvn -P developer -pl developer -Ddeploydb

mysql -h localhost cloud -u cloud --password=cloud < virtual_box.sql

mvn -pl :cloud-client-ui jetty:run