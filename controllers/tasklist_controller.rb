module TasklistController

  # This is the top-level app loop. It's here rather than in App because most
  # of its functions concern the Tasklist. RF
  def app_loop
    command = nil
    until command == 'q'
      command = get_user_command('=')
      process_tasklist_input(command)
      return if $view_archive # Escape from TaskList when user requests archive.
    end
    puts ''
    puts "You have unarchived (un-backed up) changes, but your data is saved." if
      $unsaved_changes
    puts "Goodbye until next time!"
  end

  # Dispatch table for tasklist (and options, archive, and task view launch).
  # Typically (not always) redisplays tasks after executing some function. RF
  def process_tasklist_input(command)
    # A 'message' (or nil) is returned by most of these functions, and then
    # passed off to TasklistView::display_tasks
    message = case command.downcase
    when '>', '.'
      nav('next')
    when '<', ','
      nav('back')
    when '>>', '..'
      nav('end')
    when '<<', ',,'
      nav('top')
    when 'n'
      task = Task.generate_new_task
      task ? "New task saved." : "Task input abandoned or failed."
    when /\A(\d+)\Z/
      task = fetch_task_from_displayed_number($1.to_i)
      task ? (task.edit) : "Task not found."
    when 'l'
      prep_to_show_all_tasks # Clears @default_tag and stops filtering.
    when 'x'
      edit_next_item
    when 'd'
      confirm_delete
    when 't'
      tag_search
    when 'a'
      $view_archive = true # Used in revuu.rb: App#initialize.
      return
    # START HERE--START REVIEWING METHODS USED FROM HERE
    when 'e'
      choose_text_editor
    when 'p'
      choose_default_language
    when 'de'
      destroy_all
    when 'h', '?'
      launch_instructions_system
    when 'q'
      return
    else
      puts 'Huh?'
      no_refresh = true
    end
    # Note, no_refresh is declared only after 'else' above.
    clear_screen unless no_refresh
    # Note, 'message' is the return value of the 'case' block above.
    display_tasks(false, message) unless no_refresh
  end

  # Given where to navigate, set the page num to reflect the change. RF
  def nav(where)
    # Decide whether to use all tasks or a filtered subset.
    list = @filter_tag ? @tag_filtered_list : @list
    return '' if list.length < 10 # Nav not possible; too few tasks.
    last_pg = calculate_last_page_number(list)
    on_first = (@page_num == 1)
    on_last = (@page_num == last_pg)
    case where
    when 'top'
      @page_num = 1
    when 'back'
      @page_num = (on_first ? 1 : @page_num - 1 )
    when 'next'
      @page_num = (on_last ? last_pg : @page_num + 1)
    when 'end'
      @page_num = last_pg
    end
    nil # No dispatch table message.
  end

  # Given a task list, calculate and return the # of last page to display. RF
  def calculate_last_page_number(list)
    last_pg = (list.length/10.0).floor + 1
    # This gets rid of an empty page when user has multiples of 10.
    last_pg -= 1 if (list.length/10.0) == (list.length/10)
    last_pg
  end

  # Simply clears the filter tag and tag-filtered list; will cause the whole
  # list to be displayed on re-display of tasks. RF
  def prep_to_show_all_tasks
    @filter_tag = nil
    @tag_filtered_list = []
    nil # No dispatch table message.
  end

  # Simply opens the item with the earliest review date to edit. RF
  def edit_next_item
    list = @filter_tag ? @tag_filtered_list : @list
    list[0].edit
    nil # No dispatch table message.
  end

  # Get user input for searching tasks by tag; return just matching tasks. RF
  def tag_search
    # Prepare arrays of tasks containing tags.
    tag_hash = prepare_hash_of_tag_arrays
    if tag_hash.empty?
      return "No tags found."
    end
    tag = get_search_tag_from_user
    # If default tag exists and user hit <enter> alone, use default tag.
    if (!@default_tag.nil? && tag == '')
      tag = @default_tag
    end
    tag_match = tag_hash.keys.find { |k| tag.downcase == k.downcase }
    # Display results. If not found, say so.
    if tag_match
      # Assign default tag to input. This does double duty as boolean
      # indicating whether the current tasklist display is filtered or not.
      @filter_tag = tag_match
      @default_tag = @filter_tag.dup
      @page_num = 1
      # Save sorted array of tasks filtered by this tag.
      @tag_filtered_list = tag_hash[tag_match]
      return ''
    else
      return "'#{tag}' not found."
    end
  end

  # For use in tag search: a hash where keys = tags while values = tasks. RF
  def prepare_hash_of_tag_arrays
    tag_hash = {}
    list.each do |task|
      next unless task.tags
      task.tags.each do |tag|
        tag_hash[tag] = [] unless tag_hash[tag]
        tag_hash[tag] << task
      end
    end
    tag_hash
  end

  # Given an integer, return a task from the tasklist. RF
  def fetch_task_from_displayed_number(num)
    @displayed_tasks[num]
  end

end
