#!/bin/bash
# Copyright (C) ShapeBlue Ltd - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Released by ShapeBlue <info@shapeblue.com>, April 2014


# Author - Geoff Higginbottom - ShapeBlue LTD
# Version - 1.0
# Release Date - 6 Oct 2014
# Contact - geoff.higginbottom@shapbelue.com

# CloudMonkey script to create the Bootcamp Zone, configure the Physical Network and its associated settings, 
# add Secondary Storage, create the POD and Cluster, add Host and finally add Primary Storage.


# ************************ Global Variables Start ************************

#Zone Settings
zone_name=Bootcamp
guest_cidr=10.1.1.0/24
guest_vlan_range=650-669
dns_ext1=192.168.100.1
dns_int1=8.8.8.8

sec_stor1_name=SEC1
sec_stor1_url=nfs://192.168.217.11/exports/sec1

#Physical Network Settings
phy1_name="Physical Network 1"
phy1_iso_method=VLAN
phy1_speed=1G

#Traffic Mappings
mgmtlab=MGMT
guestlab=GUEST
publiclab=PUBLIC

#Public Network Settings
public_start=192.168.100.65
public_end=192.168.100.95
public_gateway=192.168.100.1
public_netmask=255.255.255.0
public_vlan=

#Host Settings
host_password=password
host_username=root

#POD1 Settings
p1_pod_name=POD1
p1_reserved_system_gateway=192.168.217.1
p1_reserved_system_netmask=255.255.255.0
p1_reserved_system_start_ip=192.168.217.35
p1_reserved_system_end_ip=192.168.217.75

#POD1 Cluster1 Settings
p1_cluster1_hypervisor=XenServer
p1_cluster1_type=CloudManaged
p1_cluster1_name=CLU1
p1_cluster1_host_ip=192.168.217.12
p1_cluster1_host2_ip=192.168.217.14

#POD1 Cluster1 Primary Storage Settings
p1_cluster1_pri_stor1_name=PRI1
p1_cluster1_pri_stor1_url=nfs://192.168.217.11/exports/prim1

# ************************ Global Variables End ************************

# ************************ Set Parameters ************************
cli=cloudmonkey
$cli set asyncblock true
$cli set timeout 10
$cli set color false
$cli set display default

# ************************ System Tests ************************

yum install -y nc

# POD1 Cluster 1 Checks
P1_PORT80=`nc -z -w5 $p1_cluster1_host_ip 80; echo $?`
P12_PORT80=`nc -z -w5 $p1_cluster1_host2_ip 80; echo $?`

if [[ $P1_PORT80 = '1' ]]
	then
	echo "Unable to connect to POD 1 Cluster 1 Host on Port 80 - Exiting"
	exit
fi
if [[ $P12_PORT80 = '1' ]]
	then
	echo "Unable to connect to POD 1 Cluster 1 Host 2 on Port 80 - Exiting"
	exit
fi

echo "Successsfully connected on Port 80 to POD 1 Cluster 1 Host "$p1_cluster1_host_ip
echo "Successsfully connected on Port 80 to POD 1 Cluster 1 Host "$p1_cluster1_host2_ip


P1_PORT443=`nc -z -w5 $p1_cluster1_host_ip 443; echo $?`
P12_PORT443=`nc -z -w5 $p1_cluster1_host2_ip 443; echo $?`

if [[ $P1_PORT443 = '1' ]]
	then
	echo "Unable to connect to POD 1 Cluster 1 Host on Port 443 - Exiting"
	exit
fi
if [[ $P12_PORT443 = '1' ]]
	then
	echo "Unable to connect to POD 1 Cluster 1 Host on Port 443 - Exiting"
	exit
fi

echo "Successsfully connected on Port 443 to POD 1 Cluster 1 Host "$p1_cluster1_host_ip
echo "Successsfully connected on Port 443 to POD 1 Cluster 1 Host 2 "$p1_cluster1_host2_ip


P1_PORT22=`nc -z -w5 $p1_cluster1_host_ip 22; echo $?`
P12_PORT22=`nc -z -w5 $p1_cluster1_host2_ip 22; echo $?`

if [[ $P1_PORT22 = '1' ]]
	then
	echo "Unable to connect to POD 1 Cluster 1 Host on Port 22 - Exiting"
	exit
fi
if [[ $P12_PORT22 = '1' ]]
	then
	echo "Unable to connect to POD 1 Cluster 1 Host 2 on Port 22 - Exiting"
	exit
fi

echo "Successsfully connected on Port 22 to POD 1 Cluster 1 Host "$p1_cluster1_host_ip
echo "Successsfully connected on Port 22 to POD 1 Cluster 1 Host 2"$p1_cluster1_host2_ip

# ************************ System Tests End ************************


# ************************ Create Zone ************************
zone_id=`$cli create zone dns1=$dns_ext1 internaldns1=$dns_int1 name=$zone_name networktype=Advanced guestcidraddress=$guest_cidr | grep ^id\ = | awk '{print $3}'`
echo "Created Zone - ID" $zone_id "-" $zone_name
echo $zone_id > /tmp/zoneid

# ************************ Create Physical Networks ************************
phy1_id=`$cli create physicalnetwork name='"'$phy1_name'"' zoneid=$zone_id broadcastdomain=Zone isolationmethods=$phy1_iso_method networkspeed=$phy1_speed | grep ^id\ = | awk '{print $3}'`
echo "Created Physical Network " $phy1_name - $phy1_id

