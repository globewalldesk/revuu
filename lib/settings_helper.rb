module SettingsHelper

  # Accepts a hash (e.g., {'lang' => 'C'}) & overwrites settings file. RF
  def update_settings_file(args)
    # Ensure a settings file exists.
    create_settings_file_if_necessary
    settings_hash = load_settings_into_hash
    # Merge new language info into hash.
    hash_to_write = settings_hash.merge(args)
    # Write new hash.
    File.write("./data/settings.json", hash_to_write.to_json)
  end

  # Checks if there is no data/settings.json file. Creates one and populates it
  # with some defaults, if not. RF
  def create_settings_file_if_necessary
    settings_file = "data/settings.json"
    if File.exist?(settings_file) && File.stat(settings_file).size > 0
      return
    else
      system("touch #{settings_file}")
      ur_settings = { 'lang' => 'Other',
                      'texted' => 'Pico',
                      'last_change' => DateTime.now.to_s,
                      'unsaved_changes' => true,
                      'last_archive' => DateTime.now.to_s }
      File.write(settings_file, ur_settings.to_json)
    end
  end

  # Loads JSON from settings.json into hash, or else returns {}. RF
  def load_settings_into_hash
    raw_settings = File.read("./data/settings.json")
    raw_settings = {} if raw_settings == ""
    settings_hash = ( raw_settings == {} ? {} : JSON.parse(raw_settings) )
  end

  # Load the default language and other settings from file. RF
  def load_defaults_from_settings
    # Revuu doesn't assume a settings file exists, in case of user error.
    create_settings_file_if_necessary
    # Load settings from data/settings.json.
    settings_hash = load_settings_into_hash
    # Next, check settings for completeness, and fix if incomplete.
    # Does a language setting exist?
    ensure_language_setting_exists(settings_hash)
    # Does a text editor setting exist and is it still OK?
    ensure_text_editor_setting_kosher(settings_hash)
    # Does settings contain a last updated, last archive, unsaved changes boolean?
    ensure_archive_settings_kosher(settings_hash)
  end

  # Checks that the settings file has a language setting; if not, forces user
  # to pick one. RF
  def ensure_language_setting_exists(settings_hash)
    # Check if 'lang' key exists; if not, create and save.
    if settings_hash['lang']
      # Given a programming language name, return a Lang object, stored in a global.
      $lang_defaults = Lang.new(settings_hash['lang'])
    else
      puts "LANGUAGE SETTING MISSING."
      message = choose_default_language # Saves the language if the user picks one.
      puts message, ''
    end
  end

  # Checks that the settings file has an available text editor setting; if not,
  # forces user to pick one. RF
  def ensure_text_editor_setting_kosher(settings_hash)
    if settings_hash['texted'] &&
     ensure_text_editor_still_available(settings_hash['texted']) # Self-truthing.
      $texted = settings_hash['texted']
      $textedcmd = text_editors[$texted]
    else # i.e., there is no 'texted' setting.
      puts "TEXT EDITOR SETTING MISSING."
      message = choose_text_editor(true) # i.e., a choice is required.
      puts message, ''
      update_settings_file({'lang': $lang_defaults.name})
    end
  end

  # Checks whether a given text editor is available; if not, forces user to
  # pick one. RF
  def ensure_text_editor_still_available(texted)
    # Check if text editor in settings is still available. If not, choose new.
    unless available_editors.include? texted
      puts "YOUR OLD TEXT EDITOR (#{texted.upcase}) IS NO LONGER INSTALLED."
      message = choose_text_editor(true) # i.e., a choice is required.
      puts message, ''
      return true
    else
      return true
    end
  end

  # Checks and assigns archive settings (from setting file); if they don't
  # exist, populates with some defaults. RF
  def ensure_archive_settings_kosher(settings_hash)
    settings_to_merge = {} # Probably won't be any, but just in case...
    if settings_hash['last_change']
      $last_change = settings_hash['last_change']
    else
      # Pretend the last change was now.
      $last_change = DateTime.now.to_s
      settings_to_merge.merge!({'last_change' => $last_change})
    end
    # defined? because the value is either 'true' or 'false', so testing the
    # value itself messes up the logic.
    if defined? settings_hash['unsaved_changes']
      $unsaved_changes = settings_hash['unsaved_changes']
    else
      # If there isn't an unsaved changes setting, prompt the user to save.
      $unsaved_changes = true
      settings_to_merge.merge!({'unsaved_changes' => $unsaved_changes})
    end
    if settings_hash['last_archive']
      $last_archive = settings_hash['last_archive']
    else
      # No idea when last archive was, so just set it to now.
      $last_archive = DateTime.now.to_s
      settings_to_merge.merge!({'last_archive' => $last_archive})
    end
    # If there was any missing data, write it to settings.
    update_settings_file(settings_to_merge) unless settings_to_merge.empty?
  end

  # Should be called whenever a task is created or changed. Generates a new 
  # "last [most recent] change" timestamp as well as a "last archive" which is
  # set to an arbitrary time before the task is marked as created. These are
  # used to calculate whether there are unsaved changes. Finally, saves these
  # three values to settings. RF
  def save_change_timestamp_to_settings
    $last_change = DateTime.now.to_s
    $last_archive = (DateTime.now - 1).to_s unless $last_archive
    $unsaved_changes = DateTime.parse($last_change) > DateTime.parse($last_archive)
    update_settings_file( { 'last_change'     => $last_change,
                            'last_archive'    => $last_archive,
                            'unsaved_changes' => $unsaved_changes } )
  end

  # Used both at startup and as a user option function, this both solicits and
  # sets a new text editor global, returning a message to the user. RF
  def choose_text_editor(choice_required = false)
    # Display text editors available on the user's system.
    display_list_of_editors_to_user
    editor_num = nil
    # Select new editor; two circumstances of doing so:
    # user is required to choose an editor if none is saved in settings...
    if choice_required
      until editor_num && editor_num.between?(0,available_editors.length-1)
        # Let user select new editor.
        puts "Please select which one you'll use to write answers."
        editor_num = get_user_command('e').to_i - 1
        puts "Choose a number between 1 and #{available_editors.length}." unless
          editor_num.between?(0,available_editors.length-1)
      end
    else # ...or user is simply switching editors.
      puts "Please select which one you'll use to write answers."
      editor_num = get_user_command('e').to_i - 1
      unless editor_num.between?(0,available_editors.length-1)
        return "Sticking with #{$texted}."
      end
    end
    # Reset text editor global ($texted).
    edname = available_editors[editor_num]
    $texted = edname
    $textedcmd = text_editors[edname]
    update_settings_file({'texted' => edname})
    return "OK, you'll use #{edname}."
  end

  # Both compiles a list of available editors and displays them to the user. RF
  def display_list_of_editors_to_user
    default_msg = " (default = *)" if $texted
    puts "Text editors on your system#{default_msg}:"
    width = 0
    # Actually do the displaying. Note, available_editors is a method.
    available_editors.each_with_index do |editor,i|
      default_asterisk = '*' if defined? $texted and $texted == editor
      item = "(#{i+1}) #{editor}#{default_asterisk} "
      # Decide whether to wrap (add newline).
      if item.length + width >= 75
        puts('')
        width = 0
      end
      # Always adds to line length and prints item.
      width += item.length
      print item
    end
    puts ''
  end

  # Compares Revuu's list of text editors with what is available on the user's
  # system; returns sorted array of the names of available text editors. RF
  def available_editors
    # Given list of text editors, return those available on this system.
    available = text_editors.select do |name,command|
      `which #{command}`.length > 0
    end
    available.keys.sort # Alpha order names and return as array.
  end

  # Could be a variable and/or constant, and could be stored in a JSON file,
  # but for consistency with 'available_editors', I made it a global method. RF
  def text_editors
    { 'Sublime Text'        => 'subl',
      'Atom'                => 'atom',
      'Nano'                => 'nano',
      'Pico'                => 'pico',
      'Visual Studio Code'  => 'code',
      'vi'                  => 'vi',
      'vim'                 => 'vim',
      'Eclipse'             => 'eclipse',
      'IntelliJ'            => 'idea',
      'Android Studio'      => 'studio',
      'Xcode'               => 'xcode',
      'Netbeans'            => 'netbeans',
      'PhpStorm'            => 'phpstorm',
      'PyCharm'             => 'pycharm',
      'Emacs'               => 'emacs',
      'gedit'               => 'gedit' }
  end

  # After getting a language from Lang::choose_default, saves to defaults.
  # Returns nil if language saved properly; returns language name otherwise. RF
  def choose_default_language
    puts "OK, let's choose a default language."
    default = $lang_defaults ? $lang_defaults.name : 'Other'
    new_default = Lang.solicit_languages_from_user('p', default)
    if (new_default && new_default != default && new_default != 'q')
      update_settings_file({'lang' => new_default})
      $lang_defaults = Lang.new(new_default)
      message = "Saved #{$lang_defaults.name} as the default language."
    else
      # This is necessary because sometimes the setting won't be saved.
      update_settings_file({'lang' => default})
      $lang_defaults = Lang.new(default)
      message = "Sticking with #{default}."
    end
    return message
  end

end
