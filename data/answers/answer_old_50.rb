arr  = *(-10..10)
pos = []
neg = []
arr.each do |n|
  case n <=> 0
  when 1
    pos << n
  when -1
    neg << n
  end
end
p pos
p neg



puts ''
#####################################


