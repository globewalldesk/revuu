###############################################################################
# TaskLists contain, most importantly, a sorted array of tasks and come with
# various helpers for CRUD functions with respect to tasks, although the
# actual display and editing of tasks is handled by class Task. RF
class TaskList
  include TasklistController
  include TasklistView
  attr_accessor :list
  # These might not need accessors; I'm just listing them for clarity.
  attr_reader :displayed_tasks, :tag_filtered_list, :filter_tag, :default_tag,
    :page_num
  def initialize
    @list = []
    @tasklist_filter = 'all'
    @page_num = 1
    load_all_tasks
    $tasks = self # class Task & class Archiv need access for saving etc.
    display_tasks('first screen')
    app_loop
  end

  # Loads contents of tasks.json into an array that is iterated in order to
  # output @list. RF
  def load_all_tasks
    # Let it work without the datafile existing.
    if (File.exist?("./data/tasks.json") &&
      File.stat("./data/tasks.json").size > 0)
      file = File.read "./data/tasks.json"
      data = JSON.parse(file)
      task_array = data['tasks']
      task_array.each do |task|
        task_with_symbols = {}
        task.each {|k,v| task_with_symbols[k.to_sym] = v }
        @list << Task.new(task_with_symbols)
      end
      @list = @list.sort!{|x,y| DateTime.parse(x.next_review_date) <=>
        DateTime.parse(y.next_review_date)}
    end
  end

  # Overwrites tasks.json datafile with the latest tasklist data. RF
  def save_tasklist
    # Convert @list to JSON.
    json = JSON.pretty_generate({"tasks": @list.map{|task| task.to_hash } })
    # Overwrite datafile.
    File.open("./data/tasks.json", "w") do |f|
      f.write(json)
    end
    save_change_timestamp_to_settings
  end

  # Accepts the display number (NOT ID) of a task and attempts to delete it.
  # Return info for user about deleted task, or false if unsuccessful. RF
  def delete_task(num)
    task = fetch_task_from_displayed_number(num)
    # Prepare info about the task deleted to send back to user.
    if @list.delete(task) # Recall that Array#delete returns nil if not found.
      message = "(#{task.lang}) "
      message += task.instructions.split("\n")[0][0..20]
      message += '...' if task.instructions.split("\n")[0][0..20] !=
                        task.instructions.split("\n")[0]
      message += " (ID ##{task.id.to_s})"
      delete_task_files(task)
      save_tasklist
      return "Deleted:\n#{message}"
    else
      return "'#{num}' not found; nothing deleted."
    end
  end

  # Delete any files associated with the task to delete. RF
  def delete_task_files(task)
    return nil unless defined?(task.id)
    ending = "#{task.id}.#{task.langhash.ext}"
    # Delete current answer.
    system("rm data/answers/answer_#{ending}") if
      File.exist? "data/answers/answer_#{ending}"
    # Delete archive.
    system("rm data/answers/answer_old_#{ending}") if
      File.exist? "data/answers/answer_old_#{ending}"
    # Delete code starter.
    system("rm data/starters/starter_#{ending}") if
      File.exist? "data/starters/starter_#{ending}"
  end

  # Start over. Delete all data in tasks.json, starters/, and answers/.
  def destroy_all
    begin
      if user_confirms_destruction
        # Actually perform the file deletions.
        system("rm data/tasks.json")
        system("rm data/settings.json")
        # Save the user's old settings in new settings file.
        update_settings_file({lang: $lang_defaults.name, texted: $texted})
        system("rm -f answers/*")
        system("rm -f starters/*")
        # Reload the goods.
        load_defaults_from_settings
        TaskList.new
        sleep 1 # Pause for dramatic effect.
        return "All tasks destroyed."
      else
        return "Nothing destroyed. Remember, you can back up your data with [a]rchive."
      end
    rescue => err
      return "There was an error: #{err}"
    end
  end

end # of class TaskList
