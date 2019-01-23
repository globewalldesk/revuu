module RepotaskController

  # Launches repotask display for user and prompts for input (e.g., open files,
  # save review, run answer, edit instructions, etc.).
  def launch_repotask_interface
    display_info # Different display from class Task.
    command = ''
    until command == 'q' or $auto_next
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
    when 'a'
      puts "Interpreting 'a' as '1'."
      open_file(1)
    when 'o'
      open_repo
    when 's' # Same as Task method.
      review_result = record_review
      # See TaskView#prompt_for_autonext.
      return command if review_result == 'done'
      if $auto_next and branch_reset_confirmed?(true) # true = exiting
        # Needed when leaving, to avoid git errors.
        reset_current_branch('skip_notice')
      else
        puts "Branch reset not confirmed; not quitting.\n\n"
        command = '' # Prevents quitting.
      end
    when 'r' # Execute the repotask's run_commands.
      run_answer
    when 'help', '?' # Launch help.
      launch_instructions_system
      display_info # Display the task after returning from help.
    when 'oo' # Switch to backup/archive repo and open.
      open_repo('old')
    when 'rr' # Run archived repo code.
      run_answer('old')
    when 'h'
      review_history
    when 'co'
      open_console
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
    when 'q', 'x' # Quit task view and return to tasklist.
      cache_answer_in_archive_branch
      if branch_reset_confirmed?(true) # true = exiting
        # Needed when leaving, to avoid git errors.
        reset_current_branch
      else
        puts "Branch reset not confirmed; not quitting.\n\n"
        command = '' # Prevents quitting.
      end
      $auto_next = true if command == 'x'
    else
      puts 'Huh?'
    end
    return command
  end

  def open_file(file)
    unless @files
      print "No files to open. Add some with 'fi'.\n\n"
      return
    end
    return unless checkout_before_open_or_run
    unless file.between?(1, @files.length)
      print "\nSorry, but (#{file}) is not the number of a file. You can add " +
            "a file to open\nwith the [fi]les command.\n\n"
      return
    end
    file = @files[file-1]
    system("#{$textedcmd} data/repos/#{@repo}/#{file}")
    puts "When you're done, don't forget to press 'r' to run."
  end

  def open_repo(old=false)
    return unless checkout_before_open_or_run(old)
    system("#{$textedcmd} data/repos/#{@repo}")
    puts "When you're done, don't forget to press 'r' to run."
  end

  def checkout_before_open_or_run(old=false)
    if old # We're switching to the task's old (archive) branch.
      # Check out the archive before launching the archive branch.
      return false unless safely_check_out_branch(@old_branch, 'oo')
    else # We're switching to the task's main branch.
      # Check out the branch (and reset the previous branch) if we're not on it.
      return false unless safely_check_out_branch
      # If we're on the task branch, it might be unclean. Double-check and
      # reset if necessary.
      return false unless branch_reset_confirmed?
    end
    return true
  end

  # This prompts the user for an "OK" to hard reset the branch (rolling back
  # the files); if so, resets and returns true; if not, returns false.
  # Automatically returns true if branch already reset this session, or if
  # a reset was not needed.
  def branch_reset_confirmed?(exiting = false)
    return true if @reset_this_session and ! exiting
    g = Git.open("data/repos/#{@repo}")
    # This will make the following status query correct.
    system("cd data/repos/#{@repo}&&git status -s")
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
      @reset_this_session = true
    end
  end

  def reset_current_branch(skip_notice = false)
    g = Git.open("data/repos/#{repo}")
    g.reset_hard
    # Remove untracked files (hard reset leaves them behind).
    system("cd data/repos/#{repo}&&git clean -qfdx -f")
    puts "\nBranch (#{@branch}) reset: files restored to original state." unless
      skip_notice
    @reset_this_session = true
  end

  def run_answer(old=false)
    return unless checkout_before_open_or_run(old)
    # If running the old (archive) repo, first check if the branch exists and
    # is different from the unedited starter version.
    if old
      g = Git.open("data/repos/#{@repo}")
      branches = g.branches.local.map {|b| b.full}
      if ! branches.include? @old_branch
        print "\nNo old branch to view. You haven't saved a solution to this " +
              "task yet.\n\n"
        return nil
      elsif system("cd data/repos/#{@repo}&&git diff #{branch} #{@old_branch} --quiet")
        print "\nNothing to run. The old (archived) task code is unchanged. " +
           "Maybe the task\nhas never been done?\n\n"
        return nil
      end
    end
    # OLD: commands = @run_commands.split("\n").join("&&")
    commands = @run_commands.split("\n")
    # OLD: commands = `cd data/repos/#{@repo}&&#{commands}`
    archive_msg = " " + "archive".colorize(background: @langhash.color) if old
    puts "\nRunning commands from ##{@id}#{archive_msg}:"
    puts ("=" * 75).colorize(@langhash.color)
    puts ''
    run_command_list(commands)
    puts ''
    puts ("=" * 75).colorize(@langhash.color)
  end

  def run_command_list(commands)
    pid = nil
    commands.each do |command|
      if command.split(': ')[0] == 'fork'
        pid = Process.fork do
          system("cd data/repos/#{@repo}&&#{command.split(': ')[1]}")
        end
        Process.wait(pid) if pid
      else
