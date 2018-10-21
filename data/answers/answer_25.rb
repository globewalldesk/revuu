dog_breeds = {
  'Fido' => 'poodle',
  'Rover' => 'golden retriever',
  'Lucky' => 'black lab'
}
dog_breeds.default = 'mutt'
%w[Fido Funny Rover Lucky Bozo].each do |name|
  puts "#{name}: #{dog_breeds[name]}"
end