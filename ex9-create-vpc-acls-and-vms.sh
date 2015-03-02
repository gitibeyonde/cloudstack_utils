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

template_name='"CentOS 5.6(64-bit) no GUI (XenServer)"'
service_offering_name='"Ultra Tiny"'

domain_name=wayne
account=batman

vpc_super_cidr=172.16.0.0/22
vpc_name=batman-vpc-001
vpc_desc='"Batman VPC 001"'

vm001_name=Batman-VPC-VM-001
vm001_display_name='"Batman VPC VM 001"'
vm001_ip_addr=172.16.1.101

vm002_name=Batman-VPC-VM-002
vm002_display_name='"Batman VPC VM 002"'
vm002_ip_addr=172.16.2.102

vpc_tier1_name=batman-tier-1
vpc_tier1_display_name='"Batman Tier 1"'
vpc_tier1_gateway=172.16.1.1
vpc_tier1_netmask=255.255.255.0

vpc_tier2_name=batman-tier-2
vpc_tier2_display_name='"Batman Tier 2"'
vpc_tier2_gateway=172.16.2.1
vpc_tier2_netmask=255.255.255.0

# ************************ Global Variables End ************************

cli=cloudmonkey
$cli set asyncblock true
$cli set timeout 600
$cli set color false
$cli set display default

#Obtain Required Resource IDs
echo "
Please wait while we gather requried information
"
zone_id=`$cli list zones name=$zone_name | grep ^id\ = | awk '{print $3}'`
echo "Zone ID = "$zone_id

domain_id=`$cli list domains name=$domain_name | grep ^id\ = | awk '{print $3}'`
echo "Domain ID = "$domain_id
echo "Account = "$account

vpc_offering_id=`$cli list vpcofferings name='"Default VPC Offering"' | grep ^id\ = | awk '{print $3}'`
echo "VPC Offering ID = "$vpc_offering_id

vpc_t1_offering_id=`$cli list networkofferings forvpc=true supportedservices=lb,vpn | grep ^id\ = | awk '{print $3}'`
echo "VPC Tier 1 Offering ID = "$vpc_t1_offering_id

vpc_t2_offering_id=`$cli list networkofferings name=DefaultIsolatedNetworkOfferingForVpcNetworksNoLB | grep ^id\ = | awk '{print $3}'`
echo "VPC Tier 2 Offering ID = "$vpc_t2_offering_id

template_id=`$cli list templates name=$template_name templatefilter=featured | grep ^id\ = | awk '{print $3}'`
echo "Template ID = "$template_id

serviceoffering_id=`$cli list serviceofferings name=$service_offering_name | grep ^id\ = | awk '{print $3}'`
echo "Service Offering ID = "$serviceoffering_id
echo " "

# ************************ Create VPC ************************
echo "Creating VPC - please wait - this can take up to 2 mins"
vpc_jobid=`$cli create vpc cidr=$vpc_super_cidr name=$vpc_name displaytext=$vpc_desc vpcofferingid=$vpc_offering_id zoneid=$zone_id account=$account domainid=$domain_id | grep ^jobid\ = | awk '{print $3}'`
#echo "Created VPC JOB ID = " $vpc_jobid

vpc_status=`$cli query asyncjobresult jobid=$vpc_jobid | grep ^jobstatus\ = | awk '{print $3}'`
while [[ $vpc_status == 0 ]]; do
vpc_status=`$cli query asyncjobresult jobid=$vpc_jobid | grep ^jobstatus\ = | awk '{print $3}'`
done

#vpc_id=`$cli query asyncjobresult jobid=$vpc_jobid | awk 'NR == 9' | cut -c 6-`
vpc_id=`$cli query asyncjobresult jobid=$vpc_jobid | grep ^id | cut -c 6-`
echo "VPC has been created - ID = "$vpc_id
echo " "

# ************************ Create ACLs ************************
echo "Creating the Tier 1 ACL List"
tier1_acllist_jobid=`cloudmonkey create networkacllist name='"Tier 1 ACL List"' description='"Tier 1 ACL List"' vpcid=$vpc_id | grep ^jobid\ = | awk '{print $3}'`
#echo $tier1_acllist_jobid
tier1_acllist_id=`cloudmonkey query asyncjobresult jobid=$tier1_acllist_jobid | grep ^id\ = | awk '{print $3}'`
echo "Tier 1 ACL List - ID = "$tier1_acllist_id
echo "Tier 1 ACL List Created - Please wait whilst we now add the ACL Rules"
tier1_acl1_id=`$cli create networkacl protocol=tcp aclid=$tier1_acllist_id cidrlist=0.0.0.0/0 startport=80 endport=80 traffictype=ingress action=allow | grep ^id\ = | awk '{print $3}'`
echo "Rule 1 Created"
tier1_acl2_id=`$cli create networkacl protocol=tcp aclid=$tier1_acllist_id cidrlist=0.0.0.0/0 startport=443 endport=443 traffictype=ingress action=allow | grep ^id\ = | awk '{print $3}'`
echo "Rule 2 Created"
tier1_acl3_id=`$cli create networkacl protocol=tcp aclid=$tier1_acllist_id cidrlist=0.0.0.0/0 startport=22 endport=22 traffictype=ingress action=allow | grep ^id\ = | awk '{print $3}'`
echo "Rule 3 Created"
tier1_acl4_id=`$cli create networkacl protocol=icmp aclid=$tier1_acllist_id cidrlist=0.0.0.0/0 icmptype=-1 icmpcode=-1 traffictype=egress action=allow | grep ^id\ = | awk '{print $3}'`
echo "Rule 4 Created"
echo "ACL Rules for Tier 1 Created"
echo " "

