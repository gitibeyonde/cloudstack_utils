#!/bin/bash
# Copyright (C) ShapeBlue Ltd - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Released by ShapeBlue <info@shapeblue.com>, April 2014


# Author - Geoff Higginbottom - ShapeBlue LTD
# Version - 2.0
# Release Date - 4 Nov 2014
# Contact - geoff.higginbottom@shapbelue.com

# ************************ Global Variables Start ************************

zone_name=Bootcamp
network_offering_name=DefaultIsolatedNetworkOfferingWithSourceNatService
template_name='"CentOS 5.6(64-bit) no GUI (XenServer)"'
service_offering_name='"Ultra Tiny"'

domain_name=wayne
account=batman
network_name=batman-001

vm001_name=Batman-VM-001
vm001_display_name='"Batman VM 001"'
vm001_ip_addr=10.1.1.101

vm002_name=Batman-VM-002
vm002_display_name='"Batman VM 002"'
vm002_ip_addr=10.1.1.102

vm001_port_fwd_priv=22
vm001_port_fwd_pub=2221
vm001_port_fwd_prot=tcp

vm002_port_fwd_priv=22
vm002_port_fwd_pub=2222
vm002_port_fwd_prot=tcp

fw_rule1_start_port=2221
fw_rule1_end_port=2222
fw_rule1_prot=tcp

eg_rule1_start_port=
eg_rule1_end_port=
eg_rule1_icmpcode=-1
eg_rule1_icmptype=-1
eg_rule1_prot=ICMP
eg_rule1_cidr=10.1.1.0/24

eg_rule2_start_port=80
eg_rule2_end_port=80
eg_rule2_icmpcode=
eg_rule2_icmptype=
eg_rule2_prot=TCP
eg_rule2_cidr=10.1.1.102/32

# ************************ Global Variables End ************************

cli=cloudmonkey
$cli set asyncblock true
$cli set timeout 600
$cli set color false
$cli set display default

echo "
Please wait while we gather requried information
"

#Obtain Required Resource IDs
zone_id=`$cli list zones name=$zone_name | grep ^id\ = | awk '{print $3}'`
echo "Zone ID = "$zone_id

domain_id=`$cli list domains name=$domain_name | grep ^id\ = | awk '{print $3}'`
echo "Domain ID = "$domain_id
echo "Account = "$account

networkoffering_id=`$cli list networkofferings name=$network_offering_name | grep ^id\ = | awk '{print $3}'`
echo "Network Offering ID = " $networkoffering_id

template_id=`$cli list templates name=$template_name templatefilter=featured | grep ^id\ = | awk '{print $3}'`
echo "Template ID = "$template_id

serviceoffering_id=`$cli list serviceofferings name=$service_offering_name | grep ^id\ = | awk '{print $3}'`
echo "Service Offering ID = "$serviceoffering_id

# ************************ Create Network ************************
echo "Please wait whilst we create the Network"
network_id=`$cli list networks keyword=$network_name listall=true | grep ^id\ = | awk '{print $3}'`
if [ -z "$network_id" ]; then
	echo "Creating Network" $network_name
	network_id=`$cli create network name=$network_name displaytext=$network_name networkofferingid=$networkoffering_id zoneid=$zone_id account=$account domainid=$domain_id | grep ^id\ = | awk '{print $3}'`
fi
echo "Created Network - ID = "$network_id
echo " "

# ************************ Create VM 001 ************************
echo "$vm001_name is deploying - please wait - first VM can take a long time to deploy as VR has to start, and Template may require copying from Secondary to Primary Storage"
vm001_jobid=`$cli deploy virtualmachine serviceofferingid=$serviceoffering_id templateid=$template_id zoneid=$zone_id account=$account domainid=$domain_id networkids=$network_id ipaddress=$vm001_ip_addr name=$vm001_name displayname=$vm001_display_name | grep ^jobid\ = | awk '{print $3}'`
echo "Deploy VM Job ID ="$vm001_jobid

vm001_status=`$cli query asyncjobresult jobid=$vm001_jobid | grep ^jobstatus\ = | awk '{print $3}'`
while [[ $vm001_status == 0 ]]; do
   vm001_status=`$cli query asyncjobresult jobid=$vm001_jobid | grep ^jobstatus\ = | awk '{print $3}'`
