dog_breeds = {Lassie:  'collie', Rex: 'German shepherd', Fido: 'cocker spaniel'}
dog_breeds.default = 'mutt'
names = [:Lassie, :Peaches, :Rex, :Old_Yeller, :Fido]
names.each do |name|
  puts "#{name.to_s}: #{dog_breeds[name]}"
end
