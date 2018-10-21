cube = Proc.new {|x| x**3 }
puts cube.call(3) # 27
tothefourth = lambda {|x| x**4}
puts tothefourth.call(7)
tothesixth = -> (x) { x**6}
puts tothesixth.call(13)



###########################################################################


