friends = ['Jack', 'Jill', 'Sam']
def yo(greet, *friends)
  friends.each { |friend| puts "#{greet}, #{friend}!" }
end
yo("Hi", *friends)

arr = ['a', 'b', 'c', 'd']
first, *the_rest = arr
puts "I really like #{first}, but as to #{the_rest.join(', ')}...they're OK."