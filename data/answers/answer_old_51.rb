az = *('a'..'z')
az.sort! { |x,y| x <=> y }
puts az[0] # 'a'
az.sort! { |x,y| y <=> x }
puts az[0] # 'z'
az.sort!
puts az[0] # 'a'
puts ('a' <=> 'b') # -1
[*(32..127)].each {|n| print "#{n.chr} "}
puts ''
puts (38.chr <=> 124.chr)



puts ''
#####################################


