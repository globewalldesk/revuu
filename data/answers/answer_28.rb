def yo(greet, *friends)
  friends.each { |friend| puts "#{greet}, #{friend}!" }
end
friends = ['Jack', 'Jill', 'Sam']
yo("Yo", *friends)

first, *the_rest = ['a', 'b', 'c', 'd']
puts "I really like #{first}, but as to #{the_rest.join(', ')}...they're OK."