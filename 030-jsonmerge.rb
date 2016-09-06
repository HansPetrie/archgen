#!/usr/bin/ruby

require 'json'
require 'yaml'

@profile=ARGV[0]
@region=ARGV[1]
@filepath=ARGV[2]

vpc_hash = JSON.parse(File.read("#{@filepath}/#{@profile}-#{@region}-ec2-describe-vpcs"))
subnet_hash = JSON.parse(File.read("#{@filepath}/#{@profile}-#{@region}-ec2-describe-subnets"))
reservation_hash = JSON.parse(File.read("#{@filepath}/#{@profile}-#{@region}-ec2-describe-instances"))
security_group_hash = JSON.parse(File.read("#{@filepath}/#{@profile}-#{@region}-ec2-describe-security-groups"))
elb_hash = JSON.parse(File.read("#{@filepath}/#{@profile}-#{@region}-elb-describe-load-balancers"))
rds_hash = JSON.parse(File.read("#{@filepath}/#{@profile}-#{@region}-rds-describe-db-instances"))

instance_array = Array.new
instance_hash = Hash.new

reservation_hash['Reservations'].each do |reservation|
  reservation['Instances'].each do |instance|
    instance_array.push(instance)
  end
end

instance_hash=instance_hash.merge({"Instances" => instance_array})
vpc_array = Array.new

vpc_hash['Vpcs'].each do |vpc|
  elbs_in_vpc = elb_hash['LoadBalancerDescriptions'].select { |key, hash| key["VPCId"] == vpc['VpcId'] } 
  merged = vpc.merge({:ELB => elbs_in_vpc})
  puts vpc["Vpc_Id"]
  rds_array = Array.new 
  rds_hash['DBInstances'].each do |db_instance|
    if db_instance['DBSubnetGroup']['VpcId'] == vpc['VpcId'] then 
	rds_array.push(db_instance)	
    end
  end
  merged = merged.merge({:RDS => rds_array})
  subnets_in_vpc = subnet_hash['Subnets'].select { |key, hash| key["VpcId"] == vpc['VpcId'] } 
  subnet_array = Array.new 
  subnets_in_vpc.each do |subnet|
    instances_in_subnet = instance_hash['Instances'].select { |key, hash| key['SubnetId'] == subnet['SubnetId'] }
    subnet_merged = subnet.merge({:Instances => instances_in_subnet})
    subnet_array.push(subnet_merged)
  end
  merged = merged.merge({:Subnets => subnet_array})
  vpc_array.push(merged)
end

#Put everything in one big hash and output
output_hash = Hash.new
output_hash = output_hash.merge({:VPC => vpc_array})
puts output_hash.to_json

#To print in yaml
#puts output_hash.to_yaml
