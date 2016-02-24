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

cd /root/cloudstack
/etc/vmware-tools/services.sh restart

if [ $c = "unknown" ]; then
        usage
elif [ $c = "reset" ]; then
	killall java
	#clean primary store
	rm -rf /exports/prim1/*
	rm -rf /exports/prim2/*
	rm -rf /exports/sec1/snapshots
	rm -rf /exports/sec1/volumes
	rm -rf /exports/sec2/snapshots
	rm -rf /exports/sec2/volumes
	sleep 5
	mvn -P developer -pl developer -Ddeploydb
	nohup mvn -pl :cloud-client-ui jetty:run 2>&1 > /dev/null &

	sleep 60
	killall java
	sleep 10

	mysql -h localhost cloud -u cloud --password=cloud < /root/cloudstack_utils/virtual_box.sql

elif [ $c = "run" ]; then
	killall java
	sleep 5
	mvn -pl :cloud-client-ui jetty:run
elif [ $c = "build" ]; then
	killall java
	sleep 5
	mvn clean install -P developer,systemvm -DskipTests=true
	mvn -pl :cloud-client-ui jetty:run
elif [ $c = "setup" ]; then
	killall java
	#clean primary store
	rm -rf /exports/prim1/*
	rm -rf /exports/prim2/*
	rm -rf /exports/sec1/snapshots
	rm -rf /exports/sec1/volumes
	rm -rf /exports/sec2/snapshots
	rm -rf /exports/sec2/volumes

	#nohup ./client/target/generated-webapp/WEB-INF/classes/scripts/storage/secondary/cloud-install-sys-tmplt -m /exports/sec1 -u http://packages.shapeblue.com/systemvmtemplate/4.5/systemvm64template-4.5-xen.vhd.bz2 -h xenserver -F &

	mvn clean install -P developer,systemvm -DskipTests=true

	mvn -P developer -pl developer -Ddeploydb

	nohup mvn -pl :cloud-client-ui jetty:run 2>&1 > /dev/null &

	sleep 60
	killall java
	sleep 10

	mysql -h localhost cloud -u cloud --password=cloud < /root/cloudstack_utils/virtual_box.sql

	mvn -pl :cloud-client-ui jetty:run 

fi
