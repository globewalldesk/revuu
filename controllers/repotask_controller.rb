module RepotaskController

  # Launches repotask display for user and prompts for input (e.g., open files,
  # save review, run answer, edit instructions, etc.).
  def launch_repotask_interface
    display_info # Different display from class Task.
    command = ''
    until command == 'q'
      command = get_user_command('+').downcase
      # Dispatch table returns command, which in at least one case might be
      # changed by the dispatch table.
      command = process_repotask_input(command)
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
      if branch_reset_confirmed?(true) # true = exiting
        # Needed when leaving, to avoid git errors.
        reset_current_branch
      else
        puts "Branch reset not confirmed; not quitting.\n\n"
        command = '' # Prevents quitting.
      end
    else
      puts 'Huh?'
    end
    return command
  end

  def open_file(file)
    return unless safely_check_out_branch_for_this_task
    return unless branch_reset_confirmed?
    file = @files[file-1]
    system("#{$textedcmd} data/repos/#{@repo}/#{file}")
    puts "When you're done, don't forget to press 'r' to run."
  end

  def open_repo
    return unless safely_check_out_branch_for_this_task
    return unless branch_reset_confirmed?
    system("#{$textedcmd} data/repos/#{@repo}")
    puts "When you're done, don't forget to press 'r' to run."
  end

  # This prompts the user for an "OK" to hard reset the branch (rolling back
  # the files); if so, resets and returns true; if not, returns false.
  # Automatically returns true if branch already reset this session, or if
  # a reset was not needed.
  def branch_reset_confirmed?(exiting = false)
    return true if @reset_this_session and ! exiting
    g = Git.open("data/repos/#{@repo}")
    unless g.status.changed.empty?
      if exiting
        puts <<~EXITCONFIRMATION

        Whenever you exit a repotask, we need to reset (delete changes made to)
        this branch. Please confirm to quit.

        EXITCONFIRMATION
      else
        puts <<~CONFIRMRESET

          WARNING:
          There are uncommitted (unsaved) changes to this branch. They could be
          from another answer that uses this branch that you never reset, or
          something else. You might (or might not) want to make sure it's not
          something you want to save before proceeding with reset; these
          changes will be deleted.

          CONFIRMRESET
      end
      confirm = nil
      until ['y', 'n', ''].include? confirm
        puts "Confirm reset? (Enter for [y]es, or [n]o)"
        confirm = get_user_command('o')
      end
      if confirm == 'n'
        print "OK, branch not reset.\n\n"
        return false
      end
      reset_current_branch # Returns true.
    else
      true
    end
  end

  def reset_current_branch
    g = Git.open("data/repos/#{repo}")
    g.reset_hard
    puts "\nBranch (#{@branch}) reset: files restored to original state."
    @reset_this_session = true
  end

  def run_answer
    return unless safely_check_out_branch_for_this_task
    commands = @run_commands.split("\n").join("&&")
    commands = "cd data/repos/#{@repo}&&" + commands
    puts "\nRunning commands from ##{@id}:"
    puts ("=" * 75)
    puts ''
    system(commands)
    puts ''
    puts ("=" * 75)
  end

  def safely_check_out_branch_for_this_task
    g = Git.open("data/repos/#{@repo}")
    # Is the currently checked-out git branch this repotask's branch?
    if g.current_branch != @branch
      # Give scary warning if there are uncommitted changes.
      unless g.status.changed.empty?
        unless external_branch_reset_confirmed?(g.current_branch)
          puts "Not running. Branch #{g.current_branch} unchanged."
          # Escape if permission not granted by user.
          return nil
        end
        # If permission granted, hard-reset the external branch.
        g.reset_hard
      end
      # Check out needed branch in any case.
      g.branch(@branch).checkout
    end
    true
  end

  # Asks user to confirm hard resetting changes to an external branch.
  def external_branch_reset_confirmed?(current)
    warning = external_branch_reset_warning(current)
    puts wrap_overlong_paragraphs(warning)
    confirm = nil
    until ['y', 'n', ''].include? confirm
      puts "Enter for [y]es, or [n]o to escape (and take care of the changes)."
      confirm = get_user_command('r')
    end
    confirm != 'n' # Returns true if 'y' or '', false if 'n'.
  end

  def external_branch_reset_warning(current)
    <<~EXTBRANCHWARNING
    WARNING:

    We need to switch to the "#{@branch}" branch before running. In the
    "#{@repo}" repo, which this task belongs to, there are uncommitted changes
    to the currently checked-out branch, "#{current}". These changes could be
    an answer to a question, set-up of a new branch that was never saved (by
    being committed), or some random editing you might or might not want.
    First make sure, then answer:

    Do you want to hard reset (delete) the changes to #{current}?

    EXTBRANCHWARNING
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
  # user wants to see his answer again later (as an answer reference, e.g.),
  # we need to give him a place to see it. We do so by caching his answer in
  # a special archive branch (one per task), which is always overwritten by
  # this method. Specially named so they don't show up as options to base new
  # repotasks on.
  def cache_answer_in_archive_branch
    archive_branch = "#{@branch}_#{@id}_archive"
    g = Git.open("data/repos/#{@repo}")
    # Delete any existing archive branch.
    branches = g.branches.local.map {|b| b.full}
    g.branch(@branch).checkout # In case the user is on the archive branch now.
    g.branch(archive_branch).delete if branches.include? archive_branch
    # Create archive branch (again, maybe).
    g.branch(archive_branch).checkout
    g.add
    g.commit("standard archive") unless g.status.changed.empty?
    # Finally, checkout the main repotask branch.
    g.branch(@branch).checkout
  end

end
