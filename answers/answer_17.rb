numbers = []
three_ones = [1, 1, 1]
10.times do |i|
  next unless i.odd?
  numbers << i
  redo unless (numbers == three_ones || numbers.length > 3)
  i += 1
  break if i == 10
end
print numbers
puts ''
