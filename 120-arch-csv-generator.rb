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
  vpc['Subnets'].each do |subnet|
    subnet['Instances'].each do |instance|
      instances=instances+1
      if instance['Tags'] then
        instance['Tags'].each do |instance_tags|
          if instance_tags['Key'] == "Name" then
            print "\"#{instance['PrivateIpAddress']}\",\"#{instance_tags['Key']}:#{instance_tags['Value']}\""
          end 
        end
      end
      print ",\""
      system ("cat hosts/#{@account}/#{@region}/netcon-#{instance['PrivateIpAddress']} | sed 's|\"||g' | tr '\n' '     ' ")
      print "\"\n"
    end
  end
end
