module RepotaskController

  # Launches repotask display for user and prompts for input (e.g., open files,
  # save review, run answer, edit instructions, etc.).
  def launch_repotask_interface
    display_info # Different display from class Task.
    command = ''
    until command == 'q'
      command = get_user_command('+').downcase
      process_repotask_input(command)
    end
    nil # No tasklist dispatch table message.
  end

  # Given a user command in the Repotask view, dispatch as appropriate.
  def process_repotask_input(command)
    case command
    when /\A(\d+)\Z/
      open_file($1.to_i)
    when 'o'
      open_repo
    when 's' # Same as Task method.
      record_review
#    when 'a' # Very different; needs to be replaced entirely, in fact.
#      write_answer
    when 'r' # Execute the repotask's run_commands.
      run_answer
    when 'h', '?' # Launch help.
      launch_instructions_system
      display_info # Display the task after returning from help.
#    when 'o' # Basically need to switch to backup/archive repo...
#      view_old_answers
#    when 'rr' # Run old answer. Switch and run...
#      run_answer('old')
    when 'l' # Same as Task method.
      self.change_language
    when 'i' # Same as Task method.
      edit_field('instructions')
    when 'c'
      edit_run_commands # User will often have to tweak @run_commands.
    when 'fi'
      edit_files_to_edit
    when 't' # Same as Task method.
      edit_field('tags')
    when 'd' # Same as Task method.
      date = get_next_review_date('d')
      save_review_date(date) if date
    when 'sc' # Same as Task method.
      prep_new_score
    when 'f'
      display_info
    when 'q' # Quit task view and return to tasklist.
      cache_answer_in_archive_branch
      reset_branch
      return
    else
      puts 'Huh?'
    end
  end

  def open_file(file)
    return unless branch_reset_confirmed?
    file = @files[file-1]
    system("#{$textedcmd} data/repos/#{@repo}/#{file}")
    puts "When you're done, don't forget to press 'r' to run."
  end

  def open_repo
    return unless branch_reset_confirmed?
    system("#{$textedcmd} data/repos/#{@repo}")
    puts "When you're done, don't forget to press 'r' to run."
  end

  # This prompts the user for an "OK" to hard reset the branch (rolling back
  # the files); if so, resets and returns true; if not, returns false.
  def branch_reset_confirmed?
    puts <<~CONFIRMRESET
      NOTE:
      If you have made any changes to this task's branch they will be
      deleted. If you want to see your old code or test-run it again,
      press 'n' now.

      CONFIRMRESET
    confirm = nil
    until ['y', 'n', ''].include? confirm
      puts "Confirm reset? (Enter for [y]es, or [n]o)"
      confirm = get_user_command('o')
    end
    return false if confirm == 'n'
    reset_branch
  end

  def reset_branch
    g = Git.open("data/repos/#{repo}")
    g.branch(branch).checkout
    #g.reset_hard
    puts "Repo (#{repo}) reset: files restored to original state."
    true
  end

  def run_answer
    commands = @run_commands.split("\n").join("&&")
    commands = "cd data/repos/#{@repo}&&" + commands
    system(commands)
  end

  def edit_run_commands
    # Write @run_commands to temp file.
    file = 'tmp/run_commands.tmp'
    File.write(file, @run_commands)
    # Load with pico.
    system("pico #{file}")
    # Capture contents to @run_commands.
    @run_commands = File.read(file)
    # Delete temp file.
    File.delete(file)
    # Save tasks
    $tasks.save_tasklist
    puts "New run commands loaded."
  end

  def edit_files_to_edit
    response = self.class.get_files(@repo, @branch, @files)
    if response == 'q'
      display_info
      puts "Quit files interface. No changes made."
    else
      @files = response
      $tasks.save_tasklist
      display_info
      puts "Files loaded."
    end
  end

  # We'll cause errors when checking out other branches (when either creating
  # or answering other repotasks) if our changes to this branch aren't either
  # committed or reset. We don't want to commit them (that ruins the branch
  # for purposes of this question). So we must reset the branch. But if the
  # user wants to see his answer, we need to give him a place to see it.
  # We do so by caching his answer in a special archive branch (one per task),
  # which is always overwritten by this method.
  def cache_answer_in_archive_branch
    # Delete any existing archive branch.
    # Create archive branch (again, maybe).
    # Finally, checkout the main repotask branch.
  end

end
