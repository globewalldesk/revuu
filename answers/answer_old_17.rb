numbers = []
three_ones = [1, 1, 1]
10.times do |i|
# next, redo, break
  next if i%2 == 0
  numbers << i
  redo if i < 2 and numbers != three_ones
  i += 1
  break if i > 9
end
print numbers
puts ''



#####################################


numbers = []
three_ones = [1, 1, 1]
10.times do |i|
  next if i%2 == 0
  numbers << i
  redo unless numbers == three_ones or i > 1
  i += 1
  break if i == 10
end
print numbers
puts ''



#####################################


