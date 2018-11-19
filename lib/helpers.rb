module Helpers

  # NOTE: move some methods to settings_helper.rb and some to help_helper.rg

  # Clear screen and print header. Used throughout the app. RF
  def clear_screen
    system("clear")
    header
  end

  # Used in clear_screen above. RF
  def header
    puts sprintf("%-69s%s", " * R * E * V * U * U *",  "v. 3.1").
      colorize(:color => :black, :background => :white)
    puts ''
  end

  def get_user_command(leader)
    extra_space = ( ("=+a".include? (leader)) ? "" : "  ")
    print "#{extra_space}#{leader}> "
    gets.chomp
  end

  # This is copied into new Java answers. Used throughout class Task.  RF
  def java_starter
    return <<~JAVASTARTER
      public class answer_#{@id} {
          public static void main(String[] args) {
              /* do not edit 'answer_<id>' */
          }
      }
      JAVASTARTER
  end

  # Given an array, show it with numbers (separate method) and solicit and
  # return the element corresponding to the user choice (or nil if user quits).
  def wrap_items_with_numbers(arr, enter_OK = false, minus_mode = false)
    show_array_with_numbers(arr)
    choice = 0
    minus = false # Allows user to use this interface to delete from list.
    until ( choice.between?(1,arr.length) || (choice =~ /(\-)(\d+)/ &&
                                              $2.between?(1,arr.length))
          ) do
      or_enter = enter_OK ? 'or Enter ' : ''
      or_minus = minus_mode ? '; -# to remove' : ''
      puts "Choose a number (#{or_enter}or 'q' to quit#{or_minus}):"
      choice = get_user_command('r')
      return '' if choice == '' && enter_OK
      return 'q' if choice == 'q'
      # If user inputs something of the form '-#' (e.g., '-2') then handle
      # specially.
      if choice =~ /(\-)(\d+)/
        choice = $2.to_i
        return choice, true # true = This is a removal.
      else
       choice = choice.to_i
      end
    end
    chosen_item = arr[choice-1]
  end

  # Display an array in (1) format (2) like (3) this, wrapped.
  def show_array_with_numbers(arr)
    # FOR LATER: EITHER PUT THE MOST RECENT ON THE TOP OR MAKE DEFAULT with *.
    # Actually do the displaying. Note, available_editors is a method.
    width = 0
    arr.each_with_index do |element,i|
      item = "(#{i+1}) #{element} " # Works with paths...
      # Decide whether to wrap (add newline).
      if item.length + width >= 75
        puts('')
        width = 0
        item = '  ' + item # Add padding to wrapped item.
      end
      # Add padding to first item.
      (item = '  ' + item) if i == 0
      # Always adds to line length and prints item.
      width += item.length
      print item
    end
    print "\n\n"
  end


end
