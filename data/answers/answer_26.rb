names = [
  { firstname: 'John', lastname: 'Doe' },
  { firstname: 'Jane', lastname: 'Roe' },
  { firstname: 'Jack', lastname: 'Sprat' },
  { firstname: 'Holly', lastname: 'Golightly' },
  { firstname: 'Santa', lastname: 'Claus' }
]

def print_table(arr)
  arr.each {|name| puts "#{name[:lastname]}, #{name[:firstname]}" }
end

names = names.sort_by do |pers|
  pers[:firstname]
end
print_table(names)
puts ''

names = names.sort_by do |pers|
  pers[:lastname]
end
print_table(names)

puts ''

names = names.sort do |x,y|
  x[:firstname] <=> y[:firstname]
end
print_table(names)
puts ''
names = names.sort do |x,y|
  x[:lastname] <=> y[:lastname]
end
print_table(names)
