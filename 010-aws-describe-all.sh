#!/bin/bash -e

mkdir -p awsreport 
IFS=$'\n' 
profile=$1
region=$2

commands="ec2 describe-account-attributes
ec2 describe-addresses
ec2 describe-availability-zones
ec2 describe-instances
ec2 describe-internet-gateways
ec2 describe-key-pairs
ec2 describe-network-acls
ec2 describe-network-interfaces
ec2 describe-placement-groups
ec2 describe-reserved-instances
ec2 describe-route-tables
ec2 describe-security-groups
ec2 describe-subnets
ec2 describe-tags
ec2 describe-volumes
ec2 describe-vpcs
elb describe-load-balancers
rds describe-db-instances
"

for command in $commands; do
  filename=$(echo $command | sed 's/ /-/g' )
  set -x
    bash -c "aws --profile $profile --output json --region $region $command > awsreport/$profile-$region-$filename"
  set +x
done
