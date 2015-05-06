#!/bin/bash

set -x

eth0_pif_uuid=`xe pif-list params=all device=eth0 | grep "^uuid" | cut -d':' -f2 | tr -d ' '`
eth0_network_uuid=`xe pif-list params=all device=eth0 | grep "network-uuid" | cut -d':' -f2 | tr -d ' '`
echo "PIF uuid for eth0 PUBLIC " $eth0_pif_uuid
echo "Network uuid for eth0 PUBLIC " $eth0_network_uuid

#check network params for eth0
xe network-param-set name-label=PUBLIC uuid=$eth0_network_uuid
xe pif-reconfigure-ip IP=192.168.100.46 netmask=255.255.255.0 gateway=192.168.100.1 mode=static uuid=$eth0_pif_uuid


eth1_pif_uuid=`xe pif-list params=all device=eth1 | grep "^uuid" | cut -d':' -f2 | tr -d ' '`
eth1_network_uuid=`xe pif-list params=all device=eth1 | grep "network-uuid" | cut -d':' -f2 | tr -d ' '`
echo "PIF uuid for eth1 MGMT " $eth1_pif_uuid
echo "Network uuid for eth1 MGMT " $eth1_network_uuid

#check network params for eth1
xe network-param-set name-label=MGMT uuid=$eth1_network_uuid
xe pif-reconfigure-ip IP=192.168.217.16 netmask=255.255.255.0 gateway=192.168.217.1 mode=static uuid=$eth1_pif_uuid

eth2_pif_uuid=`xe pif-list params=all device=eth2 | grep "^uuid" | cut -d':' -f2 | tr -d ' '`
eth2_network_uuid=`xe pif-list params=all device=eth2 | grep "network-uuid" | cut -d':' -f2 | tr -d ' '`
echo "PIF uuid for eth2 GUEST " $eth2_pif_uuid
echo "Network uuid for eth2 GUEST " $eth2_network_uuid

#check network params for eth2
xe network-param-set name-label=GUEST uuid=$eth2_network_uuid
xe pif-reconfigure-ip IP=172.16.16.16 netmask=255.255.255.0 gateway=172.16.16.1 mode=static uuid=$eth2_pif_uuid

