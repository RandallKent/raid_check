#!/bin/sh

###############################################################################
# Copyright 2012, Randall Kent
# URL: http://www.randallkent.com
# Email: rkent@sevaa.com
###############################################################################

# This script will send an email if the raid array is not "OK"
# To install:
#   1. Extract to /root/raid_check
#   2. Add to daily cron with command below
#       ln -s /root/raid_check/3ware_check /etc/cron.daily/raid_check

# Set variable to where you'd like alerts to be sent
email=email@domain.tld

# You shouldn't have to modify anythign below this line
arch=`uname -m`
val=`/root/raid_check/cli_tools/$arch/tw_cli info c0 | grep -i "RAID-1" | awk '{print$3}'`
model=`/root/raid_check/cli_tools/$arch/tw_cli info | grep -i "c0" | awk '{print$2}'`

if [ "$val" != "OK" ]; then
  mailtmp=/tmp/.raidcheck$$
  fullstatus=`/root/raid_check/cli_tools/$arch/tw_cli info c0`

  echo "SYSTEM: $HOSTNAME" >> $mailtmp
  echo "RAID TYPE: 3ware" >> $mailtmp
  echo "RAID MODEL: $model" >> $mailtmp
  echo "RAID STATUS: $fullstatus">> $mailtmp

  cat $mailtmp | mail -s "!! RAID failure on $HOSTNAME !!" $email
fi