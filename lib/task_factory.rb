# This module has the main methods needed to compile the data needed to create
# a new task. It is a mixin (extension) of class Task.
module TaskFactory

  # Prepares data for new task.
  # Launched only by tasklist 'n' command. Compiles data needed to create a
  # task. At end, calls Task#new and returns the new task instance (or nil).
  # Note, this is basically just a series of user interfaces that prompt for
  # input and offer to skip (sometimes) or to quit. Quitting returns nil. RF
  def generate_new_task
    clear_screen
    # This is a hash we'll be passing to Task.new, which uses saved: false in
    # order to signal #initialize to populate
    new_task_data = {saved: false}
    lang = '' # Capture lang value when created; used in lambdas below.
    # Create methods array: these are the methods needed to generate task data.
    # Labels correspond to Task attributes.
    new_task_lambdas = [
      { lang: -> { get_initial_language_from_user } },
      { instructions: -> { get_instructions_from_user(lang) } },
      { starter: -> { starter_arg = (lang == 'Java' ? 'Java' : false);
        starter_code_sequence(starter_arg) } },
      { tags: -> { get_tags_from_user(lang) } }
    ]
    # Iterate above lambdas; abandon task-making if 'q', or when nil if
    # required. Otherwise, use returned values in new_task_data hash.
    new_task_lambdas.each do |lhash|
      lhash.each do |label, methd|
        value = methd.call
        return nil if value == 'q' # Quit abandons task-making.
        # This is the list of required values.
        if [:lang, :instructions, :tags].include? label && value.nil?
          return nil # Abandon task-making if a required value is missing.
        end
        new_task_data[label] = value
        lang = value if label == :lang # Grab the lang; needed for later lambdas.
      end
    end
    # Construct new task!
    Task.new(new_task_data)
  end # of ::generate_new_task

  # Get language from user; returns a canonical, approved name for saving. RF
  def get_initial_language_from_user
    puts "CHOOSE LANGUAGE:"
    lang = Lang.solicit_languages_from_user('n', $lang_defaults.name)
  end

  # Just a wrapper for launch_external_input... and instructions. RF
  def get_instructions_from_user(lang)
    instructions = launch_external_input_for_new_task(type: 'Instructions',
        prompt: "INPUT INSTRUCTIONS:\nOn the next screen, you'll type in the " +
        "instructions for your new task. ", required: true)
    instructions = (instructions == 'q' || instructions.nil?) ? instructions :
      wrap_overlong_paragraphs(instructions, lang.length)
  end

  # Asks the user if he wants to write some starter code. If so, opens a temp
  # file in the text editor, then grabs the text when the user gives the OK,
  # deletes the file, and returns the text (or nil). RF
  def starter_code_sequence(java=nil) # Lang needed for file extension.
    starter_desired = get_starter_code?
    return 'q' if starter_desired == 'q'
    if starter_desired
      launch_external_input_for_new_task(type: 'Starter', required: false, prompt:
        "Edit the starter code on the next screen.",
        java: java)
    else
      nil
    end
  end

  # Ask user if he wants to edit starter code up front. RF
  def get_starter_code?
    puts "\nEDIT STARTER CODE:"
    starter_decision = nil
    loop do
      puts "Edit some starter code (you can do this later)?"
      puts "<Enter> for [y]es, [n]o, or [q]uit."
      starter_decision = get_user_command('n')
      break if ('ynq'.include? starter_decision || starter_decision == '')
    end
    return 'q' if starter_decision == 'q'
    (starter_decision == 'y' || starter_decision == '') ? true : false
  end

  # Solicit tags from user (not required). RF
  def get_tags_from_user(lang)
    puts "\nINPUT TAGS:"
    tag_decision = nil
    loop do
      puts "Edit tags (you can do this later)?"
      puts "<Enter> for [y]es, [n]o, or [q]uit."
      tag_decision = get_user_command('n')
      break if ('ynq'.include? tag_decision || tag_decision == '')
    end
    return 'q' if tag_decision == 'q'
    tag_decision = (tag_decision == 'y' || tag_decision == '') ? true : false
    if tag_decision
      tags = launch_external_input_for_new_task(type: 'Tags', prompt:
        "Edit tags on the next screen; language-related tags are added automatically.",
        required: false)
    else
      tags = nil
    end
    # Add standard tags and "massage" user-input tags.
    prep_tags(tags, lang)
  end

  # Massage user-input tags so they're standardized. Returns tag array. RF
  def prep_tags(tags, lang)
    # Convert newlines to commas.
    tags.gsub!("\n", ',') if tags
    # Convert user input string, which should be comma-separated, into array.
    # This also initializes a tag array if user didn't input any tags.
    tags = (tags ? tags.split(',').map!(&:strip) : [])
    # List = this language name + any alts
    lang_name_variants = Lang.all_lang_names_and_alts(lang)
    # Remove any tags that (case-insensitively) match langs to reject.
    tags.reject! {|tag| lang_name_variants.any? {|l| /\A#{l}\Z/i.match(tag) } }
    # Making use of an accessor of the Lang class variable 'defined_langs',
    # first 'find' the hash matching the param 'lang'; return [:alts] value.
    lang_alts = Lang.defined_langs.find {|l| l[:name] == lang }[:alts]
    # Put in canonical language tags; splat operators ensure that subarrays aren't created.
    lang_name_variants.concat(tags)
  end

  # Given a prompt and a test, wring an acceptable answer from the user or let
  # him abandon adding the new task. Returns input, nil, or 'q'. RF
  def launch_external_input_for_new_task(args) # :prompt, :type, :required, :java
    args[:prompt] = (args[:prompt] ? "\n" + args[:prompt] : "\n")
    args[:prompt] += "\nPress Ctrl-W to save and Ctrl-X to submit. " +
                     "\nPress <Enter> now to continue or [q]uit."
    # Loop = solicit input in external file; verifies or else prompts again.
    loop do
      puts args[:prompt]
      choice = get_user_command('n')
      return 'q' if choice == 'q' # Quit to abandon task-creation.
      input = get_input_from_external_file(args)
      if args[:required]
        if input && input.length > 0
          puts "#{args[:type]} saved."
          return input
        else
          puts "\n\nPLEASE NOTE:\n#{args[:type]} required."
        end
      else # input not required
        input ? (puts "#{args[:type]} saved."; return input) : (return nil)
      end
    end
  end

  # Given some arguments, prep and open a temporary file for user input; then
  # get input from it and return it. RF
  def get_input_from_external_file(args)
    tempfile = "tmp/#{args[:type].downcase}.tmp"
    system("rm #{tempfile}") if File.file?(tempfile) # Just to be safe.
    File.write(tempfile, java_starter) if args[:java] # java_starter in TaskView module.
    system("pico #{tempfile}")
    input = File.read(tempfile).strip if File.file?(tempfile)
    system("rm #{tempfile}") if File.file?(tempfile)
    return input
  end

  # This is copied into new Java answers. Used throughout class Task.  RF
  def java_starter
    return <<~JAVASTARTER
      public class answer_#{@id} {
          public static void main(String[] args) {
              /* do not edit 'answer_<id>' */
          }
      }
      JAVASTARTER
  end

end
