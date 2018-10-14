module Helpers

  # NOTE: move some methods to settings_helper.rb and some to help_helper.rg

  def clear_screen
    system("clear")
    header
  end

  def header
    puts sprintf("%-69s%s", " * R * E * V * U * U *",  "v. 2.0").
      colorize(:color => :black, :background => :white)
    puts "\n"
  end

  def get_user_command(leader)
    extra_space = ( ("=+".include? (leader)) ? "" : "  ")
    print "#{extra_space}#{leader}> "
    gets.chomp
  end

  # Accepts a hash (e.g., {'lang' => 'C'}) & overwrites settings file with it.
  def update_settings_file(args)
    ensure_there_is_a_default_settings_file
    settings_hash = load_settings_into_hash
    # Merge new language info into hash.
    hash_to_write = settings_hash.merge(args)
    # Write new hash.
    File.write("./data/settings.json", hash_to_write.to_json)
  end

  def ensure_there_is_a_default_settings_file
    `touch ./data/settings.json` unless File.exists? ("./data/settings.json")
  end

  # Checks if there is no data/settings.json file. Creates one and populates it
  # with some defaults.
  def initialize_settings_if_necessary
    settings_file = "./data/settings.json"
    if File.exist?(settings_file) && File.stat(settings_file).size > 0
      return
    else
      system("touch #{settings_file}")
      ur_settings = {'lang' => 'Ruby', 'texted' => 'Pico'}
      File.write(settings_file, ur_settings.to_json)
    end
  end

  # Loads JSON from settings.json into hash, or else returns {}.
  def load_settings_into_hash
    raw_settings = File.read("./data/settings.json")
    raw_settings = {} if raw_settings == ""
    settings_hash = ( raw_settings == {} ? {} : JSON.parse(raw_settings) )
  end

  $text_editors = {
    'Sublime Text'        => 'subl',
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
    'gedit'               => 'gedit'
  }

end 