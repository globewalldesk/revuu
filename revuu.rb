require 'json'
require 'date'
require_relative 'lib/date_prettifier.rb'
include DatePrettifier
require 'colorize'
require 'chronic'
require_relative 'lib/answer.rb'
include Answer
require_relative 'lib/helper.rb'
include Helper

###############################################################################
# The Task class enables the user to input new tasks and do basic task manipulation.
class Task

  class << self
    # Factory methods for this task, prior to initialization.
    # Wrangles all necessary input from the user and submits it to Task.new, or
    # abandons adding the new task.
    def generate_new_task
      system("clear")
      header

      # Get task instructions from user.
      instructions = self.get_input(type: 'Instructions', prompt:
        "INPUT INSTRUCTIONS:\nOn the next screen, you'll type in the instructions for your new task.",
        required: true)
      return nil unless instructions # Instructions required.

      # NOTE: you probably need a whole new optional field: starter_code.
      # This would be automatically inserted into the 'answer' file for
      # the user's convenience, and it wouldn't necessarily need to be
      # included in the Task view screen (especially if it's very long).

      # Get tags from user.
      tags = self.get_input(type: 'Tags', prompt:
        "\nINPUT TAGS:\nOn the next screen, you'll input tags, separated by commas (optional).",
        required: false)
      tags = self.validate_tags(tags) if tags
      # Note: tags are not required.

      # Get language from user.
      lang = configure_initial_language

      # Get initial score from user.
      puts "\nINITIAL SCORE:"
      puts "Input initial score (5: mastered, 4: confident, 3: shaky, 2: barely recall, 1: blank)"
      score = get_user_command('n').to_i
      score = 1 unless [1, 2, 3, 4, 5].include? score
      self.new(instructions: instructions, tags: tags, score: score, lang: lang)
    end # of ::generate_new_task

    # Given a prompt and a test, wring an acceptable answer from the user or let
    # him abandon adding the new task.
    def get_input(args)
      while true
        args[:prompt] += "\nThen press Ctrl-W to save and Ctrl-X to submit. "
        args[:prompt] +=
          args[:required] ? "\nPress <Enter> now to continue... " :
            "\nPress <Enter> now to continue, or space-<Enter> to skip... "
        print args[:prompt]
        if gets.chomp == " " && ! args[:required]
          return nil
        end
        system("rm tmp/instructions.tmp") if File.file?("./tmp/instructions.tmp")
        system("pico tmp/instructions.tmp")
        input = File.read("./tmp/instructions.tmp").strip if File.file?("./tmp/instructions.tmp")
        if args[:required]
          if input
            if input.length < 3
              puts("Surely not long enough...")
            else
              puts "#{args[:type]} saved."
              return input
            end
          else
            args[:prompt] = "\n\nERROR: Some input is required here."
          end
        else
          input ? (puts "#{args[:type]} saved."; return input) : (return nil)
        end
      end
    end # of ::get_input

    def validate_tags(tags)
      # Convert user input string, which should be comma-separted, into array.
      tags = tags.split(',').map!(&:strip)
      # No tag should be over 20 characters long.
      return nil if tags.find { |tag| tag.length > 20 }
      tags # Otherwise, return the tag array.
    end

  end # of class methods

  attr_accessor :instructions, :tags, :score, :saved, :lang
  attr_reader :id, :date_started, :next_review_date, :all_reviews

  def initialize(args = {})
    args = defaults.merge(args)
    @instructions = args[:instructions]
    @tags = args[:tags]
    @score = args[:score]
    @saved = args[:saved]
    @lang = args[:lang]
    @id = args[:id]
    @date_started = args[:date_started]
    @next_review_date = args[:next_review_date]
    @all_reviews = args[:all_reviews]
    if @saved == false
      @id = calculate_id
      # First review is due immediately.
      @next_review_date = DateTime.now.to_s # Saved as string.
      save_new_task
    end
  end

  def defaults
    {
      tags: [],
      score: 1,
      saved: false,
      lang: $lang,
      date_started: DateTime.now.to_s,
      all_reviews: []
    }
  end

  # Converts task to hash for further conversion to JSON.
  def to_hash
    hash = {}
    self.instance_variables.each do |var|
      hash[var.to_s[1..-1]] = self.instance_variable_get var
    end
    hash
  end

  def edit # I.e., edit a particular, ID-numbered task.
    display_info
    # Prepare globals for use in Answer module.
    lang_data_hash = lookup_lang_data_from_name_cmd(@lang)
    assign_language_globals(lang_data_hash)
    get_locations(@id)
    command = ''
    until command == 'q'
      command = get_user_command('e')
      process_edit_input(command)
    end
    $tasks.display_tasks
  end

  def display_info
    system("clear")
    header
    puts '=' * 75
    puts "TASK INSTRUCTIONS:"
    puts @instructions
    puts '=' * 75
    date = DateTime.parse(@date_started).strftime("%-m/%-d/%Y")
    printf("  ID: %d   Started: %-10s   Reviews: %d   Score: %s\n",
      @id, date, @all_reviews.length, @score)
    last_date_timestamp = @all_reviews.empty? ?
      nil : @all_reviews.max_by {|r| r['review_date']}['review_date']
    last_precise_date = last_date_timestamp ?
      DateTime.parse(last_date_timestamp).strftime("%-m/%-d/%Y") : 'none yet'
    next_precise_date = DateTime.parse(@next_review_date).
      strftime("%-m/%-d/%Y")
    puts "  Review dates >>  Last: #{last_precise_date}  Next: #{next_precise_date} (#{prettify_timestamp(@next_review_date)})"
    puts "\nCOMMANDS  Review: [s]ave review  [a]nswer  [r]un answer  answers [h]elp"
    puts   "                  [c]onfigure language  [o]ld answers  [rr]un old answers"
    puts   "            Edit: [i]nstructions  [t]ags  [d]ate of next review  [sc]ore"
    puts   "            Also: re[f]resh view  [q]uit review and editing\n\n"
  end

  def process_edit_input(command)
    case command
    when 's' # Record information about review.
      record_review
    when 'a' # See Answer module for this and many of the next features.
      write_answer(self)
    when 'h'
      help_with_answers
      puts "Answer feature coming soon."
    when 'r'
      run_answer(self)
    when 'rr'
      run_answer(self, 'old')
    when 'o'
      view_old_answers(self)
    when 'c'
      configure_language(self)
    when 'i' # Edit instructions.
      edit_field('instructions')
    when 't' # Edit tags.
      edit_field('tags')
    when 'd' # Edit date of next review.
      date = get_next_review_date('d')
      save_review_date(date) if date
    when 'sc' # Edit score.
      edit_score
    when 'f'
      display_info
    else
      puts 'Huh?'
    end
  end

  def record_review
    puts "Good, you completed a review."
    # Get @score from user.
    score = get_score('r')
    return unless score
    # Get @next_review_date from user.
    date = get_next_review_date('r')
    return unless date
    # Update current @score.
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

  def get_score(prompt)
    puts "Input score (5: mastered, 4: confident, 3: shaky, 2: barely recall, 1: blank)"
    score = get_user_command(prompt).to_i
    unless [1, 2, 3, 4, 5].include?(score)
      puts "Score must be between 1 and 5."
      return nil
    end
    score
  end

  def edit_field(field)
    # Load current attribute contents into temp file.
    contents = (field == 'tags' ?
      (self.instance_variable_get("@#{field}").join(', ') if
      self.instance_variable_get("@#{field}") ) :
      self.instance_variable_get("@#{field}") )
    File.write("./tmp/#{field}.tmp", contents)
    # Open file for editing.
    system("pico tmp/#{field}.tmp")
    # Save upon closing: grab text.
    attrib = File.read("./tmp/#{field}.tmp").strip
    if attrib.empty?
      if field == 'instructions'
        puts "ERROR: Instructions cannot be blank."
      end
      return nil
    end
    # Use validation method if field type is tags.
    if field == 'tags'
      attrib = self.class.validate_tags(attrib)
      unless attrib
        puts "ERROR: tags must be comma-separated and at most 20 characters long."
        return nil
      end
    end
    # Set instance variable to contents of edited temp file.
    self.instance_variable_set("@#{field}", attrib)
    # Save updated instructions to JSON file if you've made it this far.
    $tasks.save_tasklist
    # Refresh view.
    display_info
  end

  def get_next_review_date(prompt)
    puts "Do next review when? (Use regular English.)"
    date = get_user_command(prompt)
    date = Chronic.parse(date) # Gem parses ordinary English input to Time obj.
    unless date.class == Time
      puts "ERROR: couldn't parse date."
      return nil
    end
    date = DateTime.parse(date.to_s).to_s # Convert Time to DateTime string.
    pretty = DateTime.parse(date).
      strftime("%-m/%-d/%Y (#{prettify_timestamp(date)})")
    date
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

  private
    def calculate_id
      if ! $tasks.list.empty?
        max = $tasks.list.max_by { |t| t.id.to_i }
        max.id.to_i + 1
      else
        1
      end
    end

    def calculate_next_review_date
      "placeholder"
    end

    def save_new_task
      @saved = true
      # Add object to $tasks.list.
      $tasks.list << self
      # Save the tasklist.
      $tasks.save_tasklist
    end

