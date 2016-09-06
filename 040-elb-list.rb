#!/usr/bin/ruby

require 'json'

@filepath=ARGV[0]

input_hash = JSON.parse(File.read("#{@filepath}"))

input_hash['VPC'].each do |vpc|
  vpc['ELB'].each do |elb|
    #print "  ELB(#{elb['Scheme']}) #{elb['DNSName']}\n"
    print "#{elb['DNSName']}\n"
  end
end