echo "Creating the Tier 2 ACL List"
tier2_acllist_jobid=`cloudmonkey create networkacllist name='"Tier 2 ACL List"' description='"Tier 2 ACL List"' vpcid=$vpc_id | grep ^jobid\ = | awk '{print $3}'`
#echo $tier2_acllist_jobid
tier2_acllist_id=`cloudmonkey query asyncjobresult jobid=$tier2_acllist_jobid | grep ^id\ = | awk '{print $3}'`
echo "Created Tier 2 ACL List - ID = "$tier2_acllist_id
echo "Tier 2 ACL List Created - Please wait whilst we now add the ACL Rules"
tier2_acl1_id=`$cli create networkacl protocol=tcp aclid=$tier2_acllist_id cidrlist=172.16.1.0/24 startport=3306 endport=3306 traffictype=ingress action=allow | grep ^id\ = | awk '{print $3}'`
echo "Rule 1 Created"
tier2_acl2_id=`$cli create networkacl protocol=icmp aclid=$tier2_acllist_id cidrlist=172.16.1.0/24 icmptype=-1 icmpcode=-1 traffictype=ingress action=allow | grep ^id\ = | awk '{print $3}'`
echo "Rule 2 Created"
tier2_acl3_id=`$cli create networkacl protocol=all aclid=$tier2_acllist_id cidrlist=0.0.0.0/0 traffictype=egress action=deny | grep ^id\ = | awk '{print $3}'`
echo "Rule 3 Created"
echo "ACL Rules for Tier 2 Created"
echo " "

# ************************ Create Networks ************************
echo "Please wait whilst we create the Tier 1 Network"
vpc_tier1_network_id=`$cli create network zoneid=$zone_id vpcid=$vpc_id domainid=$domain_id account=$account networkofferingid=$vpc_t1_offering_id name=$vpc_tier1_name displaytext=$vpc_tier1_display_name gateway=$vpc_tier1_gateway netmask=$vpc_tier1_netmask aclid=$tier1_acllist_id | grep ^id\ = | awk '{print $3}'`
echo "Created Tier 1 Network - ID = "$vpc_tier1_network_id
echo " "

echo "Please wait whilst we create the Tier 2 Network"
vpc_tier2_network_id=`$cli create network zoneid=$zone_id vpcid=$vpc_id domainid=$domain_id account=$account networkofferingid=$vpc_t2_offering_id name=$vpc_tier2_name displaytext=$vpc_tier2_display_name gateway=$vpc_tier2_gateway netmask=$vpc_tier2_netmask aclid=$tier2_acllist_id | grep ^id\ = | awk '{print $3}'`
echo "Created Tier 2 Network - ID = "$vpc_tier2_network_id
echo " "

# ************************ Create VPC VM 001 ************************
echo "$vm001_name is deploying - please wait - first VM can take a long time to deploy as Template may require copying"
vm001_jobid=`$cli deploy virtualmachine serviceofferingid=$serviceoffering_id templateid=$template_id zoneid=$zone_id account=$account domainid=$domain_id networkids=$vpc_tier1_network_id ipaddress=$vm001_ip_addr name=$vm001_name displayname=$vm001_display_name | grep ^jobid\ = | awk '{print $3}'`
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
echo "$vm002_name is deploying - please wait"
vm002_jobid=`$cli deploy virtualmachine serviceofferingid=$serviceoffering_id templateid=$template_id zoneid=$zone_id account=$account domainid=$domain_id networkids=$vpc_tier2_network_id ipaddress=$vm002_ip_addr name=$vm002_name displayname=$vm002_display_name | grep ^jobid\ = | awk '{print $3}'`
echo "Deploy VM Job ID ="$vm002_jobid

vm002_status=`$cli query asyncjobresult jobid=$vm002_jobid | grep ^jobstatus\ = | awk '{print $3}'`
while [[ $vm002_status == 0 ]]; do
	vm002_status=`$cli query asyncjobresult jobid=$vm002_jobid | grep ^jobstatus\ = | awk '{print $3}'`
done

vm002_id=`cloudmonkey query asyncjobresult jobid=$vm002_jobid filter=virtualmachine,id | grep '^id =' | head -1 | cut -c 6-`
echo "VM002 ID = $vm002_id"
echo "$vm002_name has been created"
echo " "

echo "All Done"