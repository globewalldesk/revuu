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
  def wrap_items_with_numbers(arr, args = {})
    args[:enter_OK] ||= false
    args[:minus_mode] ||= false
    show_array_with_numbers(arr, args)
    choice = 0
    minus = false # Allows user to use this interface to delete from list.
    until ( choice.between?(1,arr.length) || (choice =~ /(\-)(\d+)/ &&
                                              $2.between?(1,arr.length))
          ) do
      or_enter = args[:enter_OK] ? 'or Enter ' : ''
      or_minus = args[:minus_mode] ? '; -# to remove' : ''
      puts "Choose a number (#{or_enter}or 'q' to quit#{or_minus}):"
      choice = get_user_command('r')
      return '' if choice == '' && args[:enter_OK]
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
  def show_array_with_numbers(arr, args = {})
    args[:colored] ||= false # Used in color-coding file names.
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
      item = args[:colored] ? colored(item) : item
      print item
    end
    print "\n\n"
  end

  # Takes a string from #show_array_with_numbers and colors it, if it
  # corresponds to a language type.
  def colored(item)
    Lang.defined_langs.each do |lang|
      ext = lang[:ext]
      if item =~ /( ?\(\d+\) )([\w\s]+\.#{ext} )$/
        return $1 + $2.colorize(lang[:color])
      end
      lname = lang[:name]
      if item =~ /( ?\(\d+\) )(#{lname} )$/
        return $1 + $2.colorize(lang[:color])
      end
    end
    return item # If no color matches.
  end

  # New, important method determines the directory within data/answers/ and
  # data/starters that a file goes in.
  # # Given an ID (string), return the directory (string) it goes in.
  # Returns in the form '00000/0000/000/00'.
  def determine_directory(id)
    id = id.to_s.split('').reverse.join
    # Supports up to ten thousands of answers.
    id =~ /^(\d)(\d?)(\d?)(\d?)(\d?)/
    tens = $2 == '' ? '0' : $2
    huns = $3 == '' ? '0' : $3
    thous = $4 == '' ? '0' : $4
    tthous = $5 == '' ? '0' : $5
    "#{tthous}0000/#{thous}000/#{huns}00/#{tens}0"
  end

  ##############################################################################
  # DATA MIGRATION
  # Until Revuu 3.2, all answers were held in a single directory, data/answers.
  # Now we are putting them all into nested folders based on thousands,
  # hundreds, and tens. Thus the user's answer for #32 will go in
  # data/answers/0000/000/30; answer #2485 in data/answers/2000/400/80.

  # Updates file locations for those few people who saved data from
  def update_file_locations
    # Make array of answer files.
    answers = Dir["data/answers/*"]
    starters = Dir["data/starters/*"]
    files = answers + starters
    files.each do |f|
      # Skip it if it doesn't match; if it does, extract its ID.
      next unless f =~ /(answer_|answer_old_|starter_)(\d+)\./
      # For each answer file, concatenate its proper directory.
      inner_location = determine_directory($2)
      # If the directory doesn't exist, create it.
      dir = if (f =~ /\/starter_/)
        "data/starters/#{inner_location}"
      else
        "data/answers/#{inner_location}"
      end
      p dir
      `mkdir -p #{dir}` unless File.directory?(dir)
      # Move the answer file to the directory.
      `mv #{f} #{dir}`
    end
  end

end

class String
  def color_text(r, g, b)
    "\033[38;2;#{r};#{g};#{b}m#{self}\u001b[0m"
  end

  def color_bg(r, g, b)
    "\033[48;2;#{r};#{g};#{b}m#{self}\u001b[0m"
  end
end
