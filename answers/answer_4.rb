class MyClass
  class << self
    def my_class_method
      puts "You successfully called my class method! Woo hoo!"
    end

    def my_other_class_method
      puts "Oh my god you did it twice!"
    end
  end
end

MyClass.my_class_method
MyClass.my_other_class_method
