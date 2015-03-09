#!/bin/bash

set -x

/exports/cloudstack/4.5/cloudstack/client/target/generated-webapp/WEB-INF/classes/scripts/storage/secondary/cloud-install-sys-tmplt -m /exports/sec1 -u http://packages.shapeblue.com/systemvmtemplate/4.5/systemvm64template-4.5-xen.vhd.bz2 -h xenserver -F

