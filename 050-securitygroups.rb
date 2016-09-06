#!/usr/bin/ruby

require 'json'

@filepath=ARGV[0]

input_hash = JSON.parse(File.read("#{@filepath}"))

input_hash['SecurityGroups'].each do |sg|
  puts "-----------------------"
  puts "#{sg['GroupName']} #{sg['Description']}"
  sg['IpPermissions'].each do |perm|
    puts "#{perm['FromPort']} to #{perm['ToPort']} #{perm['IpProtocol']}"
    perm['IpRanges'].each do |ip|
      puts "   CIDR: #{ip['CidrIp']}"
    end

    perm['UserIdGroupPairs'].each do |group|
      puts "   GROUP: #{group['GroupId']}  #{group['UserId']} #{group['GroupName']}"
    end
  end  
end
