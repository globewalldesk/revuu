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
