#!/bin/bash

set -x

set -x

usage() { echo "Usage: $0 [ -c <setup|build> -v <cloudstack branch> ]" 1>&2; exit 1; }

c=unknown
n=unknown
while getopts ":c:v:" o; do
        case "${o}" in
                c)
                        c=${OPTARG}
                        ;;
                v)
                        v=${OPTARG}
                        ;;
                *)
                        usage
                        ;;
        esac
done

if [ $c = "unknown" ]; then
        usage
elif [ $c = "run" ]; then
	killall java
	mvn -pl :cloud-client-ui jetty:run
elif [ $c = "build" ]; then
	killall java
	mvn clean install -P developer,systemvm -o -DskipTests=true
	mvn -pl :cloud-client-ui jetty:run
elif [ $c = "setup" ]; then
	killall java
	cd /imports/4.5

	#nohup ./client/target/generated-webapp/WEB-INF/classes/scripts/storage/secondary/cloud-install-sys-tmplt -m /exports/sec1 -u http://packages.shapeblue.com/systemvmtemplate/4.5/systemvm64template-4.5-xen.vhd.bz2 -h xenserver -F &

	mvn clean install -P developer,systemvm -o -DskipTests=true

	mvn -P developer -pl developer -Ddeploydb

	mysql -h localhost cloud -u cloud --password=cloud < virtual_box.sql

	mvn -pl :cloud-client-ui jetty:run
fi
