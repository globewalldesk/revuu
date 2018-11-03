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
include ArchivController
# VIEWS
Dir["./views/*.rb"].each {|file| require file }
include TaskView
include ArchivView
# MODELS (all are classes so don't need to be 'include'-ed)
Dir["./models/*.rb"].each {|file| require file}

###############################################################################
# Program wrapper object
class App

  def initialize
    system("clear")
    start_text
    load_defaults_from_settings
    TaskList.new
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
      File.exist?("./data/tasks.json")
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

end

App.new
