#!/bin/bash
# Copyright (C) ShapeBlue Ltd - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Released by ShapeBlue <info@shapeblue.com>, April 2014


# Author - Geoff Higginbottom - ShapeBlue LTD
# Version - 1.4
# Release Date - 02 Feb 2015
# Contact - geoff.higginbottom@shapbelue.com

cli=cloudmonkey
$cli set asyncblock true
$cli set timeout 10
$cli set color false
$cli set display default

# ======================== Remove Default Offerings ========================
offeringid1=`$cli list serviceofferings name='"Small Instance"' | grep ^id\ = | awk '{print $3}'`
offeringid2=`$cli list serviceofferings name='"Medium Instance"' | grep ^id\ = | awk '{print $3}'`

echo "Deleting default Compute Offerings"
$cli delete serviceoffering id=$offeringid1
$cli delete serviceoffering id=$offeringid2

diskofferingid1=`$cli list diskofferings name="Small" | grep ^id\ = | awk '{print $3}'`
diskofferingid2=`$cli list diskofferings name="Medium" | grep ^id\ = | awk '{print $3}'`
diskofferingid3=`$cli list diskofferings name="Large" | grep ^id\ = | awk '{print $3}'`

echo "Deleting default Disk Offerings"
$cli delete diskoffering id=$diskofferingid1
$cli delete diskoffering id=$diskofferingid2
$cli delete diskoffering id=$diskofferingid3

# ======================== Add Offerings ========================
#Add Compute Offerings
echo "Adding new Bootcamp Compute Offerings"
$cli create serviceoffering cpunumber=1 cpuspeed=500 displaytext='"Ultra Tiny - 1vCPU, 128MB RAM"' memory=128 name='"Ultra Tiny"' offerha=true
$cli create serviceoffering cpunumber=1 cpuspeed=500 displaytext='"Tiny - 1vCPU, 256MB RAM"' memory=256 name='"Tiny"' offerha=true
$cli create serviceoffering cpunumber=1 cpuspeed=500 displaytext='"Ultra Tiny Local - 1vCPU, 128MB RAM"' memory=128 name='"Ultra Tiny Local"' offerha=false storagetype=local

echo "Adding new Bootcamp Disk Offerings"
#Add Disk Offerings
$cli create diskoffering displaytext='"Bootcamp 10GB"' name='"Bootcamp 10GB"' disksize=10 storagetype=shared
$cli create diskoffering displaytext='"Bootcamp 2GB"' name='"Bootcamp 2GB"' disksize=2 storagetype=shared
$cli create diskoffering displaytext='"Bootcamp 2GB"' name='"Bootcamp 2GB Local"' disksize=2 storagetype=local

echo "All Done"