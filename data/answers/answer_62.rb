az = [*('a'..'g')]
nums = [*(1..10)]

class Array
  def each_odd
    self.map!.each_with_index {|e,i| i.odd? ? yield(e) : e}
  end
end

p az.each_odd {|x| x.upcase }
p nums.each_odd {|x| x*2}
