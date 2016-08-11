#!/bin/sh


set -x

echo $1 $2 $3



if [ "$1" == "4.5" ]; then
  if [ "$2" == "xen" ]; then 
    $3/client/target/generated-webapp/WEB-INF/classes/scripts/storage/secondary/cloud-install-sys-tmplt -m /exports/sec1 -u http://192.168.217.11/systemvm64template-4.5-xen.vhd.bz2 -h xenserver -F &
  elif [ "$2" == "kvm" ]; then
    $3/client/target/generated-webapp/WEB-INF/classes/scripts/storage/secondary/cloud-install-sys-tmplt -m /exports/sec1 -u http://192.168.217.11/systemvm64template-4.5-kvm.qcow2.bz2 -h kvm -F &
  fi
fi

if [ "$1" == "4.6" ]; then
  if [ "$2" == "xen" ]; then 
    $3/client/target/generated-webapp/WEB-INF/classes/scripts/storage/secondary/cloud-install-sys-tmplt -m /exports/sec1 -u http://192.168.217.11/systemvm64template-master-4.6.0-xen.vhd.bz2 -h xenserver -F &
  elif [ "$2" == "kvm" ]; then
    $3/client/target/generated-webapp/WEB-INF/classes/scripts/storage/secondary/cloud-install-sys-tmplt -m /exports/sec1 -u http://192.168.217.11/systemvm64template-master-4.6.0-kvm.qcow2.bz2 -h kvm -F &
  fi
fi


