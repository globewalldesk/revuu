class OldClass
  def old_method
    warn "Don't use this old method. Use NewClass#new_method instead."
    puts "By Jove!"
  end
end

class NewClass
  def new_method
    puts "Swag!"
  end
end

$VERBOSE = nil
OldClass.new.old_method
