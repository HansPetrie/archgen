#!/usr/bin/ruby

require 'json'

@account=ARGV[0]
@region=ARGV[1]

input_hash = JSON.parse(File.read("awsreport/#{@account}-#{@region}-ec2-describe-network-interfaces"))
instance_hash = JSON.parse(File.read("awsreport/#{@account}-#{@region}-ec2-describe-instances"))

input_hash['NetworkInterfaces'].each do |net|
  print "#{net['PrivateIpAddress']}" 
  #print " #{net['Attachment']['InstanceId']}\n"
  instance_hash['Reservations'].each do |reservation|
    reservation['Instances'].each do |instance|
      if net['Attachment'] then
       if net['Attachment']['InstanceId'] == instance['InstanceId'] then
         instance['Tags'].each do |tag|
            if tag['Key'] == "Name" then
              print " \"#{tag['Value']}\""
#              print " \"#{tag['Key']}: #{tag['Value']}\""
            end
         end
       end
      end
    end
  end
  if net['Description'] != "Primary network interface" && net['Description'] != "" then
     print " \"#{net['Description']}\""
  end
  print "\n"
end
