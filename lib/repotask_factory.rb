# "Factory module" that prepares the data needed to initialize a Task of the
# RepoTask variety.
module RepotaskFactory

  # Cf. TaskFactory#generate_new_task; uncommented items might be commented
  # there.
  def generate_new_repotask
    clear_screen
    task_data = {saved: false}
    lang = ''
    repo = ''   # Used by get_branch & get_files.
    branch = '' # Used by get_files.
    new_task_lambdas = [
      # Get repo for this task.
      { repo: -> { get_repo } },
      # Get git branch.
      { branch: -> { get_branch(repo) } },
      # Get list of files user will have to edit in order to do task.
      { files: -> {  puts "CHOOSE FILES:"; get_files(repo, branch) } },
      # The next three are the same as TaskFactory.
      { lang: -> { get_initial_language_from_user('r') } }, # In TaskFactory.
      { instructions: -> { get_instructions_from_user(lang) } }, # Ditto.
      { tags: -> { get_tags_from_user(lang) } },                 # Ditto.
      # Get command(s) needed to run the app.
      { run_commands: -> { get_run_commands } }
    ]
    new_task_lambdas.each do |lhash|
      lhash.each do |label, methd|
        value = methd.call
        return nil if value == 'q' # Quit abandons task-making.
        # This is the list of required values.
        if (value.nil? && [:repo, :branch, :lang, :instructions,
                           :tags].include?(label))
          return nil # Abandon task-making if a required value is missing.
        end
        task_data[label] = value
        repo = value    if label == :repo # Needed for later lambdas.
        branch = value  if label == :branch
        lang = value    if label == :lang # Ditto.
        clear_screen
      end
    end
    Repotask.new(task_data)
  end

  ############################################################################
  # REPO METHODS
  # Extracts and returns choice of repo or 'q' from user, or returns nil.
  def get_repo
    return nil unless repo_exists?
    puts "CHOOSE REPO:"
    repo = solicit_choice_of_repo_from_user
  end

  # Checks for an actual repo in repos/. Just needs to be a directory; could
  # be empty.
  def repo_exists?
    result = Dir["./data/repos/*"].any? do |item|
      File.directory?(item)
    end
    unless result
      puts "You have no repos. Please make some (get [h]elp if necessary)."
      print "Press Enter to continue..."
      gets
    end
    result
  end

  def solicit_choice_of_repo_from_user
    puts "Choose the repo that you'll be making the task about."
    puts "Your repos (in data/repos/):"
    # First, get a list of actual directories in data/repos/.
    repos = Dir["data/repos/*"].select{|r| File.directory?(r)}
    repos.map! {|r| r.split("/")[-1]} # Only want the folder names themselves.
    repo = wrap_items_with_numbers(repos) # Returns user choice.
  end

  ############################################################################
  # GIT BRANCH METHODS
  # Extracts and returns choice of branch or 'q' from user, or returns nil.
  def get_branch(repo)
    return nil unless branch_exists?(repo)
    puts "CHOOSE GIT BRANCH:"
    branch = solicit_choice_of_branch_from_user(repo)
  end

  # Return boolean: does the repo have a git branch?
  def branch_exists?(repo)
    begin
      g = Git.open("data/repos/#{repo}")
      g.branches.local.find {|b| b.full} # A branch has a "full" name.
    rescue
      puts "Directory '#{repo}' hasn't been initialized with git yet."
      puts "Please navigate to it, type 'git init', and make a branch."
      print "Press Enter to continue..."
      gets
      nil
    end
  end

  def solicit_choice_of_branch_from_user(repo)
    g = Git.open("data/repos/#{repo}")
    branches = g.branches.local
                .map {|b| b.full}
                .reject {|b| b =~ /\d\_archive$/}
    puts "Choose the git branch your task is based on."
    puts "WARNING! Your latest commit, whatever it is, will be used."
    puts "Revuu never makes git commits for you, but will reset to the latest.\n\n"
    puts "Your branches:"
    branches = sort_branches_by_git_commit_order(repo, branches)
    branch = wrap_items_with_numbers(branches)
  end

  # I want the branches in order of most recent commit. ruby-git doesn't
  # seem to support this, so I had to do this hacky thing.
  def sort_branches_by_git_commit_order(repo, branches)
    branches_ordered = `cd data/repos/#{repo}&&git for-each-ref --sort=committerdate`
    branches_ordered = branches_ordered.split("\n")
                                       .reverse
                                       .map {|br| br.split('/')[-1]}
    # Now, re-order branches in the same order.
    branches.sort! do |x,y|
      branches_ordered.find_index(x) <=> branches_ordered.find_index(y)
    end
    branches
  end

  ###########################################################################
  # FILES METHODS
  # Extracts and returns an array of files (maybe just one long) that the
  # user will change in order to do the task.
  def get_files(repo, branch, existing_choices = [])
    begin
      checkout_branch(repo, branch) # Files might only be available on one branch.
      return nil unless any_files_exist?(repo)
      files = all_repo_files(repo)
      user_chosen_files = get_file_array_from_user(files, existing_choices)
    rescue Exception => e
      print "Sorry, you can't use that branch:\n\n"
      puts e
      print "\nPress any key to continue..."
      gets
      return 'q'
    end
  end

  # As the title says: given a repo and a branch, check it oooouuuuut!
  def checkout_branch(repo, branch)
    g = Git.open("data/repos/#{repo}")
    g.branch(branch).checkout
  end

  # Return boolean: does the repo have any files at all?
  def any_files_exist?(repo)
    all_repo_files(repo).length > 0
  end

  def all_repo_files(repo)
    Dir[ File.join("data/repos/#{repo}", '**', '*') ]
       .reject {|d| File.directory? d}
       .reject {|f| f =~ /tmp\// || f =~ /bin\//}
       .map {|f| f.gsub!("data/repos/#{repo}/", '') }
       #.sort
  end

  # existing_choices is a file array provided by the presently-existing
  # Repotask#files. Used when get_files is called from the Repotask view.
  def get_file_array_from_user(files, existing_choices)
    puts <<~GETFILES
      To do the task, the user will have to edit some files. Please specify
      which files. NOTE: Press Enter by itself to finish (or skip).
    GETFILES
    user_chosen_files = existing_choices
    files -= existing_choices
    ans = nil
    file = nil
    until file == ''
      # Show files with choice
      unless user_chosen_files.empty?
        puts "\nFiles you've chosen so far: "
        show_array_with_numbers(user_chosen_files)
        puts "Files remaining:"
      end
      # 'true' on next line allows user to return choice of ''.
      file, remove = wrap_items_with_numbers(files, true, true) unless
        files.empty?
      return 'q' if file == 'q'
      break if file == ''
      # If wrap_items_with_numbers returns a removal, then it returns an
      # integer (the number of the file to remove from user_chosen_files).
      if remove
        file = user_chosen_files[file - 1]
        user_chosen_files -= [file]
        files << file
        file = nil # Because otherwise this will be added in again. This code sucks!
      end
      # If there are no more files choice, ask user to confirm or remove one.
      if files.empty?
        print "  No files remaining.\n\n"
        user_chosen_files_copy = user_chosen_files.dup
        user_chosen_files, removed_file =
          remove_file_from_complete_list(user_chosen_files)
        return 'q' if removed_file == 'q'
        files = [removed_file] if removed_file
      end
      break if files.empty? # 'files' array might be no longer empty.
      files -= [file]
      (user_chosen_files << file) if file
    end
    user_chosen_files ? user_chosen_files : nil
  end

  def remove_file_from_complete_list(files)
    puts "You've included all files from the repo for editing. Press Enter"
    puts "to confirm or enter the number of a file to remove."
    response = wrap_items_with_numbers(files, true)
    return 'q' if response == 'q'
    response = response == '' ? nil : response
    return (files - [response]), response
  end

  ############################################################################
  # RUN COMMANDS METHOD
  def get_run_commands
    puts "INPUT RUN COMMANDS:\n"
    run_commands = launch_external_input_for_new_task(
      type: 'run_commands',
      prompt: "On the next screen, enter at least one command line\n" +
              "command needed to see the code in action. Required.",
      required: true )
  end

end
