#!/bin/bash

source config

if [ $# -ne 2 ]; then echo "Requires account and region as arguments"; exit 1; fi
echo "" > reports/mem-$1-$2.txt

for host in `cat reports/instance-ips-$1-$2.txt`
do 
  echo "Interrogating via ssh: $host"
  memfree=`ssh -ttt $username@$host -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "free -th | grep Total" | awk '{ print $4 }'`
  echo "$host $memfree" >> reports/mem-$1-$2.txt
done
