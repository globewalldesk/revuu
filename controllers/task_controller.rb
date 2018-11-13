module TaskController

  # Launches task display for user and prompts for input (e.g., write answer,
  # save review, run answer, edit instructions, etc.). RF
  def launch_task_interface
    display_info
    command = ''
    until command == 'q'
      command = get_user_command('+')
      process_edit_input(command)
    end
    nil # No tasklist dispatch table message.
  end

  # Given a user command in the Task view, dispatch as appropriate. RF
  def process_edit_input(command)
    case command.downcase
    when 's' # Record information about review.
      record_review
    when 'a' # Opens file in your text editor so you can write answer.
      write_answer
    when 'r' # Execute the file you wrote.
      run_answer
    when 'h', '?' # Launch help.
      launch_instructions_system
      display_info # Display the task after returning from help.
    when 'o' # Open file containing old/archived answers for this task.
      view_old_answers
    when 'rr' # Run old answer. No guarantee it will work.
      run_answer('old')
    when 'c' # Change language setting for this task.
      self.change_language
    when 'i' # Edit instructions for this task.
      edit_field('instructions')
    when 't' # Edit tags for this task.
      edit_field('tags')
    # START HERE -- almost done refactoring Task
    when 'd' # Edit date of next review (spaced repetition algorithm suggests).
      date = get_next_review_date('d')
      save_review_date(date) if date
    when 'sc' # Edit score of personal knowledge of this task.
      edit_score
    when 'st' # Open starter code file in text editor & load it when done.
      edit_starter
    when 'f' # Re[f]resh task page. Maybe should be done automatically.
      display_info
    when 'q' # Quit task view and return to tasklist.
      return
    else
      puts 'Huh?'
    end
  end

  def record_review
    puts "Good, you completed a review."
    # Get @score from user.
    score = get_score('r') # User gets one chance; abandons attempt otherwise.
    return unless score
    # Get @next_review_date from user (might be based on spaced repetition algorithm).
    date = get_next_review_date('r', score)
    return unless date
    # Update current @score only after date is acceptable.
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

  def archive_old_answer
    old_archive = File.exist?(@old_location) ? File.read(@old_location) : ''
    # Load current answer file contents.
    contents = File.read(@location)
    # If C, Java, etc., then completely overwrite old answer file
    if @langhash.one_main_per_file
      new_archive = contents
      # If Java, the main class needs to be renamed to be runnable.
      if @lang == 'Java'
        new_archive.gsub!('public class answer', 'public class answer_old')
      end
    else
    # Else the usual case: append newer answer to top of old_archive.
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
    save_change_timestamp_to_settings
    # Finally, overwrite the current answer file with '' or Java template.
    create_answer_file
  end

  def create_answer_file
    if ! File.exist?(@location)
      system("touch #{@location}")
    end
    if @starter
      File.write(@location, @starter)
      save_change_timestamp_to_settings
    elsif @lang == 'Java'
      # So far, only Java files need to be written-to before getting started.
      File.write(@location, java_starter)
      save_change_timestamp_to_settings
    else
      File.write(@location, '')
      save_change_timestamp_to_settings
    end
  end

end
