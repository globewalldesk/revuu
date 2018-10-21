cubed = Proc.new {|x| x**3}
puts cubed.call(3)
fourth = lambda {|x| x**4}
puts fourth.call(7)
sixth = -> (x) {x**6}
puts sixth.call(13)
