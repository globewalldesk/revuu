require 'date'

now = DateTime.now
puts now.to_s

date = (now + 7).strftime("%-m/%-d/%Y")
puts "In a week it will be #{date}."
time = (now + 2/24.0).strftime("%-I:%M %p")
puts "In two hours it will be #{time}."



puts ''
#####################################


