class Dog
  attr_accessor :cute, :breed, :weight
  def initialize(args = {})
    args = defaults.merge(args)
    @cute =   args[:cute]
    @breed =  args[:breed]
    @weight = args[:weight]
  end

  def defaults
    {
      cute: false,
      breed: 'mutt',
      weight: 15
    }
  end

end
lassie = Dog.new(cute: true, breed: 'collie')
puts lassie.cute   # true
puts lassie.breed  # collie
puts lassie.weight # 15
rover = Dog.new
puts rover.breed




puts ''
#####################################


