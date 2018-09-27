arr = ['xanax', 'hello', 'aya', 'foobar']

def pal?(string)
  string.reverse == string
end

puts arr.count { |x| pal?(x) }
puts arr.select { |x| pal?(x) }.inspect
puts arr.map!(&:capitalize).inspect
puts arr.map!(&:upcase).inspect
puts arr.map!(&:downcase).inspect