#        if command =~ /\Aruby/
#          puts "Running:"
#          puts "cd data/repos/#{@repo}&&bundle exec #{command}"
#          system("cd data/repos/#{@repo}&&bundle exec #{command}")
#        else
#          puts "Running:"
#          puts "cd data/repos/#{@repo}&&#{command}"
          system("cd data/repos/#{@repo}&&#{command}")
#        end
      end
    end
  end

  # If not already done, check out a git branch (the task's or the archive).
  # This is skipped if we're already on the branch we want. (The latter doesn't
  # guarantee that the tree is clean, as we might want it to be.)
  def safely_check_out_branch(branch=@branch, prompt='o')
    #puts "branch = #{branch}"
    #puts "@reset_this_session = #{@reset_this_session}"
    #puts "@reset_archive_this_session = #{@reset_archive_this_session}"
    # The task's branch is already checked out and it's the one we want?
    # Skip checkout.
    return true if @reset_this_session and branch == @branch
    # The archive's branch is already checked out and it's the one we want?
    # Skip checkout.
    return true if @reset_archive_this_session and branch == @old_branch
    # If you got here, then either another branch is checked out, and we
    # want the task's branch; OR the task's branch is checked out, and we
    # want the archive branch.
    g = Git.open("data/repos/#{@repo}")
    # Is the currently checked-out git branch the branch we want? No...
    if g.current_branch != branch
      # This will make the following status query correct.
      system("cd data/repos/#{@repo}&&git status -s")
      # Give scary warning if there are uncommitted changes.
      if branch == @branch
        unless g.status.changed.empty?
          if ! external_branch_reset_confirmed?(g.current_branch)
            puts "Not running. Branch #{g.current_branch} unchanged."
            # Escape if permission not granted by user.
            return nil
          else
            @reset_this_session = true # It soon will be...
            g.reset_hard # RESET!!!
            # Remove untracked files (hard reset leaves them behind).
            system("cd data/repos/#{repo}&&git clean -qfdx")
          end
        end
          # Forget the archive session regardless of reset.
          @reset_archive_this_session = false
      elsif branch == @old_branch
        # If I want the archive branch, the task branch is checked out and
        # clean, groovy--ready to switch.
        if g.status.changed.empty? and g.current_branch == @branch
          puts "Current branch of the #{@repo} repo is clean, so"
          puts "you're ready to switch to the archive branch for task #{@id}."
        # If I want the archive branch, the task branch is checked out but
        # NOT clean, make sure the user is OK with it.
        elsif ! g.status.changed.empty? and g.current_branch == @branch
          puts "The main branch of the #{@repo} repo has edits. If you want"
          puts "to view the archive, you can, but you'll lose all your changes."
          return nil unless old_checkout_confirmed?(prompt)
          g.reset_hard # RESET!!!
          # Remove untracked files (hard reset leaves them behind).
          system("cd data/repos/#{repo}&&git clean -qfdx")
        end
        # Regardless of whether the task's main branch was clean, it's been
        # reset (cleaned).
        @reset_this_session = false # Going away from maybe-dirty main branch.
        @reset_archive_this_session = true
        # If I want the archive branch, and another branch is checked out and
        # IT is clean, groovy--ready to switch. No need of comment.
      end
      # Check out needed branch in any case.
      g.branch(branch).checkout
    end
    true # We have the branch we want now.
  end

  # Get confirmation, if necessary, from user to switch to the archive branch.
  def old_checkout_confirmed?(prompt)
    # Return true if no changes yet to the current branch AND the user is on
    # the task's branch
    confirm = nil
    until ['y', 'n', ''].include? confirm
      puts "Confirm reset? (Enter for [y]es, or [n]o)"
      confirm = get_user_command(prompt)
    end
    if confirm == 'n'
      print "OK, branch not reset.\n\n"
      return false
    else
      return true
      # I.e., the user has confirmed that he's ready to switch from this
      # repo's current unclean branch to the archive branch. The actual switch
      # is performed in #safely_check_out_branch.
    end
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

    We need to switch to the "#{@branch}" branch before running. There are
    uncommitted changes to the currently checked-out branch,
    "#{current}". These changes could be an answer to a question,
    set-up of a new branch that was never saved (by being committed), or some
    random editing you might or might not want. First make sure, then answer:

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
    g = Git.open("data/repos/#{@repo}")
    # This will make the following status queries correct.
    system("cd data/repos/#{@repo}&&git status -s")
    # Skip making an archive if (1) we're in the archive branch, or (2) no
    # changes were made to the main task branch and we're in the main branch,
    # or (3) another branch is checked out already.
    # If we're in the archive branch, the main task branch was already reset.
    # If we're in another branch, we don't want to overwrite this one.
    return if ( (g.status.changed.empty? &&
                 g.current_branch == @branch) or # Covers case (2).
               g.current_branch != @branch) # Covers cases (1) and (3).
    # Delete any existing archive branch.
    branches = g.branches.local.map {|b| b.full}
    g.branch(@old_branch).delete if branches.include? @old_branch
    # Create archive branch (again, maybe).
    g.branch(@old_branch).checkout
    g.add
    g.commit("standard archive")
    # Finally, checkout the main repotask branch.
    g.branch(@branch).checkout
  end

end
