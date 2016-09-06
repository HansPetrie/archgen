#!/bin/bash

rm -rf reports
mkdir -p reports

accounts="qa production devops"
regions="us-east-1"
for account in $accounts
do
  for region in $regions
  do
    echo $account $region 
    echo "jsonmerge"
    ./030-jsonmerge.rb $account $region awsreport > reports/$account-$region.json
    echo "elblist"
    ./040-elb-list.rb reports/$account-$region.json > reports/elbs-$account-$region.txt
    echo "elb ip list"
    ./045-elb-ip-list.sh reports/elbs-$account-$region.txt > reports/ipelb-$account-$region.txt
    echo "security groups"
    ./050-securitygroups.rb awsreport/$account-$region-ec2-describe-security-groups > reports/sg-$account-$region.txt
    echo "summary report"
    ./060-summary-report.rb awsreport/$account-$region.json > reports/summary-$account-$region.txt
    echo "network"
    ./070-network.rb $account $region > reports/enis-$account-$region.txt
    echo "host ips"
    ./075-hostips.rb reports/$account-$region.json > reports/instance-ips-$account-$region.txt
    cat reports/ipelb-$account-$region.txt reports/enis-$account-$region.txt > reports/ips-$account-$region.txt
    echo "interrogating hosts via ssh"
#    ./080-interrogate-all-hosts.sh $account $region 
    echo "outbound network connections"
    ./090-outbound-netcon-list.sh $account $region
    echo "architecture report"
    ./100-architecutre-report.rb $account $region > reports/arch-$account-$region.txt

  done
done
