module TasklistView

  private

  # Displays a view of (part of) the task list to the user. Uses many methods
  # that only it calls. RF
  def display_tasks(first_screen=nil, message='')
    clear_screen unless first_screen
    print_header_for_tasklist_display
    list = prepare_tasklist_for_tasklist_display
    if ! list.empty?
      print_tasklist(list)
    else
      print "\nThere are no tasks yet. Press 'n' to add one or 'a'" +
            " to load archive.\n\n"
    end
    print_pagination_string_for_tasklist_display(list)
    print_help_text_for_tasklist_display
    puts message unless (message == '' || message == nil)
  end

  # Simply print the first couple lines of the task list (used only by
  # #display_tasks). RF
  def print_header_for_tasklist_display
    label_for_date_column = 'Due date' # By default except for history.
    if @filter_tag
      if @filter_tag == 'history'
        puts "> History <".center(75).colorize(:black).colorize(background: :light_yellow)
        label_for_date_column = 'Last reviewed'
      else
        puts "> Filtered by '#{@filter_tag}' <".center(75).colorize(background: :green)
      end
      puts
    end
    printf("%3s | %-49s| %-21s\n", ' #', 'Instructions (first line)',
      label_for_date_column)
    puts separator = '=' * 75
  end

  # Since #display_tasks can print different views of the user's task list, first
  # we must prepare a properly filtered, sorted tasklist. Returns list. RF
  def prepare_tasklist_for_tasklist_display
    # If the TaskList knows that the user has successfully searched for a tag,
    # then return the search results.
    @displayed_tasks = []
    list = (@filter_tag ? @tag_filtered_list : @list)
    unless @filter_tag == 'history'
      list.sort!{|x,y| DateTime.parse(x.next_review_date) <=>
          DateTime.parse(y.next_review_date)}
    end
    list
  end

  # Simply prints the tasklist. Requires tasklist; prints it for user. RF
  def print_tasklist(list)
    pindex = (@page_num - 1) * 10 # The list's array index to copy from.
    colored = true
    list = list[pindex, 10]
    list[0..10].each_with_index do |task, i|
      @displayed_tasks[i] = task # Used in switching to task view for a task.
      # Absolute insanity required to make the colors come out right.
      colorblock = " ".colorize(background: task.langhash.color)
      numstr = becolor(" #{i} | ", colored)
      lang_str = ('(' + task.lang + ') ').colorize(task.langhash.color)
      title_str = becolor(prepare_title_string(task, (task.lang.length+3)), colored)
      date_item = @filter_tag == 'history' ? task.all_reviews[-1]['review_date'] :
                  task.next_review_date
      time_str = becolor(sprintf("| %-21s",
                         prettify_timestamp(date_item)), colored)
      puts colorblock + numstr + lang_str + title_str + time_str
      #      (colored ? line.colorize(:green) : line) + "\n"
      #puts line.colorize(task.langhash.color)
      colored = !colored # Toggle green and white colors with each line.
    end
    puts separator = '=' * 75
  end

  def becolor(str, colored)
    colored ? str.colorize(:green) : str
  end

  # Given a task, prepare the title string that is shown in the tasklist
  # display. Requires the task, returns the string (title_str). RT
  def prepare_title_string(task, lang_length)
    # Grab the first 47 characters of the first line of @instructions.
    # First, add the language in parens and calculate how much space is left.
    limit = 47 - lang_length # Subtract length of the addition from title.
    # Prepare '...' at end of string if nec.
    line_1 = task.instructions.split("\n")[0][0..limit]
    line_1_avec_dots = line_1 == task.instructions.split("\n")[0] ?
      line_1 : line_1[0..-4] + '...'
    line_1_avec_dots + (' ' * (49 - line_1_avec_dots.length - lang_length))
  end

  # From a tasklist array, prepare (mostly) and show a string, e.g.:
  # [<<]top [<]back ...5 (6) 7... next[>] end[>>]       RF
  def print_pagination_string_for_tasklist_display(list)
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
      # Delete the nonexistent "page" above the last page.
      str.gsub!(") #{pnum + 1}", ')')
    end
    str = "Nav: " + str
    tcl = 69 - str.length
    task_count = sprintf("%#{tcl}s tasks", list.length)
    puts str + task_count
  end

  # Prints the help text that goes underneath the tasklist display. RF
  def print_help_text_for_tasklist_display
    asterisk = $unsaved_changes ? '*' : ''
    puts <<~HELPTEXT

    Commands are:
    [n]ew task  new [r]epo task  [1] view task #1  [l]ist all tasks
    show ne[x]t  [d]elete task  [t]ag search  [h]istory  [a]rchive data#{asterisk}
    set text [e]ditor  set [p]rogramming language  [de]stroy  [?] help

    HELPTEXT
  end

  # Get search term (tag) from user. RF
  def get_search_tag_from_user
    default_text = @default_tag.nil? ? '' :
      " (<enter> for '#{@default_tag}')"
    puts "Enter tag#{default_text}."
    get_user_command('t')
  end

  # Warns user & gets a number to delete from user; returns message. RF
  def confirm_delete
    print "WARNING! CANNOT UNDO!\nType number of task to delete or 'q' to escape: "
    num = gets.chomp
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
