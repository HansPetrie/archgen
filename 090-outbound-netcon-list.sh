#!/bin/bash

for file in `cat reports/instance-ips-$1-$2.txt`
do 
  # get a unique list of all the outbound connections by ip
  tail -n +3 hosts/$1/$2/net.$file | grep -v 127.0.0.1 | awk '{ print $5 }' | cut -f1 -d":" | sort | uniq > hosts/$1/$2/netcon-$file
  # for all the ips in the new file - replace it with the ip and the hostname
  for ip in `cat hosts/$1/$2/netcon-$file`
  do
    machinename=`cat reports/ips-$1-$2.txt | grep $ip | head -1 | cut -f2 -d'"'`
    if [ -z "$machinename" ]; then
      machinename=`dig +short -x $ip`
    fi
    echo "$file converted $ip $machinename"
    sed -i "s|$ip|$machinename|g" hosts/$1/$2/netcon-$file 
  done
done
