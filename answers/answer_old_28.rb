friends = ['Jack', 'Jill', 'Sam']
def yo(greet, *friends)
  friends.each { |friend| puts "#{greet}, #{friend}!" }
end
yo("Hi", *friends)

arr = ['a', 'b', 'c', 'd']
first, *the_rest = arr
puts "I really like #{first}, but as to #{the_rest.join(', ')}...they're OK."


#####################################


friends = ['Jack', 'Jill', 'Sam']
def yo(greet, *friends) # This assigns greet and doesn't care how many are left;
                        # it collects them all together into a single array.
  friends.each { |friend| puts "#{greet}, #{friend}!" }
end
yo('Yo', *friends); # Here, you're passing each item individually; four args.

arr = ['a', 'b', 'c', 'd']
first, *the_rest = arr      # Again, this collects the_rest into an array.

puts "I like #{first}, but as to #{the_rest.join(', ')}...they're OK."



#####################################


