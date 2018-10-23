cuber = Proc.new {|x| x**3}
puts cuber.call(3)
quadder = lambda {|x| x**4}
puts quadder.call(7)
sixer = -> (x) { x**6}
puts sixer.call(13)
