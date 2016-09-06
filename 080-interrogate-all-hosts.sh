#!/bin/bash

if [ $# -ne 2 ]; then echo "Requires account and region as arguments"; exit 1; fi

rm -rf hosts/$1/$2
mkdir -p hosts/$1/$2

username="hans"

for host in `cat reports/instance-ips-$1-$2.txt`
do 
  echo "Interrogating via ssh: $host"
  ssh -ttt $username@$host -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "hostname -f;sudo free -h;sudo df -h;sudo top -b n1" > hosts/$1/$2/free.$host
  ssh -ttt $username@$host -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "sudo netstat --numeric --tcp --udp --program --raw" > hosts/$1/$2/net.$host
done
