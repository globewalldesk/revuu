# These are closely-related features associated with writing and viewing
# answers to tasks.
module Answer
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

  def run_answer(task, old = false)
    old ? (file = $old_file and location = $old_location) :
      (file = $file and location = $location)
    if ( File.exist?(location) && File.stat(location).size > 0 )
      puts ''
      puts "Running #{file}:"
      puts ("=" * 75)
      puts ''
      system("cd answers && #{$cmd} #{file}")
      # Java Example
      # Compile: javac ./answers/Example.java
      # Run: java Example
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

  def help_with_answers
  end
end
