class Dog
  attr_accessor :cute, :breed, :weight
  def initialize(args)
    @cute   = args[:cute]   || false
    @breed  = args[:breed]  || 'mutt'
    @weight = args[:weight] || 15
  end
end
lassie = Dog.new(cute: true, breed: 'collie')
puts lassie.cute   # true
puts lassie.breed  # collie
puts lassie.weight # 15
rover = Dog.new
puts rover.breed   # mutt
