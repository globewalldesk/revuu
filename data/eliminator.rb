require 'json'

# Need to edit this to delete nonstandard tags and to ensure there is 
# exactly one copy of a tag corresponding to the language name.

raw_data = File.read("revuu.json")
data = JSON.parse(raw_data)
puts data['tasks'][3]['lang']
data['tasks'].each do |task|
  task['lang'] = 'JavaScript' if task['lang'] == 'Node.js'
end
puts data['tasks'][3]['lang']
data = data.to_json
File.write("revuu.json", data)
