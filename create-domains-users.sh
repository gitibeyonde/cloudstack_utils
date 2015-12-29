#!/bin/bash
# Copyright (C) ShapeBlue Ltd - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Released by ShapeBlue <info@shapeblue.com>, April 2014


# Author - Geoff Higginbottom - ShapeBlue LTD
# Version - 1.1
# Release Date - 6th Feb 2014
# Contact - geoff.higginbottom@shapbelue.com

cli=cloudmonkey
$cli set asyncblock true
$cli set timeout 10
$cli set color false
$cli set display default

domain_id1=`$cli create domain name=Bootcamp networkdomain=bootcamp.local  | grep ^id\ = | awk '{print $3}'`
#echo "Bootcamp - $domain_id1"
$cli create account domainid=$domain_id1 accounttype=2 username=sherlock account=bcadmin firstname=Sherlock lastname=Holmes email=sherlock.holmes@bootcamp.local password=password timezone=Etc/UTC
echo "Created Domain Admin Account - bcadmin"

domain_id2=`$cli create domain parentdomainid=$domain_id1 name=ACME networkdomain=acmeinc.local  | grep ^id\ = | awk '{print $3}'`
echo "Created Domain ACME - ID = $domain_id2"
$cli create account domainid=$domain_id2 accounttype=0 username=wile account=roadrunner firstname=Wile lastname=Coyote email=wile.e.coyote@acme.com password=password timezone=Etc/UTC
echo "Created User Account roadrunner"

domain_id3=`$cli create domain parentdomainid=$domain_id1 name=Wayne networkdomain=wayneindustries.local  | grep ^id\ = | awk '{print $3}'`
echo "Created Domain Wayne - ID = $domain_id3"
$cli create account domainid=$domain_id3 accounttype=0 username=bruce account=batman firstname=Bruce lastname=Wayne email=bruce.wayne@wayneindustries.com password=password timezone=Etc/UTC
echo "Created Account batman and User bruce, in Domain Wayne"
$cli create user password=password username=dick account=batman domainid=$domain_id3 firstname=Dick lastname=Grayson email=dick.grayson@wayneindustries.com timezone=Etc/UTC
echo "Created User dick in Account Batman"
