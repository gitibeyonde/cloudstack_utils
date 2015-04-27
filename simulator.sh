#!/bin/sh

set -x

TMP=/tmp
CLOUDDIR=/root/cloudstack
mkdir -p $TMP/simulator/smoke/misc
mkdir -p $TMP/simulator/component

TESTS="smoke/test_affinity_groups smoke/test_deploy_vms_with_varied_deploymentplanners smoke/test_disk_offerings smoke/test_global_settings" 
TESTS="${TESTS} smoke/test_portable_publicip smoke/test_primary_storage smoke/test_privategw_acl smoke/test_public_ip_range smoke/test_pvlan smoke/test_regions" 
TESTS="${TESTS} smoke/smoke/test_reset_vm_on_reboot smoke/test_resource_detail test_routers smoke/test_guest_vlan_range smoke/test_iso"
TESTS="${TESTS} smoke/test_secondary_storage smoke/test_service_offerings smoke/test_ssvm test_templates"
TESTS="${TESTS} smoke/test_multipleips_per_nic smoke/test_network smoke/test_non_contigiousvlan smoke/test_over_provisioning"
TESTS="${TESTS} smoke/test_volumes smoke/test_vpc_vpn smoke/misc/test_deploy_vm smoke/test_vm_life_cycle"
TESTS="${TESTS} component/test_acl_isolatednetwork_delete component/test_acl_isolatednetwork component/test_acl_isolatednetwork component/test_acl_listsnapshot" 
TESTS="${TESTS} component/test_acl_listvm component/test_acl_listvolume component/test_acl_sharednetwork_deployVM-impersonation component/test_acl_sharednetwork"

for suite in $TESTS; do 
	nosetests --with-xunit --xunit-file=$TMP/simulator/$suite.xml --with-marvin --marvin-config=$CLOUDDIR/setup/dev/advanced.cfg $CLOUDDIR/test/integration/$suite.py -s -a tags=advanced,required_hardware=false --zone=Sandbox-simulator --hypervisor=simulator 
done

