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
    :page_num, :history
  def initialize
    @list = []
    @tasklist_filter = 'all'
    @page_num = 1
    load_all_tasks
    $tasks = self # class Task & class Archiv need access for saving etc.
    @history = load_history
    display_tasks('first screen')
    app_loop
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
    load_history
  end

  private
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
          # It's a Repotask if it has a :repo key.
          task_with_symbols[:repo] ?
            @list << Repotask.new(task_with_symbols) :
            @list << Task.new(task_with_symbols)
        end
        @list = @list.sort!{|x,y| DateTime.parse(x.next_review_date) <=>
          DateTime.parse(y.next_review_date)}
      end
    end

    def load_history
      start = Time.now
      reviews = {}
      @list.each do |t|
        t.all_reviews.each {|r| reviews[r['review_date']] = t}
      end
      @history = reviews.sort_by {|timestamp,task| timestamp }.reverse
    end

    # Accepts the display number (NOT ID) of a task and attempts to delete it.
    # Return user message (whether successful or not). RF
    def delete_task(num)
      task = fetch_task_from_displayed_number(num)
      # Prepare info about the task deleted to send back to user.
      if @list.delete(task) # Recall that Array#delete returns nil if not found.
        delete_task_files(task)
        save_tasklist
        message = delete_message(task)
        return "Deleted:\n#{message}\n\n"
      else
        return "'#{num}' not found; nothing deleted.\n\n"
      end
    end

    def delete_message(task)
      message = "(#{task.lang}) "
      message += task.instructions.split("\n")[0][0..20]
      message += '...' if task.instructions.split("\n")[0][0..20] !=
                        task.instructions.split("\n")[0]
      message += " (ID ##{task.id.to_s})"
    end

    # Delete any files associated with the task to delete. RF
    def delete_task_files(task)
      return nil unless defined?(task.id)
      ending = "#{task.id}.#{task.langhash.ext}"
      dir = determine_directory(task.id)
      # Delete current answer.
      system("rm data/answers/#{dir}/answer_#{ending}") if
        File.exist? "data/answers/#{dir}/answer_#{ending}"
      # Delete archive.
      system("rm data/answers/#{dir}/answer_old_#{ending}") if
        File.exist? "data/answers/#{dir}/answer_old_#{ending}"
      # Delete code starter.
      system("rm data/starters/#{dir}/starter_#{ending}") if
        File.exist? "data/starters/#{dir}/starter_#{ending}"
    end

    # Start over. Delete all data in tasks.json, starters/, and answers/. Results
    # in a clean install, ready to add new tasks.
    def destroy_all
      begin
        if user_confirms_destruction
          # Actually perform the file deletions.
          system("rm data/tasks.json")
          puts "tasks.json removed..."
          system("rm data/settings.json")
          puts "settings.json removed..."
          system("rm -f answers/*")
          puts "answers/ removed..."
          system("rm -f starters/*")
          puts "starters/ removed..."
          system("rm -rf repos/*")
          puts "repos/ removed..."
          # The following triggers exit from TaskList loop to App for reloading.
          $destroyed_data = true
          puts "All tasks destroyed."
          print "Press any key to continue..."
          gets
          clear_screen
        else
          return "Nothing destroyed. Remember, you can back up your data with [a]rchive."
        end
      rescue => err
        return "There was an error: #{err}"
      end
    end



end # of class TaskList
