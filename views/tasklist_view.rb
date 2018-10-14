module TasklistView

  def display_tasks(first_screen=nil)
    clear_screen unless first_screen
    colored = false
    if @default_tag
      print "   "
      puts "Filtered by '#{@default_tag}'".colorize(background: :green)
    end
    printf("%5s | %-47s| %-20s\n", 'ID', 'Instructions (first line)', 'Due date')
    puts separator = '=' * 75
    # If the TaskList knows that the user has successfully searched for a tag,
    # then display the search results here.
    list = (@default_tag ? @tag_filtered_list : @list)
    list.sort!{|x,y| DateTime.parse(x.next_review_date) <=>
        DateTime.parse(y.next_review_date)}
    if ! list.empty?
      pindex = (@pagination_num - 1) * 10 # The array index to copy from.
      list = list[pindex, 10]
      list[0..10].each do |task|
        # Grab the first 45 characters of the first line of @instructions.
        # First, add the language in parens and calculate how much space this takes up.
        instr = '(' + task.lang + ') '
        limit = 45 - instr.length # Subtract length of the parenthetical addition from title
        instr = instr + task.instructions[0..limit].split("\n")[0]
        line = sprintf("%5s | %-47s| %-20s", task.id, instr,
          prettify_timestamp(task.next_review_date))
        puts(colored ? line.colorize(:color => :green) : line)
        colored = !colored
      end
    else
      puts "\nThere are no tasks yet. Press 'n' to add one.\n\n"
    end
    puts separator
    show_pagination_string
    puts help
    puts ''
  end

  def help 
    <<-HELP

Commands are:
[n]ew task  [1] review/edit task #1  show ne[x]t  [l]ist all tasks  [h]elp
[d]elete task  [t]ag search  set text [e]ditor  set [p]rogramming language 
HELP
  end

  # Get search term (tag) from user.
  def get_search_tag_from_user
    default_text = @old_tag.nil? ? '' :
      " (<enter> for '#{@old_tag}')"
    puts "Enter tag#{default_text}."
    get_user_command('t')   # Used as 'tag' in controller.
  end

  # Given @list (or @tag_filtered_list) & @pagination_num, prepare (mostly) and
  # show a string, e.g.: [<<]top [<]back ...5 (6) 7... next[>] end[>>]
  def show_pagination_string
    # Set 'list' equal to the tag-filtered list if a tag search is in use.
    list = @default_tag ? @tag_filtered_list : @list
    # No pagination at all if list.length < 10.
    return '' if list.length < 10
    pnum = @pagination_num.dup         # The page number the user is on.
    last_pg = get_last_page(list)
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
    puts("   " + "Nav: " + str)
  end


end