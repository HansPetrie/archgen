#!/bin/bash

for i in `cat $1`
do 
  ips=`dig +short $i`
  for ip in $ips
  do
    echo $ip $i
  done
done