end # of class Tasks

###############################################################################
class TaskList
  attr_accessor :list
  def initialize
    @list = []
    load_all_tasks
  end

  def load_all_tasks
    # Let it work without the datafile existing.
    if (File.exist?("./data/revuu.json") &&
      File.stat("./data/revuu.json").size > 0)
      file = File.read "./data/revuu.json"
      data = JSON.parse(file)
      task_array = data['tasks']
      construct_tasks_array(task_array)
      puts "Tasks loaded.\n\n"
      display_tasks('first screen')
    end
  end

  def construct_tasks_array(task_array)
    task_array.each do |task|
      task_with_symbols = {}
      task.each {|k,v| task_with_symbols[k.to_sym] = v }
      @list << Task.new(task_with_symbols)
    end
  end

  def display_tasks(first_screen=nil, dlist=@list)
    system("clear") unless first_screen
    header unless first_screen
    colored = false
    printf("%5s| %-47s| %-20s\n", 'ID', 'Instructions (first line)', 'Due date')
    puts '=' * 75
    if ! dlist.empty?
      dlist.sort!{|x,y| DateTime.parse(x.next_review_date) <=>
        DateTime.parse(y.next_review_date)}
      dlist[0..10].each do |task|
        # Grab the first 45 characters of the first line of @instructions
        instr = task.instructions[0..45].split("\n")[0]
        line = sprintf("%5s| %-47s| %-20s", task.id, instr,
          prettify_timestamp(task.next_review_date))
        puts(colored ? line.colorize(:color => :green) : line)
        colored = !colored
      end
    else
      puts "\nThere are no tasks yet. Press 'n' to add one.\n\n"
    end
  end

  def save_tasklist
    # Convert $tasks.list to JSON.
    json = to_json
    # Overwrite datafile.
    File.open("./data/revuu.json", "w") do |f|
      f.write(json)
    end
  end

  def to_json
    JSON.pretty_generate({"tasks": @list.map{|task| task.to_hash } })
  end

  def delete
    print "WARNING! CANNOT UNDO!\nType number of task to delete: "
    delete_num = gets.chomp.to_i
    delete_task = @list.find {|t| t.id == delete_num}
    @list.delete(delete_task)
    save_tasklist
    display_tasks
  end

  def validate_edit_request(num)
    @list.find {|t| t.id == num }
  end

  def tag_search
    # Prepare tag-based arrays.
    prepare_hash_of_tag_arrays  # Stored in $tag_hash.
                                # NOTE: Probably not necessary every time.
    if $tag_hash.empty?
      puts "No tags found."
      return nil
    end
    # Get search term (tag) from user.
    default_text = $default_tag.nil? ? '' :
    " (<enter> for '#{$default_tag}')"
    puts "Enter tag#{default_text}."
    tag = get_user_command('t')
    # If default tag exists and user hit <enter> alone, use default tag.
    if (!$default_tag.nil? && tag == '')
      tag = $default_tag
    end
    tag_match = $tag_hash.keys.find { |k| tag.downcase == k.downcase }
    # Display results. If not found, say so.
    if tag_match
      # Assign default tag to input.
      $default_tag = tag_match
      # Display list.
      display_tasks(nil, $tag_hash[tag_match])
    else
      puts "'#{tag}' not found."
    end
  end

  def prepare_hash_of_tag_arrays
    $tag_hash = {}
    $tasks.list.each do |task|
      next unless task.tags
      task.tags.each do |tag|
        $tag_hash[tag] = [] unless $tag_hash[tag]
        $tag_hash[tag] << task
      end
    end
  end

