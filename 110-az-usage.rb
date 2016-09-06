#!/usr/bin/ruby

require 'json'

@filepath=ARGV[0]

input_hash = JSON.parse(File.read("#{@filepath}"))

input_hash['VPC'].each do |vpc|
  vpc['Subnets'].each do |subnet|
    subnet['Instances'].each do |instance|
	if instance['Tags'] then
          instance['Tags'].each do |instance_tags|
            if instance_tags['Key']=="Name" then
              print "#{subnet['AvailabilityZone']} #{instance_tags['Key']}:#{instance_tags['Value']} \n"
            end
          end
        end
    end
  end
end
