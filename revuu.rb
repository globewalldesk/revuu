require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# HELPERS
Dir["./helpers/*.rb"].each {|file| require file }
include Helpers
include DatePrettifier
include LanguageHelper
include HelpHelper
# CONTROLLERS
Dir["./controllers/*.rb"].each {|file| require file }
include TaskController
include TasklistController
# VIEWS
Dir["./views/*.rb"].each {|file| require file }
include TaskView
include TasklistView
# MODELS (all are classes so don't need to be 'include'-ed)
Dir["./models/*.rb"].each {|file| require file}

###############################################################################
# Program wrapper object
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
    start += intro
    # If no tasks, orient user. Note, 'help' method is in tasklist_view.rb.
    start += (new_user_text + help + "\n") unless
      File.exist?("./data/revuu.json")
    puts start
  end

  def intro
    intro = <<ENDINST
Revuu is a Ruby command line app to help you organize practical reviews of
programming tasks that you want to learn. You can add problems, solve them
with your favorite text editor, run the resulting script in Revuu, record
that you've done a review, and schedule more for the future. The developer
finds it to be a handy way to learn and solidify easy-to-forget skills.

ENDINST
  end

  def new_user_text
    newbie = <<NEWBIE
You're new to Revuu! Press 'n' to add your first task. Choose your text
editor with 'e' and your default programming language with 'p'. For a
general introduction and detailed instructions, press 'h'.
NEWBIE
  end

  # Load the default language and text editor ($lang, $texted).
  def load_defaults_from_settings
    initialize_settings_if_necessary
    settings_hash = load_settings_into_hash
    # Checks if 'lang' key exists. NOTE: REFACTORING SHOULD CREATE ONE.
    if settings_hash['lang']
      # Given a programming language name, return a Lang object, stored in a global.
      $lang_defaults = Lang.new(settings_hash['lang'])
    end
    # NOTE: WHEN REFACTORING, expand the following in case this setting is lost.
    # ALSO, ENSURE THAT THE USER STILL HAS THIS TEXT ED AVAILABLE! Require an
    # alternate if it has come unavailable.
    if settings_hash['texted']
      $texted = settings_hash['texted']
      $textedcmd = $text_editors[$texted]
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
    $textedcmd = $text_editors[edname]
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

  # After getting a language from Lang::choose_default, saves to defaults.
  def choose_default_language
    puts "OK, let's choose a default language."
    default = $lang_defaults.name ? $lang_defaults.name : 'Other'
    new_default = Lang.solicit_languages_from_user(default)
    if new_default != default
      update_settings_file({'lang' => new_default})
      $lang_defaults = Lang.new(new_default)
      puts "Saved #{$lang_defaults.name} as the default language."
    else
      puts "Sticking with #{default}."
    end
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
    when 'l'
      $tasks.clear_tag_search
      $tasks.display_tasks
    when 'd'
      $tasks.delete
    when 't'
      $tasks.tag_search
    when 'e'
      choose_text_editor
    when 'p'
      choose_default_language
    when 'b'
      save_backup_data
    when 'h'
      launch_instructions_system
      $tasks.display_tasks  # Redisplay tasklist after returning from help.
    when /\A(\d+)\Z/
      task = $tasks.validate_edit_request($1.to_i)
      task ? task.edit : (puts "Task not found.")
    when '>', '.'
      $tasks.nav('next')
    when '<', ','
      $tasks.nav('back')
    when '>>', '..'
      $tasks.nav('end')
    when '<<', ',,'
      $tasks.nav('top')
    when 'x'
      $tasks.show_next_item
    when 'q'
      return
    else
      puts 'Huh?' unless command == 'q'
    end
  end

end

App.new
