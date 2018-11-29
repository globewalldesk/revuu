class Repotask < Task
  extend RepotaskFactory
  include RepotaskController
  include RepotaskView

              # Attributes saved in tasks.json:
  attr_reader :repo, :branch, :files, :run_commands, :old_branch
              # All other attributes should be found in class Task.

  def initialize(args)
    super(args)
    @repo = args[:repo]
    @branch = args[:branch]
    @files = args[:files]
    @run_commands = args[:run_commands]
    # Step (2). (Step (1) is in Task#initialize.)
    if @saved # For use when loading old/existing tasks.
      @id = args[:id]
      @old_branch = calculate_old_branch
    else      # For use when creating neqw tasks.
      @id = calculate_id
      @old_branch = calculate_old_branch
      # Step (3).
      save_change_timestamp_to_settings # (a) Save change timestamp.
      save_new_task                     # (b) Save task to tasks.json.
      launch_repotask_interface # Actually launch the task view for the new task.
    end
    # Eventually, save new "defaults" (most recent choices) to settings and
    # otherwise update settings file; incl. @repo, @branch, and associated
    # commands at least.
  end

  def calculate_old_branch
    "#{@branch}_#{@id}_archive"
  end

end
