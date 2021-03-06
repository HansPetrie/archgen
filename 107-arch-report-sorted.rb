#!/usr/bin/ruby

require 'json'
elbs=0;
vpcs=0;
instances=0;
rdscount=0;

@account=ARGV[0]
@region=ARGV[1]

input_hash = JSON.parse(File.read("reports/#{@account}-#{@region}.json"))

#Get a sorted list of Name tags
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
  IO.foreach("reports/tags-sorted-#{@account}-#{@region}.txt") do |line|
    vpc['Subnets'].each do |subnet|
      matchline = line.strip
      subnet['Instances'].each do |instance|
        #puts "     #{subnet['SubnetId']} #{subnet['CidrBlock']} #{subnet['AvailabilityZone']}"
        if !instance['Tags'] then 
          abort "FATAL ERROR NO TAG for #{instance_id}"
        end
        if instance['Tags'] then
          instance['Tags'].each do |instance_tags|
            if instance_tags['Key'] == "Name" then
              if instance_tags['Value'] == matchline then
                instances=instances+1
                print "#{instances} #{instance_tags['Value']}"
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
          end
        end
      end
    end
  end
  vpc['RDS'].each do |rds|
    rdscount=rdscount+1
    rdsip=`dig +short #{rds['Endpoint']['Address']} | head -1 | tr '\n' ' '` 
    puts "  #{rdscount} RDS #{rdsip} #{rds['Endpoint']['Address']}  #{rds['DBInstanceClass']}  #{rds['Engine']} Multi-AZ: #{rds['MultiAZ']}"
    puts "     #{rds['AvailabilityZone']}  #{rds['SecondaryAvailabilityZone']}"
  end
end
