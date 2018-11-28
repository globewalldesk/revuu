module TaskView

  # This actually shows the task data (instructions, etc.) to the user, then
  # shows the commands for interfacing with this data. RF
  def display_info(type_label = nil) # See below re type_label.
    clear_screen
    puts '=' * 75
    type_label ||= 'TASK' # # type_label is "REPOTASK" if self.class == Repotask
    puts "#{type_label} INSTRUCTIONS:"
    # Note, lib/wrapping_helper.rb has already accommodated the space needed for
    # the (@lang) bit.
    puts ('(' + @lang + ') ').colorize(@langhash.color) + @instructions
    puts '=' * 75
    # Prepare and print task data strings for line 1.
    date = DateTime.parse(@date_started).strftime("%-m/%-d/%Y")
    starter_string = @starter ? '*Yes*' : 'No'
    printf("  ID: %d  Started: %-10s  Reviews: %d  Score: %s  Starter: #{starter_string}\n",
      @id, date, @all_reviews.length, @score)
    # Prepare and print task data strings for line 2 + command list.
    last_date_timestamp = @all_reviews.empty? ?
      nil : @all_reviews.max_by {|r| r['review_date']}['review_date']
    last_precise_date = last_date_timestamp ?
      DateTime.parse(last_date_timestamp).strftime("%-m/%-d/%Y") : 'none yet'
    last_time = last_date_timestamp ? DateTime.parse(last_date_timestamp).
      strftime(" %H:%M") : ''
    next_precise_date = DateTime.parse(@next_review_date).
      strftime("%-m/%-d/%Y")
    default_tag_count = @langhash.lang_alts.length + 1 # +1 for the lang name.
    @tag_str = "(#{@tags.length - default_tag_count})"
    puts "  Review dates >> Last: #{last_precise_date}#{last_time}  " +
         "Next: #{next_precise_date} (#{prettify_timestamp(@next_review_date)})"
    puts "  Files directory: #{@location_dir}"
    display_task_commands(@tag_str) if self.class == Task
  end

  def display_task_commands(tag_str)
    puts <<~DISPLAYTASKCOMMANDS

    COMMANDS  Review: [s]ave review  [a]nswer  [r]un answer  [?] help
                      [o]ld answers  [rr]un old answers  configure [l]anguage
                Edit: [i]nstructions  [t]ags#{tag_str}  [d]ate of next review
                      [sc]ore  [st]arter code
                Also: re[f]resh view  [q]uit review and editing

    DISPLAYTASKCOMMANDS
  end

  # Solicit and return a valid score or return nil if user fails to do so. RF
  def get_score(prompt)
    puts "Input score (5: mastered, 4: confident, 3: shaky, 2: barely recall, 1: blank)"
    score = get_user_command(prompt).to_i
    unless [1, 2, 3, 4, 5].include?(score)
      puts "Score must be between 1 and 5."
      return nil
    end
    score
  end

  # Prompt user to either accept spaced repetition-calculated date or else
  # enter own. Returns timestamp or, if can't parse user-entered date, nil.  RF
  def get_next_review_date(prompt, score=@score)
    calculated_date = calculate_spaced_repetition_date(score)
    puts "\nSpaced repetition date: #{calculated_date.strftime("%-m/%-d/%Y")} " +
         "(#{prettify_timestamp(calculated_date)})"
    puts "Do next review when? Use regular English, or"
    puts "just press 'Enter' to accept date above or 'q' to escape.\n\n"
    date = get_user_command(prompt)
    return nil if date == 'q'
    # "Chronic" gem parses ordinary English input to Time obj.
    date = ( date == '' ? calculated_date.to_time : Chronic.parse(date) )
    unless date.class == Time
      puts "ERROR: couldn't parse date."
      return nil
    end
    DateTime.parse(date.to_s).to_s # Convert Time to DateTime string.
  end

  # Given a task, opens its answer file with the default text editor.  RF
  def write_answer
    # If answer file has content, ask user if he wants it archived first.
    if (File.exist?(@location) && File.stat(@location).size > 0 &&
      File.read(@location) != java_starter && File.read(@location) != @starter)
      puts "An answer exists. Want to archive it before opening? ([y]/n)"
      ans = get_user_command('a')
      # If yes, archive the old answer and blank the answer file.
      if (ans == 'y' || ans == '')
        archive_old_answer
        # Create a folder for this answer if one doesn't exist yet.
        create_folder_if_necessary(@location_dir)
        File.write(@location, '') # Erase old answer from answer file.
        # Creates file with starter code as necessary.
        add_starter_code_to_answer_file
      end
    else
      add_starter_code_to_answer_file
    end
    # Open with default editor. (Set default in #configure_answers. Helper.)
    system("#{$textedcmd} #{@location}")
    # Remind user to press 'r' to run.
    puts "When you're done, don't forget to press 'r' to run."
  end

  # Given a task (answer), run it (optionally, an archived task answer).
  # Long and complex but all devoted to running the answer. RF
  def run_answer(old = false)
    old ? (file = @old_file and location = @old_location and location_dir = @old_location_dir) :
      (file = @file and location = @location and location_dir = @location_dir)
    if ( File.exist?(location) && File.stat(location).size > 0 )
      puts "\nRunning #{file}:"
      puts ("=" * 75).colorize(@langhash.color)
      puts ''
      system("cd #{location_dir} && #{@langhash.cmd} #{file}")
      # If the language is compiled, the latter line runs the compiler.
      # The following then runs the compiled executable.
      if @langhash.cmd2
        # Java, e.g., needs to remove the extension. Other rules can be
        # added here for new languages as needed.
        subbed_cmd = @langhash.cmd2.gsub('<name-no-ext>',
          file.gsub(".#{@langhash.ext}", ''))
        system("cd #{location_dir} && #{subbed_cmd}")
      end
      puts ''
      puts ("=" * 75).colorize(@langhash.color)
      # Find the last review performed.
      last_review = @all_reviews.max_by {|r| r['review_date']}
      # Decide whether to prompt user to press 's'. Skip if no reviews.
      if last_review
        date_of_last_review = last_review['review_date']
        last_was_today =
          DateTime.parse(date_of_last_review).yday == DateTime.now.yday
      else
        last_was_today = false
      end
      puts (old || last_was_today) ? "\n" :
        "\nIf it's correct, press 's' to save a review."
    else
      puts "The #{old ? 'old answer archive' : 'answer'} file doesn't exist."
    end
  end

  # Open old answer file (with archived answers) in your text editor. RF
  def view_old_answers
    # If it exists and is nonzero, display archive with default text editor.
    if ( File.exist?(@old_location) && File.stat(@old_location).size > 0 )
      system("#{$textedcmd} #{@old_location}")
      # Remind user to press 'rr' to run.
      puts "If you want, you can run the old answer archive with 'rr'."
    else # ...or else say it doesn't exist.
      puts "There is no old answer archive for this task yet."
    end
  end

  # Used to edit both instructions and tags. RF
  def edit_field(field)
    # Load current attribute contents.
    contents = (field == 'tags' ?
      (self.instance_variable_get("@#{field}").join(', ') if
      self.instance_variable_get("@#{field}") ) :
      self.instance_variable_get("@#{field}") )
    # Wraps tags (adds "\n") for user during editing; saved without.
    contents = wrap_overlong_paragraphs(contents) if field == 'tags'
    # Write contents to temp file. OK if nil.
    File.write("./tmp/#{field}.tmp", contents)
    # Open file for editing; uses Pico for simplicity of task-switching
    # (don't have to prompt the user to load after finishing).
    system("pico tmp/#{field}.tmp")
    # Save upon closing: grab text.
    attrib = File.read("./tmp/#{field}.tmp").strip
    # Strip newlines if tags (otherwise commas are introduced).
    attrib.gsub!("\n", '') if field == 'tags'
    if attrib.empty? && field == 'instructions'
      puts "ERROR: Instructions cannot be blank."
      return nil # Abandons (doesn't save) any attempt to blank instructions.
    # Use tag prep method if field type is tags.
    elsif field == 'tags'
      attrib = self.class.prep_tags(attrib, @lang) # In module TaskFactory.
    elsif field == 'instructions'
      # In lib/helpers.rb (used for both instructions and tags):
      attrib = wrap_overlong_paragraphs(attrib, @lang.length) if
        attrib.class == String
    end
    # Set instance variable to contents of edited temp file.
    self.instance_variable_set("@#{field}", attrib)
    # Save updated instructions to JSON file if you've made it this far.
    $tasks.save_tasklist
    # Refresh view.
    display_info
  end

  # Open starter code file with text editor; load and save when done.  RF
  def edit_starter
    puts "Editing the starter code in #{$texted}."
    # Create a folder for this starter if one doesn't exist yet.
    create_folder_if_necessary(@starter_location_dir)
    system("#{$textedcmd} #{@starter_location}")
    print "Save your work, then press <Enter> to load the starter code: "
    gets
    if ( File.exist?(@starter_location) &&
         File.stat(@starter_location).size > 0 )
      @starter = File.read(@starter_location)
      print "Starter text (last saved version) now loaded.\n\n"
      save_change_timestamp_to_settings
    elsif ( File.exist?(@starter_location) &&
            File.stat(@starter_location).size == 0 )
      @starter = ''
      print "The starter code is now blank.\n\n"
      save_change_timestamp_to_settings
    else
      print "Starter code not saved. Try saving first, then press 'st' again.\n\n"
    end
  end

end
