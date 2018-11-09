module Helpers

  # NOTE: move some methods to settings_helper.rb and some to help_helper.rg

  def clear_screen
    system("clear")
    header
  end

  def header
    puts sprintf("%-69s%s", " * R * E * V * U * U *",  "v. 2.5").
      colorize(:color => :black, :background => :white)
    puts "\n"
  end

  def get_user_command(leader)
    extra_space = ( ("=+a".include? (leader)) ? "" : "  ")
    print "#{extra_space}#{leader}> "
    gets.chomp
  end

end
