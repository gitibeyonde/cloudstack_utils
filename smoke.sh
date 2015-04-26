#!/bin/sh

set -x

TMP=/tmp
CLOUDDIR=/root/cloudstack
mkdir -p $TMP/integration-test-results/misc

SITESTS= #"test_acl_isolatednetwork_delete test_acl_isolatednetwork test_acl_isolatednetwork test_acl_listsnapshot test_acl_listvm test_acl_listvolume test_acl_sharednetwork_deployVM-impersonation test_acl_sharednetwork"

STEST=#"test_affinity_groups test_deploy_vms_with_varied_deploymentplanners test_disk_offerings test_global_settings test_guest_vlan_range test_iso test_portable_publicip test_primary_storage test_privategw_acl test_public_ip_range test_pvlan test_regions test_reset_vm_on_reboot test_resource_detail test_routers test_secondary_storage test_service_offerings test_ssvm test_templates test_multipleips_per_nic test_network test_non_contigiousvlan test_over_provisioning test_volumes test_vpc_vpn misc/test_deploy_vm test_vm_life_cycle"

for suite in $SITESTS; do 
	nosetests --with-xunit --xunit-file=$TMP/integration-test-results/$suite.xml --with-marvin --marvin-config=$CLOUDDIR/setup/dev/advanced.cfg $CLOUDDIR/test/integration/component/$suite.py -s -a tags=advanced,required_hardware=false --zone=Sandbox-simulator --hypervisor=simulator 
done

for suite in $STESTS; do 
	nosetests --with-xunit --xunit-file=$TMP/integration-test-results/$suite.xml --with-marvin --marvin-config=$CLOUDDIR/setup/dev/advanced.cfg $CLOUDDIR/test/integration/smoke/$suite.py -s -a tags=advanced,required_hardware=false --zone=Sandbox-simulator --hypervisor=simulator 
done

