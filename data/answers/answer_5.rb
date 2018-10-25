class MyClass
  class << self
    def class_number; 5; end

    def class_number_deux; 2; end

    def create_with_num
      num = self.class_number
      self.new(number: num)
    end
  end

  attr_accessor :number

  def initialize(args)
    @number = args[:number]
  end

  def instance_number; 10; end

  def my_sum
    @number + self.class.class_number_deux + instance_number + global_number
  end

end

def global_number; 10; end
fred = MyClass.create_with_num
p fred.my_sum 
