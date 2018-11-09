module TaskView

  def display_info
    clear_screen
    puts '=' * 75
    puts 'TASK INSTRUCTIONS:'
    puts '(' + @lang + ') ' + @instructions
    puts '=' * 75
    date = DateTime.parse(@date_started).strftime("%-m/%-d/%Y")
    starter_string = @starter ? '*Yes*' : 'No'
    printf("  ID: %d  Started: %-10s  Reviews: %d  Score: %s  Starter: #{starter_string}\n",
      @id, date, @all_reviews.length, @score)
    last_date_timestamp = @all_reviews.empty? ?
      nil : @all_reviews.max_by {|r| r['review_date']}['review_date']
    last_precise_date = last_date_timestamp ?
      DateTime.parse(last_date_timestamp).strftime("%-m/%-d/%Y") : 'none yet'
    last_time = last_date_timestamp ? DateTime.parse(last_date_timestamp).
      strftime(" %H:%M") : ''
    next_precise_date = DateTime.parse(@next_review_date).
      strftime("%-m/%-d/%Y")
    default_tag_count = @langhash.lang_alts.length + 1 # +1 for the lang name.
    tag_str = "(#{@tags.length - default_tag_count})"
    puts <<~DISPLAYDATA
      Review dates >> Last: #{last_precise_date}#{last_time}  Next: #{next_precise_date} (#{prettify_timestamp(@next_review_date)})

    COMMANDS  Review: [s]ave review  [a]nswer  [r]un answer  [h]elp
                      [o]ld answers  [rr]un old answers  [c]onfigure language
                Edit: [i]nstructions  [t]ags#{tag_str}  [d]ate of next review
                      [sc]ore  [st]arter code
                Also: re[f]resh view  [q]uit review and editing

    DISPLAYDATA
  end

  def get_score(prompt)
    puts "Input score (5: mastered, 4: confident, 3: shaky, 2: barely recall, 1: blank)"
    score = get_user_command(prompt).to_i
    unless [1, 2, 3, 4, 5].include?(score)
      puts "Score must be between 1 and 5."
      return nil
    end
    score
  end

  # Prompt user to either accept spaced repetition-calculated date or else enter own.
  def get_next_review_date(prompt, score=@score)
    calculated = calculate_spaced_repetition_date(score)
    puts "Spaced repetition date: #{calculated.strftime("%-m/%-d/%Y")} (#{prettify_timestamp(calculated)})"
    puts "Do next review when? Use regular English, or just press 'Enter' to accept date above."
    date = get_user_command(prompt)
    # Gem parses ordinary English input to Time obj.
    date = ( date == '' ? calculated.to_time : Chronic.parse(date)  )
    unless date.class == Time
      puts "ERROR: couldn't parse date."
      return nil
    end
    DateTime.parse(date.to_s).to_s # Convert Time to DateTime string.
  end

  def edit_starter
    puts "Editing the starter code in #{$texted}. Don't forget to save."
    system("#{$textedcmd} #{@starter_location}")
    print "Save your work, then press <Enter> to load the starter code: "
    if ( gets && File.exist?(@starter_location) &&
         File.stat(@starter_location).size > 0 )
      @starter = File.read(@starter_location)
      puts "Starter text (last saved version) now loaded."
    else
      puts "Starter text not saved. Try saving first, then press 'st' again."
    end
  end

  # Given a task, opens its answer file with the default text editor.
  def write_answer
    # If answer file has content, ask user if he wants it archived first.
    if (File.exist?(@location) && File.stat(@location).size > 0 &&
      File.read(@location) != java_starter && File.read(@location) != @starter)
      puts "An answer exists. Want to archive it before opening? ([y]/n)"
      ans = get_user_command('a')
      if (ans == 'y' || ans == '')
        archive_old_answer
        # If file doesn't exist, create it. If Java, add template.
        create_answer_file
      end
    else
      create_answer_file
    end
    # Open with default editor. (Set default in #configure_answers. Helper.)
    system("#{$textedcmd} #{@location}")
    # Remind user to press 'r' to run.
    puts "When you're done, don't forget to press 'r' to run."
  end

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

  # Given a task (answer), run it (optionally, an archived task answer).
  def run_answer(old = false)
    old ? (file = @old_file and location = @old_location) :
      (file = @file and location = @location)
    if ( File.exist?(location) && File.stat(location).size > 0 )
      puts ''
      puts "Running #{file}:"
      puts ("=" * 75)
      puts ''
      system("cd data/answers && #{@langhash.cmd} #{file}")
      # If the language is compiled, the @langhash.cmd line runs the compiler.
      # The following then runs the compiled executable.
      if @langhash.cmd2
        # Java, e.g., needs to remove the extension. Other rules can be
        # added here for new languages as needed.
        subbed_cmd = @langhash.cmd2.gsub('<name-no-ext>',
          file.gsub(".#{@langhash.ext}", ''))
        system("cd data/answers && #{subbed_cmd}")
      end
      puts ''
      puts ("=" * 75)
      # Find the last review performed.
      review_info_last_review = @all_reviews.max_by {|r| r['review_date']}
      # Decide whether to prompt user to press 's'. Skip if no reviews.
      if review_info_last_review
        date_of_last_review = review_info_last_review['review_date']
        last_was_today =
          ( DateTime.parse(date_of_last_review).yday == DateTime.now.yday ?
            true : false )
      else
        last_was_today = false
      end
      puts (old || last_was_today) ? "\n" :
        "\nIf it's correct, press 's' to save a review."
    else
      puts "The #{old ? 'old answer archive' : 'answer'} file doesn't exist."
    end
  end


end
