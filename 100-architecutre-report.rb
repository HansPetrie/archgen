#!/usr/bin/ruby

require 'json'
elbs=0;
vpcs=0;
instances=0;
rdscount=0;

@account=ARGV[0]
@region=ARGV[1]

input_hash = JSON.parse(File.read("reports/#{@account}-#{@region}.json"))

input_hash['VPC'].each do |vpc|
  vpcs=vpcs+1; 
  print "vpc #{vpcs} #{vpc['VpcId']} #{vpc['CidrBlock']}"
  if vpc['Tags']
    vpc['Tags'].each do |vpc_tags|
      print "  #{vpc_tags['Key']}:#{vpc_tags['Value']}\n"
    end
  end
  vpc['ELB'].each do |elb|
    elbs=elbs+1
    print "  ELB #{elbs} (#{elb['Scheme']}) #{elb['DNSName']}"
    if elb['Tags'] then
	elb['Tags'].each do |elb_tags|
          print "  #{elb_tags['Key']}:#{elb_tags['Value']}"
        end
    end 
    elb['ListenerDescriptions'].each do |listener|
      print "  #{listener['Listener']['Protocol']} #{listener['Listener']['LoadBalancerPort']} --> #{listener['Listener']['InstanceProtocol']} #{listener['Listener']['InstancePort']}"
    end
    print "\n"
    vpc['Subnets'].each do |subnet|
      elb['Instances'].each do |elbinstance|
        subnet['Instances'].each do |instance|
          if elbinstance['InstanceId'] == instance['InstanceId'] then
            if instance['Tags'] then
              instance['Tags'].each do |instance_tags|
                if instance_tags['Key'] == "Name" then
                  print "     #{instance_tags['Key']}:#{instance_tags['Value']}"
                end
              end
            end
            printf "      %-10.10s %-9.9s %-12.12s %-12.12s %-10.10s",subnet['AvailabilityZone'], instance['InstanceId'], instance['PrivateIpAddress'], instance['PublicIpAddress'], instance['InstanceType']
            print  "SGs: "
            instance["SecurityGroups"].each do |security_group|
              print"  #{security_group['GroupName']}"
            end
            print "\n" 
          end
        end
      end
    end
  end
  puts "INSTANCES DETAILS-------------------------------------------------------------------------"
  vpc['Subnets'].each do |subnet|
    subnet['Instances'].each do |instance|
      instances=instances+1
      #puts "     #{subnet['SubnetId']} #{subnet['CidrBlock']} #{subnet['AvailabilityZone']}"
      if instance['Tags'] then
        instance['Tags'].each do |instance_tags|
          if instance_tags['Key'] == "Name" then
            print "INSTANCE #{instances} #{instance_tags['Key']}:#{instance_tags['Value']}"
          end 
        end
      end
      print "\n"
      printf "    %-10.10s %-9.9s %-12.12s %-12.12s %-10.10s",subnet['AvailabilityZone'], instance['InstanceId'], instance['PrivateIpAddress'], instance['PublicIpAddress'], instance['InstanceType']
      print  "SGs: "
      instance["SecurityGroups"].each do |security_group|
        print"  #{security_group['GroupName']}"
      end
      print "\n"
      system ("cat hosts/#{@account}/#{@region}/netcon-#{instance['PrivateIpAddress']}")
      puts "---------------------------------------------------------------------------------------------------------------------------------" 
    end
  end
  vpc['RDS'].each do |rds|
    rdscount=rdscount+1
    puts "  #{rdscount} RDS #{rds['DBInstanceIdentifier']}  #{rds['DBInstanceClass']}  #{rds['Engine']}"
  end
end
