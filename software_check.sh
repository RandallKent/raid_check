#!/bin/sh

###############################################################################
# Copyright 2012, Randall Kent
# URL: http://www.randallkent.com
# Email: rkent@sevaa.com
###############################################################################

# This script detects all /dev/sdX drives then sends an email if smartctl 
# returns antyhing other than "PASSED" for any drive
# To install:
#   1. Extract to /root/raid_check
#   2. Add to daily cron with command below
#       ln -s /root/raid_check/software_check /etc/cron.daily/raid_check

# Set variable to where you'd like alerts to be sent
email=email@domain.tld

# You shouldn't have to modify anythign below this line
drives=`fdisk -l | grep "Disk /dev/sd" | awk '{print$2}' | sed 's/://'`
okval="PASSED"

for drive in $drives 
do
  val=`smartctl -H $drive | grep -i result | cut -d : -f2 | sed -e 's/^[ \t]*//'`

  if [ "$val" != "$okval" ]; then
    mailtmp=/tmp/.raidcheck$$
    fullstatus=`smartctl -a $drive`

    echo "SYSTEM: $HOSTNAME" >> $mailtmp
    echo "RAID TYPE: Software" >> $mailtmp
    echo "DIVE STATUS: $fullstatus">> $mailtmp

    cat $mailtmp | mail -s "!! HARD DRIVE failure on $HOSTNAME !!" $email
  fi
done