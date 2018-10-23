foo = :george
bar = foo
puts "#{foo.object_id} =? #{bar.object_id}" # Obvs true.
str = 'hi'
str2 = str
puts "#{str.object_id} =? #{str2.object_id}" # Thought false; but true.
str = 'yo'
puts str2
puts "#{str.object_id} =? #{str2.object_id}" # Not sure; but false.
str3 = 'hi'
str4 = 'hi'
puts "#{str3.object_id} =? #{str4.object_id}" # Obvs false.
arr = [1,2,3]
arr2 = arr
puts "#{arr.object_id} =? #{arr2.object_id}" # Obvs true.
arr[1] = 'a gazillion'
p arr2 # [1, 'a gazillion', 3]
hashy = {foo: 1, bar: 2}
hashy2 = hashy
puts "#{hashy.object_id} =? #{hashy.object_id}" # Obvs true.
hashy[:foo] = 123
p hashy2 # Defo changed
arr = [1,2,3]
arrdup = arr.dup
arrclone = arr.clone
arr[2] = 'a godawful lot'
p arr # changed
p arrdup # unchanged
p arrclone # unchanged
