require 'date'
moment = DateTime.now
p moment.to_s
moment += 7
puts "In a week it will be #{moment.strftime("%-m/%-d/%Y")}."
moment2 = DateTime.now + (2.0/24)
puts "In two hours it will be #{moment2.strftime("%-H:%M %p")}."