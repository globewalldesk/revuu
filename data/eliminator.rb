require 'json'
# Need to edit this to delete nonstandard tags and to ensure there is 
# exactly one copy of a tag corresponding to the language name.

raw_data = File.read("revuu.json")
data = JSON.parse(raw_data)
puts "yo"
data['tasks'].each do |task|
  task['tags'].reject! {|tag| %q(JavaScript node Node Node.js Bash bash Java java Ruby ruby C c).include? tag } if task['tags']
end
puts data['tasks'][6]['tags']
puts "yo"
data = data.to_json
File.write("revuu.json", data)