end # of class TaskList


###############################################################################
# Instantiate program wrapper object
class App
  def initialize
    system("clear")
    start_text
    load_defaults_from_settings
    $tasks = TaskList.new
    app_loop
  end

  def start_text
    wd = 75
    logo = "* R * E * V * U * U *"
    start = logo.center(wd)
    line = ('=' * logo.length).center(wd)
    start = line + "\n" + start + "\n" + line
    start = "\n\n\n" + start + "\n\n\n"
    start += instructions
    puts start
  end

  def instructions
    instructions = <<ENDINST
Revuu is a Ruby command line app to help you organize practical reviews of
tasks (such as programming tasks) that you want to memorize. Revuu uses
"spaced repetition"#{8212.chr("UTF-8")}practice sessions that get less frequent with each
successful review.

ENDINST
    instructions += $help + "\n\n"
  end

  # Load the default language and text editor ($lang, $texted).
  def load_defaults_from_settings
    initialize_settings_if_necessary
    settings_hash = load_settings_into_hash
    if settings_hash['lang']
      lang_hash = lookup_lang_data_from_name_cmd(settings_hash['lang'])
      # Assign associated language globals (such as $lang and $ext).
      assign_language_globals(lang_hash)
    end
    # NOTE: WHEN REFACTORING, expand the following in case this setting is lost.
    if settings_hash['texted']
      $texted = settings_hash['texted']
    end
  end

  def choose_text_editor(choice_required = false)
    # Display text editors available on the user's system.
    available_editors = display_list_of_editors_to_user
    editor_num = nil
    # Select new editor; two circumstances of doing so:
    # user is required to choose an editor if none is saved in settings...
    if choice_required
      until editor_num.between?(0,available_editors.length)
        # Let user select new editor.
        puts "Please select which one you'll use to write answers."
        editor_num = get_user_command('e') - 1
        puts "Choose a number between 1 and #{available_editors.length}." unless
          editor_num.between?(0,available_editors.length)
      end
    else # ...or user is simply switching editors. (Can return nil.)
        puts "Please select which one you'll use to write answers."
        editor_num = get_user_command('e').to_i - 1
        unless editor_num.between?(0,available_editors.length)
          puts "Sticking with #{$texted}."
          return nil
        end
    end
    # Reset text editor global ($texted).
    edname = available_editors[editor_num]
    puts "OK, you'll use #{edname}."
    $texted = $text_editors[edname]
    update_settings_file({'texted' => edname})
    # Double-check that editor is still available.
  end

  # Both compiles a list of available editors and displays them to the user.
  def display_list_of_editors_to_user
    puts "Text editors on your system:"
    width = 0
    # Actually do the displaying. Note, available_editors is a method.
    available_editors.each_with_index do |editor,i|
      item = "(#{i+1}) #{editor} "
      if item.length + width >= 75
        puts('')
        width = 0
      end
      width += item.length
      print item
    end
    puts ''
    return available_editors
  end

  def available_editors
    # Given list of text editors, return those available on this system.
    eds = $text_editors.select do |nm,cmd|
      `which #{cmd}`.length > 0
    end
    eds.keys.sort # Alpha order names and return as array.
  end

  def app_loop
    command = nil
    until command == 'q'
      command = get_user_command('=')
      process_input(command)
    end
    puts "\nAll data is automatically saved. Goodbye until next time!"
  end


  def process_input(command)
    case command
    when 'n'
      task = Task.generate_new_task
      puts task ? "New task saved." :
        "Task input abandoned or failed."
    when 'c', 'h', 'help', '?'
      puts $help
    when 'l'
      $tasks.display_tasks
    when 'd'
      $tasks.delete
    when 't'
      $tasks.tag_search
    when 'e'
      choose_text_editor
    when 'i'
      system 'clear'
      puts header
      puts $introduction
      puts $help
    when /\A(\d+)\Z/
      task = $tasks.validate_edit_request($1.to_i)
      task ? task.edit : (puts "Task not found.")
    when 'q'
      return
    else
      puts 'Huh?'
    end
  end

end

App.new

# "Create account" command (tags maybe handle this OK; but accounts might
# be better)
# Statistics
