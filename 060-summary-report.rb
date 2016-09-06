#!/usr/bin/ruby

require 'json'

@filepath=ARGV[0]

input_hash = JSON.parse(File.read("#{@filepath}"))

input_hash['VPC'].each do |vpc|
  puts "-----------------------"
  puts "#{vpc['VpcId']} #{vpc['CidrBlock']}"
  if vpc['Tags']
    vpc['Tags'].each do |vpc_tags|
      puts "#{vpc_tags['Key']}:#{vpc_tags['Value']}"
    end
  end
  vpc['ELB'].each do |elb|
    puts "  ELB #{elb['LoadBalancerName']} #{elb['Instances'].to_json}"
  end
  vpc['RDS'].each do |rds|
    puts "  RDS #{rds['DBInstanceIdentifier']}  #{rds['DBInstanceClass']}  #{rds['Engine']}"
  end
  vpc['Subnets'].each do |subnet|
    puts "------------------"  
    puts "--#{subnet['SubnetId']} #{subnet['CidrBlock']} #{subnet['AvailabilityZone']}"
    subnet['Instances'].each do |instance|
	if instance['Tags'] then
          instance['Tags'].each do |instance_tags|
            print " #{instance_tags['Key']}:#{instance_tags['Value']}"
          end
        end
        print "\n"
      	printf "      %-9.9s %-12.12s %-12.12s %-10.10s",    instance['InstanceId'], instance['PrivateIpAddress'], instance['PublicIpAddress'], instance['InstanceType']
      	print  "SGs: "
      	instance["SecurityGroups"].each do |security_group|
	  print"  #{security_group['GroupName']}"
      end
      print "\n"
      print "\n" 
    end
  end
end
