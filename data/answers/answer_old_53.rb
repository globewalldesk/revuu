sim = :symbol
simeq = sim
print sim.object_id
print ' '
print simeq.object_id # Obv. the same
puts ''

str = 'yo'
str2 = str
print str.object_id
print ' '
print str2.object_id # Same
print ' '
str3 = 'yo'
print str3.object_id # Defo diff
puts ''

num = 1
num2 = num
print num.object_id
print ' '
print num2.object_id # Same
print ' '
num3 = 1
print num3.object_id # Same
puts ''

puts "arr:"
arr = [0, 1, 2]
arr2 = arr
print arr.object_id
print ' '
print arr2.object_id # Defo same
print ' '
arr3 = [0, 1, 2]
print arr3.object_id # Difo diff
puts ''

simd = sim.dup
simc = sim.clone
puts "#{simd.object_id} #{simc.object_id}" # Obvs same.

strd = str.dup
strc = str.clone
puts "#{strd.object_id} #{strc.object_id}" # ? Turns out to be diff!

arrd = arr.dup
arrc = arr.clone
puts "#{arrd.object_id} #{arrc.object_id}" # ?? Turns out to be diff!



puts ''
#####################################