# ************************ Add Traffic Types ************************
$cli add traffictype traffictype=Management physicalnetworkid=$phy1_id xennetworklabel=$mgmtlab
echo "Added "Management" Traffic"

$cli add traffictype traffictype=Guest physicalnetworkid=$phy1_id xennetworklabel=$guestlab
echo "Added "Guest" Traffic"

$cli add traffictype traffictype=Public physicalnetworkid=$phy1_id xennetworklabel=$publiclab
echo "Added "Public" Traffic"

# ************************ Add Guest VLAN Range ************************
$cli update physicalnetwork id=$phy1_id vlan=$guest_vlan_range
$cli update zone id=$zone_id guestcidraddress=$guest_cidr

# ************************ Enable Physical Network ************************
$cli update physicalnetwork state=Enabled id=$phy1_id
echo "Enabled Physical Network - " $phy1_name

# ************************ Enable Service Providers ************************
nsp_id=`$cli list networkserviceproviders name=VirtualRouter physicalnetworkid=$phy1_id | grep ^id\ = | awk '{print $3}'`
vre_id=`$cli list virtualrouterelements nspid=$nsp_id | grep ^id\ = | awk '{print $3}'`
$cli api configureVirtualRouterElement enabled=true id=$vre_id
$cli update networkserviceprovider state=Enabled id=$nsp_id
echo "Enabled Virtual Router Service Provider"

nsp2_id=`$cli list networkserviceproviders name=VpcVirtualRouter physicalnetworkid=$phy1_id | grep ^id\ = | awk '{print $3}'`
vre2_id=`$cli list virtualrouterelements nspid=$nsp2_id | grep ^id\ = | awk '{print $3}'`
$cli api configureVirtualRouterElement enabled=true id=$vre2_id
$cli update networkserviceprovider state=Enabled id=$nsp2_id
echo "Enabled VPC Virtual Router Service Provider"

nsp3_id=`$cli list networkserviceproviders name=InternalLbVm physicalnetworkid=$phy1_id | grep ^id\ = | awk '{print $3}'`
vre3_id=`$cli list internalloadbalancerelements nspid=$nsp3_id | grep ^id\ = | awk '{print $3}'`
$cli configure internalloadbalancerelement enabled=true id=$vre3_id
$cli update networkserviceprovider state=Enabled id=$nsp3_id
echo "Enabled Internal LB VM Service Provider"

$cli api createVlanIpRange startip=$public_start endip=$public_end forvirtualnetwork=true gateway=$public_gateway netmask=$public_netmask vlan=$public_vlan zoneid=$zone_id
echo "Assigned Public IP Range"

# ************************ Add Secondary Storage ************************
$cli add imagestore provider=NFS zoneid=$zone_id url=$sec_stor1_url name=$sec_stor1_name
echo "Added Secondary Storage - "$sec_stor1_url

# ************************ Enable Zone ************************
$cli update zone id=$zone_id allocationstate=Enabled

# ************************ Add PODs ************************
p1_pod_id=`$cli create pod name=$p1_pod_name zoneid=$zone_id gateway=$p1_reserved_system_gateway netmask=$p1_reserved_system_netmask startip=$p1_reserved_system_start_ip endip=$p1_reserved_system_end_ip | grep ^id\ = | awk '{print $3}'`
echo "Created POD - " $p1_pod_name - $p1_pod_id

echo "Assigned Storage IP Range"

# ************************ Add Clusters ************************
p1_cluster1_id=`$cli add cluster zoneid=$zone_id hypervisor=$p1_cluster1_hypervisor clustertype=$p1_cluster1_type podid=$p1_pod_id clustername=$p1_cluster1_name | grep ^id\ = | awk '{print $3}'`
echo "Created Cluster - " $p1_cluster1_name - $p1_cluster1_id

# ************************ Add Hosts ************************
echo "Now adding Hosts, this can take some time so please be patient"
$cli add host zoneid=$zone_id podid=$p1_pod_id clusterid=$p1_cluster1_id hypervisor=$p1_cluster1_hypervisor username=$host_username password=$host_password url=http://$p1_cluster1_host_ip
echo "Added Hosts for POD1 Cluster 1"

ssh root@192.168.217.14 'sh /root/cloud-setup-bonding.sh'
ssh root@192.168.217.14 'xe pool-join master-address=192.168.217.12 master-username=root master-password=password'

sleep 20

$cli add host zoneid=$zone_id podid=$p1_pod_id clusterid=$p1_cluster1_id hypervisor=$p1_cluster1_hypervisor username=$host_username password=$host_password url=http://$p1_cluster1_host2_ip
echo "Added Hosts 2 for POD1 Cluster 1"


# ************************ Add Primary Storage ************************
echo "About to add Primary Storage - confirm all hosts are online in CloudStack UI before continuing"
echo "Press Enter to Continue" ; read
echo "Now adding Primary Storage"
$cli create storagepool zoneid=$zone_id podid=$p1_pod_id clusterid=$p1_cluster1_id name=$p1_cluster1_pri_stor1_name url=$p1_cluster1_pri_stor1_url
echo "Added Primary Storage - "$p1_cluster1_pri_stor1_name

echo "Done"
