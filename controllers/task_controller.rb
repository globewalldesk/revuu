module TaskController

  # Launches task display for user and prompts for input (e.g., write answer,
  # save review, run answer, edit instructions, etc.). RF
  def launch_task_interface
    display_info
    command = ''
    until command == 'q' or $auto_next
      command = get_user_command('+').downcase
      process_edit_input(command)
    end
    nil # No tasklist dispatch table message.
  end

  # Given a user command in the Task view, dispatch as appropriate. RF
  def process_edit_input(command)
    case command
    when 's' # Record information about review.
      record_review
    when 'a' # Opens file in your text editor so you can write answer.
      write_answer
    when 'r' # Execute the file you wrote.
      run_answer
    when 'co' # Open a console in the task's directory
      open_console
    when 'help', '?' # Launch help.
      launch_instructions_system
      display_info # Display the task after returning from help.
    when 'o' # Open file containing old/archived answers for this task.
      view_old_answers
    when 'rr' # Run old answer. No guarantee it will work.
      run_answer('old')
    when 'h'
      review_history
    when 'i' # Edit instructions for this task.
      edit_field('instructions')
    when 't' # Edit tags for this task.
      edit_field('tags')
    when 'd' # Edit date of next review (spaced repetition algorithm suggests).
      date = get_next_review_date('d')
      save_review_date(date) if date
    when 'sc' # Edit score of personal knowledge of this task.
      prep_new_score
    when 'st' # Open starter code file in text editor & load it when done.
      edit_starter
    when 'f' # Re[f]resh task page. Maybe should be done automatically.
      display_info
    when 'l' # Change language setting for this task.
      self.change_language
    when 'x'
      $auto_next = true
    when 'q' # Quit task view and return to tasklist.
      return
    else
      puts 'Huh?'
    end
  end

  # User records that he performed a review; updates score and next date. RF
  def record_review
    puts "Good, you completed a review."
    # Get @score from user.
    score = get_score('r') # User gets one chance; abandons attempt otherwise.
    return unless score
    # Get @next_review_date from user (might be based on spaced repetition algorithm).
    date = get_next_review_date('s', score)
    return unless date
    # Update current @score only after date is acceptable.
    @score = score
    # Update @next_review_date.
    @next_review_date = date
    # Save review date and score to @all_reviews.
    @all_reviews << {'score' => @score, 'review_date' => DateTime.now.to_s}
    # Save updated task data to JSON file.
    $tasks.save_tasklist
    # Refresh view.
    display_info
    # Show review history since typically it's of interest at this point.
    review_history
    # Ask user if he wants to go immediately to the next question; returns 'true'
    # if the answer is yes.
    return prompt_for_autonext
  end

  # Used only in the "date of next review" command. RF
  def save_review_date(date)
    @next_review_date = date
    $tasks.save_tasklist
    display_info
  end

  # User inputs new rating of own ability to solve task. Used only in the
  # "edit score" command. RF
  def prep_new_score
    score = get_score('s')
    if score
      @score = score
      # Edit data from most recent review
      @all_reviews[-1]['score'] = score
    else
      return nil
    end
    $tasks.save_tasklist
    display_info
  end

  # Save old answer to archive file (e.g., 'answer_old_23.rb'). Used by module
  # TaskView#write_answer. (Not the same as archiving all data.)  RF
  def archive_old_answer
    # Create a folder for this archive if one doesn't exist yet.
    create_folder_if_necessary(@old_location_dir)
    # Load existing answer archive, if any.
    old_archive = File.exist?(@old_location) ? File.read(@old_location) : ''
    # Load current answer file contents.
    contents = File.read(@location)
    # Prepare new archive contents.
    # If C, Java, etc., then completely overwrite old answer file.
    if @langhash.one_main_per_file
      new_archive = contents
      # If Java, the main class needs to be renamed to be runnable.
      if @lang == 'Java'
        new_archive.gsub!('public class answer', 'public class answer_old')
      end
    else # Else the usual case: append newer answer to top of old_archive.
      # Separate different archived answers with a line of comments.
      # Use $cmnt2 for /* ... */ style comments.
      comment_separator = (@langhash.cmnt2 ? ((@langhash.cmnt*37) +
        @langhash.cmnt2) : (@langhash.cmnt*37) )
      # Concatenate current contents with archive file contents.
      new_archive =
        contents + ("\n\n\n" + @langhash.spacer + "\n" + comment_separator +
            + "\n\n\n") + old_archive
    end
    # Write concatenated contents to the location of the archive.
    File.write(@old_location, new_archive)
    save_change_timestamp_to_settings # Whenever a change is made...
  end

  # Pre-populates the task answer file with starter code.  RF
  def add_starter_code_to_answer_file
    if @starter
      File.write(@location, @starter)
      save_change_timestamp_to_settings
    elsif @lang == 'Java'
      File.write(@location, java_starter)
      save_change_timestamp_to_settings
    end
  end

  # Opens a new xterm (user must have) console located in the repotask's working
  # directory.
  def open_console
    check_for_xterm
    # This is a rather complicated command that required a fair bit of research.
    # "env -i HOME=$HOME" resets the environment variables (to blank), while
    # "bash -l" starts a new bash session and "-c" plus the command executes a
    # command in that bash session. 'cd #{Dir.pwd}', etc., changes to the working
    # directory of the repotask, "DISPLAY=:0" tells Bash which computer display
    # to use (because you cleared all environment variables earlier), while
    # finally "xterm -fa 'Monospace' -fs 12'" opens xterm and sets it to run in
    # a readable font size.
    if @repo
      system("env -i HOME=\"$HOME\" bash -l -c 'cd #{Dir.pwd}/data/repos/#{@repo} && DISPLAY=:0 xterm -fa 'Monospace' -fs 11'")
    else
      system("env -i HOME=\"$HOME\" bash -l -c 'cd #{Dir.pwd}/#{@location_dir} && DISPLAY=:0 xterm -fa 'Monospace' -fs 11'")
    end
  end

  def check_for_xterm
    unless system("which xterm > /dev/null")
      puts "\nSorry, you need to install xterm. Try 'sudo apt-get install xterm'."
      puts "This might or might not work on your system. You can do it yourself;"
      puts "or do you want me to try running this for you? [y]/n"
      answer = get_user_command('co')
      unless answer == 'y' or answer == ''
        return
      end
      unless system("sudo apt-get install xterm")
        return
      end
    end
  end

end
