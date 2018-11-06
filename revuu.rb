require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# HELPERS
Dir["./helpers/*.rb"].each {|file| require file }
include Helpers
include DatePrettifier
include HelpHelper
include SettingsHelper
include WrappingHelper
# CONTROLLERS
Dir["./controllers/*.rb"].each {|file| require file }
include TaskController
include ArchivController
# VIEWS
Dir["./views/*.rb"].each {|file| require file }
include TaskView
include ArchivView
# MODELS (all are classes)
Dir["./models/*.rb"].each {|file| require file}

###############################################################################
# Program wrapper object
class App

  def initialize
    system("clear")
    start_text
    # From here you always view the tasklist; if you exit the tasklist while
    # $view_archive is true, you enter the archive system; otherwise, you quit
    # the app altogether.
    loop do
      $view_archive = false
      load_defaults_from_settings # Assigns a number of settings globals.
      TaskList.new
      $view_archive ? (Archiv.launch_archive_system; clear_screen) : break
    end
  end

  def start_text
    wd = 75 # Standard line width, could be made into a global.
    logo = "* R * E * V * U * U *"
    start = logo.center(wd)
    # Center the logo.
    line = ('=' * logo.length).center(wd)
    # Introductory padding and text on startup.
    puts "\n\n\n" + line + "\n" + start + "\n" + line + "\n\n\n" + intro
    # NB if no tasks, orient user. Note, 'help' method is in tasklist_view.rb.
    puts (new_user_text + help + "\n") unless File.exist?("./data/tasks.json")
  end

  # Shown to everyone, only on startup.
  def intro
    intro = <<~ENDINST
    Revuu is a Ruby command line app to help you organize practical reviews of
    programming tasks that you want to learn. You can add problems, solve them
    with your favorite text editor, run the resulting script in Revuu, record
    that you've done a review, and schedule more for the future. The developer
    finds it to be a handy way to learn and solidify easy-to-forget skills.

    ENDINST
  end

  # Shown only if user has no tasks loaded.
  def new_user_text
    newbie = <<~NEWBIE
    No tasks are loaded! Press 'n' to add your first task or press 'a' to load
    a task list from the archive. Choose your text editor with 'e' and your
    default programming language with 'p'. For a general introduction and
    detailed instructions, press 'h'.
    NEWBIE
  end

end

App.new
