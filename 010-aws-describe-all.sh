#!/bin/bash -e

rm -rf awsreport
mkdir -p awsreport 
IFS=$'\n' 

#For all regions use this
#regions=$(aws ec2 --region us-east-1 describe-regions --query Regions[*].[RegionName] --output text)

#To hard code a single region
regions="us-east-1"

#To use several profiles
profiles="devops
production
qa"

#To use several regions
#regions="us-east-1
#us-west-1"

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

for region in $regions; do
  for command in $commands; do
    for profile in $profiles; do
      filename=$(echo $command | sed 's/ /-/g' )
      set -x
      bash -c "aws --profile $profile --output json --region $region $command > awsreport/$profile-$region-$filename"
      set +x
    done
  done
done
