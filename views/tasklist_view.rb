module TasklistView

  # START HERE with refactoring
  def display_tasks(first_screen=nil, message='')
    clear_screen unless first_screen
    colored = false
    if @filter_tag
      print "   "
      puts "Filtered by '#{@filter_tag}'".colorize(background: :green)
    end
    printf("%2s | %-49s| %-21s\n", ' #', 'Instructions (first line)', 'Due date')
    puts separator = '=' * 75
    # If the TaskList knows that the user has successfully searched for a tag,
    # then display the search results here.
    list = (@filter_tag ? @tag_filtered_list : @list)
    list.sort!{|x,y| DateTime.parse(x.next_review_date) <=>
        DateTime.parse(y.next_review_date)}
    @displayed_tasks = []
    if ! list.empty?
      pindex = (@page_num - 1) * 10 # The array index to copy from.
      list = list[pindex, 10]
      list[0..10].each_with_index do |task, i|
        @displayed_tasks[i] = task # Used in switching to task view for a task.
        # Grab the first 45 characters of the first line of @instructions.
        # First, add the language in parens and calculate how much space this takes up.
        instr = '(' + task.lang + ') '
        limit = 47 - instr.length # Subtract length of the parenthetical addition from title
        # Prepare '...' at end of string if nec.
        line_1 = task.instructions.split("\n")[0][0..limit]
        task_str = line_1 == task.instructions.split("\n")[0] ?
          line_1 : line_1[0..-4] + '...'
        instr = instr + task_str
        line = sprintf("%2s | %-49s| %-21s", i, instr,
          prettify_timestamp(task.next_review_date))
        puts(colored ? line.colorize(:color => :green) : line)
        colored = !colored
      end
    else
      puts "\nThere are no tasks yet. Press 'n' to add one or 'a' to load archive.\n\n"
    end
    puts separator
    show_pagination_string
    ast = $unsaved_changes ? '*' : ''
    puts <<~HELP

    Commands are:
    [n]ew task  [1] review/edit task #1  [l]ist all tasks
    show ne[x]t  [d]elete task  [t]ag search  [a]rchive data#{ast}
    set text [e]ditor  set [p]rogramming language  [de]stroy  [h]elp

    HELP
    puts message unless (message == '' || message == nil)
  end

  # Get search term (tag) from user. RF
  def get_search_tag_from_user
    default_text = @default_tag.nil? ? '' :
      " (<enter> for '#{@default_tag}')"
    puts "Enter tag#{default_text}."
    get_user_command('t')
  end

  # Given @list (or @tag_filtered_list) & @page_num, prepare (mostly) and
  # show a string, e.g.: [<<]top [<]back ...5 (6) 7... next[>] end[>>]
  def show_pagination_string
    # Set 'list' equal to the tag-filtered list if a tag search is in use.
    list = @filter_tag ? @tag_filtered_list : @list
    # No pagination at all if list.length < 10.
    return '' if list.length < 10
    pnum = @page_num.dup         # The page number the user is on.
    last_pg = calculate_last_page_number(list)
    on_first = (pnum == 1 ? true : false)
    on_last = (pnum == last_pg ? true : false)
    # Print page number plus surrounding pages; remove stuff from this as nec.
    str = "[<<]top [<]back #{pnum - 1} (#{pnum}) #{pnum + 1} next[>] end[>>]"
    # Remove top/end if list.length < 21.
    if list.length < 21
      str.slice!('[<<]top ')
      str.slice!(' end[>>]')
    end
    # Remove top and back if on first page (pnum < 10).
    if on_first
      str.slice!('[<<]top ')
      str.slice!('[<]back ')
      # Show third page in list if it exists
      str.gsub!('(1) 2 ', '(1) 2 3 ') if last_pg > 2
      str.slice!('0 ')
    end
    # Remove next and end if on last page.
    if on_last
      str.slice!(' next[>]')
      str.slice!(' end[>>]')
      # If you're on p. 3 or up, you'll need to add a page before the penultimate page.
      str.gsub!('[<]back ', "[<]back #{pnum - 2} ") unless pnum < 3
      # Delete the "page" above the last page that doesn't exist.
      str.gsub!(") #{pnum + 1}", ')')
    end
    puts("Nav: " + str)
  end

  # Warns user & gets a number to delete from user; returns message. RF
  def confirm_delete
    print "WARNING! CANNOT UNDO!\nType number of task to delete: "
    num = gets.chomp.to_i
    # Receives back a message for the user or false if delete not successful.
    message = delete_task(num)
    return message
  end

  # Simply prompts the user (twice if there's unsaved data) to confirm that
  # he indeed wants to destroy all task data. RF
  def user_confirms_destruction
    # Explain what's happening.
    puts "\nTo \"destroy\" is to delete all tasks, i.e., erase everything loaded."
    # Get user confirmation or report status if there are unsaved changes.
    if $unsaved_changes
      puts "\nALERT! You have unarchived changes. Do you really want to do this?"
      puts 'Confirm with [y]es; all else quits this function.'
      command = get_user_command('de')
      return false unless command == 'y'
    else
      puts "\nLooks like you're ready; the currently-loaded data has been archived,"
      puts "so it can be easily reloaded from the [a]rchive system."
    end
    # Final confirmation.
    puts "\nWARNING! Are you ready to delete all tasks? LAST WARNING! Press [y]es or [n]o."
    command = get_user_command('de')
    return command == 'y' # Returns boolean.
  end

end
