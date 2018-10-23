class Integer
  def factorial_minus_triangle
    x = (1..self).reduce(1, :*) # factorial
    y = self == 1 ?             # triangle
      1 : (1..self).reduce(1, :+)
    x - y
  end
end

puts 1.respond_to?(:factorial_minus_triangle)
10.times {|n| print "#{n.factorial_minus_triangle} "}
