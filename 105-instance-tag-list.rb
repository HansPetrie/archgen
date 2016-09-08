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
  vpc['Subnets'].each do |subnet|
    subnet['Instances'].each do |instance|
      if instance['Tags'] then
        instance['Tags'].each do |instance_tags|
          if instance_tags['Key'] == "Name" then
            puts "#{instance_tags['Value']}"
          end 
        end
      end
    end
  end
end
