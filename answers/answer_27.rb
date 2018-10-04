mountains = {
  'Mount Everest' => 29029,
  'K2' => 28251,
  'Kangchenjunga' => 28169,
  'Lhotse' => 27940,
  'Makalu' => 27838,
  'Cho Oyo' => 26864,
  'Dhaulagiri I' => 26795
}

def print_table(arr)
  arr.each {|d| printf("%-15s%d\n", d[0], d[1]) }
end

mountains = mountains.sort_by {|k,v| k}
print_table(mountains)
puts ''
mountains = mountains.sort_by {|k,v| -v}
print_table(mountains)
puts ''
mountains = mountains.sort {|x,y| x[0] <=> y[0] }
print_table(mountains)
puts ''
mountains = mountains.sort {|x,y| y[1] <=> x[1] }
print_table(mountains)
