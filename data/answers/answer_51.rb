require 'colorize'
az = [*('a'..'z')]
az.sort! { |x, y| x <=> y }
puts az[0] #=> a
az.sort! { |x, y| y <=> x }
puts az[0] #=> z
puts('a' <=> 'b') #=> -1 because a is "smaller" than b.
32.upto(126) { |x| print("#{x.chr}".colorize(background: :green), " ") }
puts ''
puts("'#{32.chr}'    '#{123.chr}'") #=> Not sure...
puts(32.chr <=> 123.chr) #=> -1 because the lower character has a smaller id.
# Places the lower-valued items first, not last; and 'a' is lower-valued than 'z'.
