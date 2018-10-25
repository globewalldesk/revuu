arr = *(-10..10)
pos = []
saame = []
neg = []
arr.each do |n|
  case 0 <=> n
  when 1
    neg << n
  when 0
    saame << n
  when -1
    pos << n
  end
end
p neg
p saame
p pos