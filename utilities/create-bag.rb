#!/usr/bin/env ruby

require 'bagit'

base_path = ARGV[0]

# make a new bag at base_path
bag = BagIt::Bag.new base_path

# make a new file
bag.add_file("samplefile") do |io|
  io.puts "Hello Bag!"
end

# generate the manifest and tagmanifest files
bag.manifest!
