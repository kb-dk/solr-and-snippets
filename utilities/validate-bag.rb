#!/usr/bin/env ruby

require 'bagit'

existing_base_path = ARGV[0]

bag = BagIt::Bag.new existing_base_path

if bag.valid?
  puts "#{existing_base_path} is valid"
else
  puts "#{existing_base_path} is not valid"

end
