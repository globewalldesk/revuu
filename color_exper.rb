# Support for 256 colors
# in Linux terminals.
class Colorizer256

  def foreground_color_test_pattern
    0.upto(15) do |i|
      puts
      0.upto(15) do |j|
        self.set_foreground_color(i * 16 + j)
            .print_str("#{i * 16 + j} ")
            .reset
      end
    end
  end

  def background_color_test_pattern
    0.upto(15) do |i|
      puts
      0.upto(15) do |j|
        self.set_background_color(i * 16 + j)
            .print_str("#{i * 16 + j} ")
            .reset
      end
    end
  end

  def set_foreground_color(id)
    print "\u001b[38;5;#{id}m"
    self
  end

  def set_background_color(id)
    print "\u001b[48;5;#{id}m"
    self
  end

  def print_str(str)
    print str
    self
  end

  def puts_str(str)
    puts str
    self
  end

  def reset
    print "\u001b[0m"
    self
  end

end
system("clear")
puts "=================="
puts "== Color Tester =="
puts "=================="
colorize = Colorizer256.new
colorize.foreground_color_test_pattern
puts "\n=============================="
colorize.background_color_test_pattern
puts "\n=============================="
print "Enter foreground color: "
foreground_color = gets.chomp.to_i
print "Enter background color: "
background_color = gets.chomp.to_i
print "Enter text to colorize: "
to_colorize = gets.chomp
colorize.set_foreground_color(foreground_color)
        .set_background_color(background_color)
        .puts_str(to_colorize)
        .reset