done

vm001_id=`cloudmonkey query asyncjobresult jobid=$vm001_jobid filter=virtualmachine,id | grep '^id =' | head -1 | cut -c 6-`
echo "VM001 ID = $vm001_id"
echo "$vm001_name has been created"
echo " "

# ************************ Create VM 002 ************************
#Deploy VM002 and monitor its status
echo "$vm002_name is deploying - please wait"
vm002_jobid=`$cli deploy virtualmachine serviceofferingid=$serviceoffering_id templateid=$template_id zoneid=$zone_id account=$account domainid=$domain_id networkids=$network_id ipaddress=$vm002_ip_addr name=$vm002_name displayname=$vm002_display_name | grep ^jobid\ = | awk '{print $3}'`
echo "Deploy VM Job ID ="$vm002_jobid

vm002_status=`$cli query asyncjobresult jobid=$vm002_jobid | grep ^jobstatus\ = | awk '{print $3}'`
while [[ $vm002_status == 0 ]]; do
	vm002_status=`$cli query asyncjobresult jobid=$vm002_jobid | grep ^jobstatus\ = | awk '{print $3}'`
done

vm002_id=`cloudmonkey query asyncjobresult jobid=$vm002_jobid filter=virtualmachine,id | grep '^id =' | head -1 | cut -c 6-`
echo "VM002 ID = $vm002_id"
echo "$vm002_name has been created"
echo " "

# ************************ Create Firewall Rules ************************
echo "Please wait while we create the Port Forwarding and Firewall Rules"

public_ip1_id=`$cli list publicipaddresses account=$account domainid=$domain_id associatednetworkid=$network_id | grep ^id\ = | awk '{print $3}'`
public_ip1_ip=`$cli list publicipaddresses account=$account domainid=$domain_id associatednetworkid=$network_id | grep ^ipaddress\ = | awk '{print $3}'`
echo "ID of Public IP for Network $network_name = $public_ip1_id"
echo "Public IP for Network $network_name = $public_ip1_ip"
echo " "

echo "Creating Port Forwarding Rules"
pfr1_status=`$cli create portforwardingrule ipaddressid=$public_ip1_id privateport=$vm001_port_fwd_priv publicport=$vm001_port_fwd_pub protocol=$vm001_port_fwd_prot virtualmachineid=$vm001_id openfirewall=false | grep ^jobstatus\ = | awk '{print $3}'`
pfr2_status=`$cli create portforwardingrule ipaddressid=$public_ip1_id privateport=$vm002_port_fwd_priv publicport=$vm002_port_fwd_pub protocol=$vm002_port_fwd_prot virtualmachineid=$vm002_id openfirewall=false | grep ^jobstatus\ = | awk '{print $3}'`
echo "Created Port Forwarding Rules"
echo " "

echo "Creating Firewall Rules"
fwr1_status=`$cli create firewallrule ipaddressid=$public_ip1_id protocol=$fw_rule1_prot startport=$fw_rule1_start_port endport=$fw_rule1_end_port | grep ^jobstatus\ = | awk '{print $3}'`
echo "Created Firewall Rule"
echo " "

# ************************ Create Egress Rules ************************
echo "Please wait while we create the Egress Rules"

egr1_status=`$cli create egressfirewallrule networkid=$network_id protocol=$eg_rule1_prot cidrlist=$eg_rule1_cidr startport=$eg_rule1_start_port endport=$eg_rule1_end_port icmpcode=$eg_rule1_icmpcode icmptype=$eg_rule1_icmptype | grep ^jobstatus\ = | awk '{print $3}'`
egr2_status=`$cli create egressfirewallrule networkid=$network_id protocol=$eg_rule2_prot cidrlist=$eg_rule2_cidr startport=$eg_rule2_start_port endport=$eg_rule2_end_port icmpcode=$eg_rule2_icmpcode icmptype=$eg_rule2_icmptype | grep ^jobstatus\ = | awk '{print $3}'`
echo "Created Firewall Egress Rules"
echo " "
echo "All Done"
