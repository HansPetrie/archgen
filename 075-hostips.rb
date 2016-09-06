#!/usr/bin/ruby

require 'json'

@filepath=ARGV[0]

input_hash = JSON.parse(File.read("#{@filepath}"))

input_hash['VPC'].each do |vpc|
  vpc['Subnets'].each do |subnet|
    subnet['Instances'].each do |instance|
      if instance['State']['Name']=="running" then
        puts "#{instance['PrivateIpAddress']}"
      end
    end
  end
end
