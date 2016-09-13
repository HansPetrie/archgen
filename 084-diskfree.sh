#!/bin/bash

source config

if [ $# -ne 2 ]; then echo "Requires account and region as arguments"; exit 1; fi
echo "" > reports/df-$1-$2.txt

for host in `cat reports/instance-ips-$1-$2.txt`
do 
  echo "Interrogating via ssh: $host"
  diskfree=`ssh -ttt $username@$host -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "df -h --total / | tail -1" | awk '{ print $4 }'`
  echo "$host $diskfree" >> reports/df-$1-$2.txt
done
