module TaskController
    # NOTE (delete later): any method that requires user input or displays
    # anything to the user is in a _view file. _controller files prep data
    # to show the user and accept data from the user, so the controller is
    # constantly talking to the view.

  # Prepares data for new task.
  def generate_new_task
    clear_screen
    # Get task instructions from user.
    instructions = self.get_input(type: 'Instructions', prompt:
      "INPUT INSTRUCTIONS:\nOn the next screen, you'll type in the instructions for your new task. ",
      required: true)         # <-- needs a lot of work/refactoring
    return nil unless instructions # Instructions required.
    # Get language from user.
    lang = configure_initial_language
    # Get tags from user. Arrives as string.
    tags = get_tags_from_user # <-- needs a lot of work/refactoring
    return nil if tags == 'q'  # TEMPORARY kluge
    # Add standard tags and massage tags. Output is an array or 'q'.
    tags = Task.validate_tags(tags)
    # Note: tags are not required.
    # Get initial score from user.
    score = get_initial_score_from_user
    # Construct new task!
    Task.new(instructions: instructions, tags: tags, score: score, lang: lang)
  end # of ::generate_new_task

  # Loads data and launches edit view for particular task.
  def edit
    display_info
    # Prepare globals for use in Answer module.
    lang_data_hash = lookup_lang_data_from_name_cmd(@lang)
    assign_language_globals(lang_data_hash)
    get_locations(@id)
    command = ''
    until command == 'q'
      command = get_user_command('+')
      process_edit_input(command)
    end
    $tasks.display_tasks
  end

  # Given a user command in the Task view, dispatch as appropriate.
  def process_edit_input(command)
    case command
    when 's' # Record information about review.
      record_review
    when 'a' # See Answer module for this and many of the next features.
      write_answer(self)
    when 'h'
      launch_instructions_system
      display_info # Display the task after returning from help.
    when 'r'
      run_answer(self)
    when 'rr'
      run_answer(self, 'old')
    when 'o'
      view_old_answers(self)
    when 'c'
      configure_language(self)
    when 'i' # Edit instructions.
      edit_field('instructions')
    when 't' # Edit tags.
      edit_field('tags')
    when 'd' # Edit date of next review.
      date = get_next_review_date('d')
      save_review_date(date) if date
    when 'sc' # Edit score.
      edit_score
    when 'f'
      display_info
    else
      puts 'Huh?' unless command == 'q'
    end
  end

  def record_review
    puts "Good, you completed a review."
    # Get @score from user.
    score = get_score('r')
    return unless score
    # Get @next_review_date from user.
    date = get_next_review_date('r')
    return unless date
    # Update current @score.
    @score = score
    # Update @next_review_date.
    @next_review_date = date
    # Save review date and score to @all_reviews.
    @all_reviews << {score: @score, 'review_date' => DateTime.now.to_s}
    # Save updated task data to JSON file.
    $tasks.save_tasklist
    # Refresh view.
    display_info
  end

  def edit_field(field)
    # Load current attribute contents into temp file.
    contents = (field == 'tags' ?
      (self.instance_variable_get("@#{field}").join(', ') if
      self.instance_variable_get("@#{field}") ) :
      self.instance_variable_get("@#{field}") )
    File.write("./tmp/#{field}.tmp", contents)
    # Open file for editing.
    system("pico tmp/#{field}.tmp")
    # Save upon closing: grab text.
    attrib = File.read("./tmp/#{field}.tmp").strip
    if attrib.empty?
      if field == 'instructions'
        puts "ERROR: Instructions cannot be blank."
      end
      return nil
    end
    # Use validation method if field type is tags.
    if field == 'tags'
      attrib = self.class.validate_tags(attrib)
    end
    # Set instance variable to contents of edited temp file.
    self.instance_variable_set("@#{field}", attrib)
    # Save updated instructions to JSON file if you've made it this far.
    $tasks.save_tasklist
    # Refresh view.
    display_info
  end

  # Used only in the "date of next review" command.
  def save_review_date(date)
    @next_review_date = date
    $tasks.save_tasklist
    display_info
  end

  # Used only in the "edit score" command
  def edit_score
    score = get_score('s')
    score ? @score = score : (return nil)
    $tasks.save_tasklist
    display_info
  end


  def configure_initial_language
    puts "\nSET LANGUAGE:"
    new_lang, available_langs = solicit_languages_from_user
    # Assign correct globals. Tell user language he's using now.
    if (new_lang && $lang != available_langs[new_lang][:name])
      puts "OK, using #{available_langs[new_lang][:name]}."
      # Set language globals.
      assign_language_globals(available_langs[new_lang])
      # Save as default settings by saving to file.
      update_settings_file('lang' => available_langs[new_lang][:name])
      return available_langs[new_lang][:name]
    else
      puts "OK, we'll go with #{$lang}."
      return $lang
    end
  end

  def configure_language(task)
    new_lang, available_langs = solicit_languages_from_user
    # Assign correct globals. Tell user if he is now switching languages.
    if (! new_lang.nil? && $lang != available_langs[new_lang][:name])
      puts "OK, switching from #{$lang} to #{available_langs[new_lang][:name]}."
      # Save language!
      assign_language_globals(available_langs[new_lang])
      # Remember default across sessions by saving to file.
      update_settings_file('lang' => available_langs[new_lang][:name])
      # Save new language to task.
      task.lang = available_langs[new_lang][:name]
      # And save to revuu.json too.
      $tasks.save_tasklist
      # Re-run #get_locations (they include $ext, which has changed)
      get_locations(task.id)
    else
      puts "Sticking with #{$lang}."
    end
  end

  def archive_old_answer(task)
    old_archive = File.exist?($old_location) ? File.read($old_location) : ''
    # Load current answer file contents.
    contents = File.read($location)
    # If C, Java, etc., then completely overwrite old answer file
    if $one_main_per_file
      new_archive = contents
      # If Java, the main class needs to be renamed to be runnable.
      if task.lang == 'Java'
        new_archive.gsub!('public class answer', 'public class answer_old')
      end
    # Else the usual case: append newer answer to top of old_archive.
    else
      # Separate different archived answers with a line of comments.
      # Use $cmnt2 for /* ... */ style comments.
      comment_separator = ($cmnt2 ? (($cmnt*37) + $cmnt2) : ($cmnt*37) )
      # Concatenate current contents with archive file contents.
      new_archive =
        contents + ("\n\n\n" + comment_separator + "\n\n\n") + old_archive
    end
    # Write concatenated contents to the location of the archive.
    File.write($old_location, new_archive)
    # Finally, overwrite the current answer file with '' or Java template.
    create_answer_file(task)
  end

  def create_answer_file(task)
    if ! File.exist?($location)
      system("touch #{$location}")
    end
    if task.lang == 'Java'
      # So far, only Java files need to be written-to before getting started.
      File.write($location, java_starter(task))
    else
      File.write($location, '')
    end
  end

end
