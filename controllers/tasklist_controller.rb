module TasklistController

  def process_input(command)
    case command
    when 'n'
      task = Task.generate_new_task
      puts task ? "New task saved." : "Task input abandoned or failed."
      display_tasks # Redisplay tasklist after returning from task view.
    when 'l'
      clear_tag_search
      display_tasks
    when 'd'
      delete
    when 't'
      tag_search
    when 'e'
      choose_text_editor
    when 'p'
      choose_default_language
    when 'a'
      Archiv.launch_archive_system
    when 'h'
      launch_instructions_system
      display_tasks  # Redisplay tasklist after returning from help.
    when /\A(\d+)\Z/
      task = fetch_task_from_displayed_number($1.to_i)
      task ? task.edit : (puts "Task not found.")
      display_tasks # Redisplay tasklist after returning from task view.
    when '>', '.'
      nav('next')
    when '<', ','
      nav('back')
    when '>>', '..'
      nav('end')
    when '<<', ',,'
      nav('top')
    when 'x'
      show_next_item
      display_tasks # Redisplay tasklist after returning from task view.
    when 'de'
      destroy_all
    when 'q'
      return
    else
      puts 'Huh?'
    end
  end

  def delete
    print "WARNING! CANNOT UNDO!\nType number of task to delete: "
    delete_num = gets.chomp.to_i
    delete_task = fetch_task_from_displayed_number(delete_num.to_i)
    @list.delete(delete_task) ? message = true : message = false
    delete_task_files(delete_task)
    save_tasklist
    display_tasks
    puts (message ? "#{delete_num} deleted." : "#{delete_num} not found; nothing deleted.")
  end

  def delete_task_files(task)
    return nil unless defined?(task.id)
    ending = "#{task.id}.#{task.langhash.ext}"
    # Delete current answer.
    system("rm ./data/answers/answer_#{ending}")
    # Delete archive.
    system("rm ./data/answers/answer_old_#{ending}")
    # Delete code starter.
    system("rm ./data/starters/starter_#{ending}")
  end

  # Get user input for searching tasks by tag; return just matching tasks.
  def tag_search
    # Prepare tag-based arrays.
    prepare_hash_of_tag_arrays  # Stored in @tag_hash.
                                # NOTE: Probably not necessary every time.
    if @tag_hash.empty?
      puts "No tags found."
      return nil
    end
    tag = get_search_tag_from_user
    # If old tag exists and user hit <enter> alone, use old tag.
    if (!@old_tag.nil? && tag == '')
      tag = @old_tag
    end
    tag_match = @tag_hash.keys.find { |k| tag.downcase == k.downcase }
    # Display results. If not found, say so.
    if tag_match
      # Assign default tag to input.
      @default_tag = tag_match
      @old_tag = @default_tag.dup
      @pagination_num = 1
      # Save sorted array of tasks filtered by this tag.
      @tag_filtered_list = @tag_hash[tag_match]
      # Display list.
      display_tasks
    else
      puts "'#{tag}' not found."
    end
  end

  # Given a "direction" to navigate in, return a display reflecting the change.
  def nav(where)
    list = @default_tag ? @tag_filtered_list : @list
    return '' if list.length < 10
    pnum = @pagination_num.dup
    last_pg = get_last_page(list)
    on_first = (pnum == 1 ? true : false)
    on_last = (pnum == last_pg ? true : false)
    case where
    when 'top'
      @pagination_num = 1
    when 'back'
      @pagination_num = (on_first ? 1 : pnum - 1 )
    when 'next'
      @pagination_num = (on_last ? last_pg : pnum + 1)
    when 'end'
      @pagination_num = last_pg
    end
    display_tasks
  end

end
