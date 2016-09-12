#!/usr/bin/ruby

require 'json'

@filepath=ARGV[0]

input_hash = JSON.parse(File.read("#{@filepath}"))

input_hash['VPC'].each do |vpc|
  puts "-----------------------"
  print "#{vpc['VpcId']} #{vpc['CidrBlock']}"
  if vpc['Tags']
    vpc['Tags'].each do |vpc_tags|
      print "#{vpc_tags['Key']}:#{vpc_tags['Value']} "
    end
  end
  print "\n"
  vpc['Subnets'].each do |subnet|
    puts "--#{subnet['SubnetId']} #{subnet['CidrBlock']} #{subnet['AvailabilityZone']}"
    subnet['Instances'].each do |instance|
      if instance['Tags'] then
        instance['Tags'].each do |instance_tags|
          if instance_tags['Key'] == "Name" then
            if instance_tags['Value'] == "" then 
              puts "    ? No Tag"
            else
              puts "    #{instance_tags['Value']}"
            end
          end
        end
      end
    end
  end
end
