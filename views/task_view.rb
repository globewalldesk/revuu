module TaskView

  # Given a prompt and a test, wring an acceptable answer from the user or let
  # him abandon adding the new task.
  # REFACTOR: UGH, fix this or split it in two!
  def get_input(args)
    while true
      args[:prompt] += "\nThen press Ctrl-W to save and Ctrl-X to submit. "
      args[:prompt] += "\nPress <Enter> now to continue (or [q]uit)... "
      print args[:prompt]
      choice = gets.chomp
      # Ways to abandon input have two possible effects...
      if (choice == "q")
        return 'q'
      end
      system("rm tmp/temp.tmp") if File.file?("./tmp/temp.tmp")
      system("pico tmp/temp.tmp")
      input = File.read("./tmp/temp.tmp").strip if File.file?("./tmp/temp.tmp")
      system("rm tmp/temp.tmp") if File.file?("./tmp/temp.tmp")
      if args[:required]
        if input
          if input.length < 3
            puts("Surely not long enough...")
          else
            puts "#{args[:type]} saved."
            return input
          end
        else
          if args[:type] == 'Instructions'
            puts "Abandoning task (no input)."
            return nil
          end
        end
      else
        input ? (puts "#{args[:type]} saved."; return input) : (return nil)
      end
    end
  end # of ::get_input

  def get_tags_from_user
    get_input(type: 'Tags', prompt:
      "\nINPUT TAGS:\nOn the next screen, you'll input tags, separated by commas (optional).",
      required: false)
  end

  def get_initial_score_from_user
    puts "\nINITIAL SCORE:"
    puts "Input initial score (5: mastered, 4: confident, 3: shaky, 2: barely recall, 1: blank)"
    score = get_user_command('n').to_i
    score = 1 unless [1, 2, 3, 4, 5].include? score
    return score
  end

  def display_info
    clear_screen
    puts '=' * 75
    puts 'TASK INSTRUCTIONS:'
    puts '(' + @lang + ') ' + @instructions
    puts '=' * 75
    date = DateTime.parse(@date_started).strftime("%-m/%-d/%Y")
    printf("  ID: %d   Started: %-10s   Reviews: %d   Score: %s\n",
      @id, date, @all_reviews.length, @score)
    last_date_timestamp = @all_reviews.empty? ?
      nil : @all_reviews.max_by {|r| r['review_date']}['review_date']
    last_precise_date = last_date_timestamp ?
      DateTime.parse(last_date_timestamp).strftime("%-m/%-d/%Y") : 'none yet'
    next_precise_date = DateTime.parse(@next_review_date).
      strftime("%-m/%-d/%Y")
    puts "  Review dates >>  Last: #{last_precise_date}  Next: #{next_precise_date} (#{prettify_timestamp(@next_review_date)})"
    puts "\nCOMMANDS  Review: [s]ave review  [a]nswer  [r]un answer  [h]elp"
    puts   "                  [o]ld answers  [rr]un old answers  [c]onfigure language"
    puts   "            Edit: [i]nstructions  [t]ags  [d]ate of next review  [sc]ore"
    puts   "            Also: re[f]resh view  [q]uit review and editing\n\n"
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

  def get_next_review_date(prompt)
    puts "Do next review when? (Use regular English.)"
    date = get_user_command(prompt)
    date = Chronic.parse(date) # Gem parses ordinary English input to Time obj.
    unless date.class == Time
      puts "ERROR: couldn't parse date."
      return nil
    end
    date = DateTime.parse(date.to_s).to_s # Convert Time to DateTime string.
    pretty = DateTime.parse(date).
      strftime("%-m/%-d/%Y (#{prettify_timestamp(date)})")
    date
  end

  # Given a task, opens its answer file with the default text editor.
  def write_answer(task)
    # If answer file has content, ask user if he wants it archived first.
    if (File.exist?($location) && File.stat($location).size > 0 &&
      File.read($location) != java_starter(task))
      puts "An answer exists. Want to archive it before opening? ([y]/n)"
      ans = get_user_command('a')
      if (ans == 'y' || ans == '')
        archive_old_answer(task)
        # If file doesn't exist, create it. If Java, add template.
        create_answer_file(task)
      end
    else
      create_answer_file(task)
    end
    # Open with default editor. (Set default in #configure_answers. Helper.)
    system("#{$textedcmd} #{$location}")
    # Remind user to press 'r' to run.
    puts "When you're done, don't forget to press 'r' to run."
  end

  def view_old_answers(task)
    # If it exists and is nonzero, display archive with default text editor.
    if ( File.exist?($old_location) && File.stat($old_location).size > 0 )
      system("#{$textedcmd} #{$old_location}")
      # Remind user to press 'rr' to run.
      puts "If you want, you can run the old answer archive with 'rr'."
    else # ...or else say it doesn't exist.
      puts "There is no old answer archive for this task yet."
    end
  end

  # Given a task (answer), run it (optionally, an archived task answer).
  def run_answer(task, old = false)
    old ? (file = $old_file and location = $old_location) :
      (file = $file and location = $location)
    if ( File.exist?(location) && File.stat(location).size > 0 )
      puts ''
      puts "Running #{file}:"
      puts ("=" * 75)
      puts ''
      system("cd answers && #{$cmd} #{file}")
      # If the language is compiled, the $cmd line runs the compiler.
      # The following then runs the compiled executable.
      if $cmd2
        # Java, e.g., needs to remove the extension. Other rules can be
        # added here for new languages as needed.
        subbed_cmd = $cmd2.gsub('<name-no-ext>', file.gsub(".#{$ext}", ''))
        system("cd answers && #{subbed_cmd}")
      end
      puts ''
      puts ("=" * 75)
      # Find the last review performed.
      review_info_last_review = task.all_reviews.max_by {|r| r['review_date']}
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
