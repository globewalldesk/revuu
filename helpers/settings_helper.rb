module SettingsHelper

  # Accepts a hash (e.g., {'lang' => 'C'}) & overwrites settings file with it.
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
  # with some defaults, if not.
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

  # Loads JSON from settings.json into hash, or else returns {}.
  def load_settings_into_hash
    raw_settings = File.read("./data/settings.json")
    raw_settings = {} if raw_settings == ""
    settings_hash = ( raw_settings == {} ? {} : JSON.parse(raw_settings) )
  end

  # Load the default language, text editor ($lang, $texted), & archive settings.
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

  def ensure_language_setting_exists(settings_hash)
    # Check if 'lang' key exists; if not, create and save.
    if settings_hash['lang']
      # Given a programming language name, return a Lang object, stored in a global.
      $lang_defaults = Lang.new(settings_hash['lang'])
    else
      puts "LANGUAGE SETTING MISSING."
      lang = choose_default_language # Saves the language if the user picks one.
      # If choose_default_language returned a language, it needs to be saved.
      if lang
        $lang_defaults = Lang.new(lang)
        update_settings_file({'lang': $lang_defaults.name})
      end
    end
  end

  def ensure_text_editor_setting_kosher(settings_hash)
    if settings_hash['texted'] &&
     ensure_text_editor_still_available(settings_hash['texted']) # Self-truthing.
      $texted = settings_hash['texted']
      $textedcmd = text_editors[$texted]
    else # i.e., there is no 'texted' setting.
      puts "TEXT EDITOR SETTING MISSING."
      choose_text_editor(true) # i.e., a choice is required.
      update_settings_file({'lang': $lang_defaults.name})
    end
  end

  def ensure_text_editor_still_available(texted)
    # Check if text editor in settings is still available. If not, choose new.
    unless available_editors.include? texted
      puts "YOUR OLD TEXT EDITOR (#{texted.upcase}) IS NO LONGER INSTALLED."
      choose_text_editor(true) # i.e., a choice is required.
      return true
    else
      return true
    end
  end

  def ensure_archive_settings_kosher(settings_hash)
    settings_to_merge = {} # Probably won't be any, but just in case...
    if settings_hash['last_change']
      $last_change = settings_hash['last_change']
    else
      # Pretend the last change was now.
      $last_change = DateTime.now.to_s
      settings_to_merge.merge!({'last_change' => $last_change})
    end
    if settings_hash['unsaved_changes'] != nil
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

  def save_change_timestamp_to_settings
    $last_change = DateTime.now.to_s
    $last_archive = (DateTime.now - 1).to_s unless $last_archive
    $unsaved_changes = DateTime.parse($last_change) > DateTime.parse($last_archive)
    update_settings_file( { 'last_change'     => $last_change,
                            'unsaved_changes' => $unsaved_changes } )
  end

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

  def choose_text_editor(choice_required = false)
    # Display text editors available on the user's system.
    available_editors = display_list_of_editors_to_user
    editor_num = nil
    # Select new editor; two circumstances of doing so:
    # user is required to choose an editor if none is saved in settings...
    if choice_required
      until editor_num && editor_num.between?(0,available_editors.length)
        # Let user select new editor.
        puts "Please select which one you'll use to write answers."
        editor_num = get_user_command('e').to_i - 1
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
    print "OK, you'll use #{edname}.\n\n"
    $texted = text_editors[edname]
    $textedcmd = text_editors[edname]
    update_settings_file({'texted' => edname})
    # Double-check that editor is still available.
  end

  # Both compiles a list of available editors and displays them to the user.
  # Returns a list of available editors as well.
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

  # Compares Revuu's list of text editors with what is available on the user's
  # system; returns sorted array of the names of available text editors.
  def available_editors
    # Given list of text editors, return those available on this system.
    eds = text_editors.select do |nm,cmd|
      `which #{cmd}`.length > 0
    end
    eds.keys.sort # Alpha order names and return as array.
  end

  # After getting a language from Lang::choose_default, saves to defaults.
  # Returns nil if language saved properly; returns language name otherwise.
  def choose_default_language
    puts "OK, let's choose a default language."
    default = $lang_defaults ? $lang_defaults.name : 'Other'
    new_default = Lang.solicit_languages_from_user('p', default)
    if (new_default && new_default != default)
      update_settings_file({'lang' => new_default})
      $lang_defaults = Lang.new(new_defadisplay_list_of_editors_to_userult)
      print "Saved #{$lang_defaults.name} as the default language.\n\n"
      return nil #
    else
      print "Sticking with #{default}.\n\n"
      return default
    end
  end

end
