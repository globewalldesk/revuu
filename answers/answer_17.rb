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
