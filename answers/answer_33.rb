require 'json'

config = {'lang' => 'Ruby', 'text_editor' => 'Pico'}
File.write("./config.json", config.to_json)
myf = File.read("./config.json")
puts "The lang is #{JSON.parse(myf)['lang']}"
system "rm ./config.json"