az = [*('a'..'g')]
nums = [*(1..10)]

class Array
  def each_odd
    self.each_with_index.map {|x,i| i.odd? ? yield(x) : x }
  end
end
p az.each_odd {|x| x.upcase }
p nums.each_odd {|x| x * 2 }

# This abbreviates:
p az.each_with_index.map { |x,i| i.odd? ? x.upcase : x }
p nums.each_with_index.map { |x,i| i.odd? ? x * 2 : x }
