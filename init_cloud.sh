#!/bin/bash

set -x

usage() { echo "Usage: $0 [ -c <setup|save|destroy:snapshot> -n <suffix for snapshot> -b <cloudstack branch> ]" 1>&2; exit 1; }

c=unknown
n=unknown
while getopts ":c:n:" o; do
        case "${o}" in
                c)
                        c=${OPTARG}
                        ;;
                n)
                        n=${OPTARG}
                        ;;
                *)
                        usage
                        ;;
        esac
done

#git --git-dir=/Users/abhinandanprateek/work/shapeblue/cloudstack_utils/.git --work-tree=/Users/abhinandanprateek/work/shapeblue/cloudstack_utils pull

if [ $c = "unknown" ]; then
        usage
elif [ $c = "run" ]; then
	ssh root@192.168.100.41 /root/cloudstack_utils/build_cloud.sh -c run
elif [ $c = "build" ]; then
  	ssh root@192.168.100.40 git --git-dir=/exports/cloudstack/4.5/cloudstack/.git --work-tree=/exports/cloudstack/4.5/cloudstack pull	
	ssh root@192.168.100.41 /root/cloudstack_utils/build_cloud.sh -c build
elif [ $c = "setup" ]; then
	#git pull
	vmrun start /Users/abhinandanprateek/Documents/Virtual\ Machines.localized/ccp.vmwarevm/ccp.vmx
	vmrun revertToSnapshot /Users/abhinandanprateek/Documents/Virtual\ Machines.localized/Xen65_2.vmwarevm/Xen65_2.vmx Initial_setup_snap
	vmrun revertToSnapshot /Users/abhinandanprateek/Documents/Virtual\ Machines.localized/Xen65_1.vmwarevm/Xen65_1.vmx Initial_setup_snap
	vmrun start /Users/abhinandanprateek/Documents/Virtual\ Machines.localized/Xen65_2.vmwarevm/Xen65_2.vmx
	vmrun start /Users/abhinandanprateek/Documents/Virtual\ Machines.localized/Xen65_1.vmwarevm/Xen65_1.vmx 
	sleep 120
  	ssh root@192.168.100.40 git --git-dir=/exports/cloudstack/4.5/cloudstack/.git --work-tree=/exports/cloudstack/4.5/cloudstack pull	
	#build
	ssh root@192.168.100.41 /root/cloudstack_utils/build_cloud.sh -c setup
elif [ $c = "start" ]; then
	vmrun start Users/abhinandanprateek/Documents/Virtual\ Machines.localized/ccp.vmwarevm/ccp.vmx
	vmrun start /Users/abhinandanprateek/Documents/Virtual\ Machines.localized/Xen65_2.vmwarevm/Xen65_2.vmx
	vmrun start /Users/abhinandanprateek/Documents/Virtual\ Machines.localized/Xen65_1.vmwarevm/Xen65_1.vmx 
fi

