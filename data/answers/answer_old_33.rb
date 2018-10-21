require 'json'
settings = {'lang' => 'Ruby', 'text_editor' => 'Pico'}
File.write("./settings.json", settings.to_json)
again_raw = File.read("./settings.json")
again = JSON.parse(again_raw)
puts "The 'lang' is #{again['lang']}."
system 'rm ./settings.json'


#####################################


