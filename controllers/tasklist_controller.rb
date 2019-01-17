module TasklistController

  private

  # This is the top-level app loop. It's here rather than in App because most
  # of its functions concern the Tasklist. RF
  def app_loop
    command = nil
    until command == 'q'
      # The 'auto next' system loads the next task automatically if the user
      # so chooses.
      command = $auto_next ? 'x' : get_user_command('=').downcase
      $auto_next = false
      process_tasklist_input(command)
      next if $auto_next
      # Escape from TaskList when user requests archive or deletes all data.
      return if $view_archive or $destroyed_data
    end
    puts ''
    puts ($unsaved_changes ?
      "You have unarchived (un-backed up) changes, but your data is saved."
      : "Your data is saved.")
    puts "Goodbye until next time!"
  end

  # Dispatch table for tasklist (and options, archive, and task view launch).
  # Typically (not always) redisplays tasks after executing some function. RF
  def process_tasklist_input(command)
    # A 'message' (or nil) is returned by most of these functions, and then
    # passed off to TasklistView::display_tasks.
    message = case command
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
      task ? "New task saved." : "Task input abandoned."
    when 'r'
      repotask = Repotask.generate_new_repotask
      repotask ? "New repotask saved." : "Repotask input abandoned."
    when /\A(\d+)\Z/
      task = fetch_task_from_displayed_number($1.to_i)
      if task
        if task.class == Task
          task.launch_task_interface
        else
          task.launch_repotask_interface
        end
      else
        "Task not found."
      end
    when 'l'
      prep_to_show_all_tasks # Clears @default_tag and stops filtering.
    when 'x'
      edit_next_item
    when 'd'
      confirm_delete
    when 't'
      tag_search
    when 'a'
      $view_archive = true # Used in revuu.rb. Exits TaskList.
      return
    when 'e'
      choose_text_editor
    when 'p'
      choose_default_language
    when 'de'
      destroy_all
      return if $destroyed_data # Used in revuu.rb. Exits TaskList.
    when 'h'
      display_history
    when 's'
      display_sorting_commands
    when 'id'
      sort_by_id
    when 'sc'
      sort_by_avg_score
    when 'notags'
      display_tasks_without_tags
    when 'c'
      prompt_to_change_all_review_dates
    when '?', 'help'
      launch_instructions_system
    when 'q'
      return
    else
      puts 'Huh?'
      no_refresh = true
    end
    # Note, no_refresh is declared only after 'else' just above.
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
    if @filter_tag
      @filter_tag = nil
      @tag_filtered_list = []
      @page_num = 1
    end
    nil # No dispatch table message.
  end

  # Simply opens the item with the earliest review date to edit. RF
  def edit_next_item
    list = @filter_tag ? @tag_filtered_list : @list
    item = list[0]
    item.class == Task ? item.launch_task_interface :
      item.launch_repotask_interface
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
    tag_matches = get_tag_matches(tag.downcase, tag_hash)
    # Display results. If not found, say so.
    unless tag_matches.empty?
      # Assign default tag to input. This does double duty as boolean
      # indicating whether the current tasklist display is filtered or not.
      @filter_tag = tag
      @default_tag = @filter_tag.dup unless
        @filter_tag == 'history' or @filter_tag == 'sort_by_id' or
        @filter_tag == 'reverse_sort_by_id' or @filter_tag == 'sort_by_avg_score' or
        @filter_tag == 'reverse_sort_by_avg_score' or @filter_tag == 'notags'
      @page_num = 1
      # Save sorted array of tasks filtered by this tag.
      @tag_filtered_list = match_tasks(tag: tag, tag_hash: tag_hash,
                                       tag_matches: tag_matches)
      return "Filtering by '#{tag}'. Press 'l' to clear filter."
    else
      return "'#{tag}' not found."
    end
  end

  # Basically uses the same logic as #tag_search.
  def display_history
    return "No history yet. Make and review a task first." if @history.empty?
    @filter_tag = 'history'
    @page_num = 1
    @tag_filtered_list = @history.map{|h| h[1]}.uniq
    return "Showing history. Press 'l' to show tasklist."
  end

  def sort_by_id
    return "No tasks to sort." if @list.empty?
    @page_num = 1
    if @filter_tag and @filter_tag == 'sort_by_id'
      @filter_tag = 'reverse_sort_by_id'
      @tag_filtered_list = @list.sort_by{|t| t.id}.reverse
      return "Showing tasks *reverse* sorted by ID (date created)."
    else
      @filter_tag = 'sort_by_id'
      @tag_filtered_list = @list.sort_by{|t| t.id}
      return "Showing tasks sorted by ID (date created)."
    end
  end

  def prep_array_of_tasks_by_avg_score
    @list.sort_by do |t|
      scores = t.all_reviews.map {|r| r['score']}
      (scores.reduce(:+) / scores.count.to_f)
    end
  end

  def sort_by_avg_score
    return "No tasks to sort." if @list.empty?
    @page_num = 1
    score_ordered_tasks = prep_array_of_tasks_by_avg_score
    if @filter_tag and @filter_tag == 'sort_by_avg_score'
      @filter_tag = 'reverse_sort_by_avg_score'
      @tag_filtered_list = score_ordered_tasks.reverse
      return "Showing tasks *reverse* sorted by average score."
    else
      @filter_tag = 'sort_by_avg_score'
      @tag_filtered_list = score_ordered_tasks
      return "Showing tasks sorted by average score."
    end
  end

  def display_tasks_without_tags
    return "No tasks." if @list.empty?
    @filter_tag = 'notags'
    @page_num = 1
    @tag_filtered_list = @list.find_all do |t|
      # Find all tasks that have no tags other than the language defaults.
      x = t.tags
      y = t.langhash.lang_alts + [t.langhash.name]
      nondefault_tags = (x + y) - (x & y)
      nondefault_tags.empty? # If there no nondefault tags, return this item.
    end
    return "Showing all tasks with no (non-default) tags."
  end

  # For use in tag search: a hash where keys = tags while values = tasks. RF
  def prepare_hash_of_tag_arrays
    tag_hash = {}
    list.each do |task|
      next unless task.tags
      task.tags.each do |tag|
        tag_hash[tag] = [] unless tag_hash[tag]
        tag_hash[tag] << task unless tag_hash[tag].include? task
      end
    end
    tag_hash
  end

  # Given an integer, return a task from the tasklist. RF
  def fetch_task_from_displayed_number(num)
    @displayed_tasks[num]
  end

end
