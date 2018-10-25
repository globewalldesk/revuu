module Helpers

  # NOTE: move some methods to settings_helper.rb and some to help_helper.rg

  def clear_screen
    system("clear")
    header
  end

  def header
    puts sprintf("%-69s%s", " * R * E * V * U * U *",  "v. 2.2").
      colorize(:color => :black, :background => :white)
    puts "\n"
  end

  def get_user_command(leader)
    extra_space = ( ("=+a".include? (leader)) ? "" : "  ")
    print "#{extra_space}#{leader}> "
    gets.chomp
  end

  # Given a string representing the contents of a longish file, output a
  # similar string with newlines redistributed so that the likely paragraphs
  # are wrapped before n (=75) characters while the code bits are not wrapped.
  # Spacer is used when the first line will have, e.g., '(JavaScript) '.
  def wrap_overlong_paragraphs(para_string, spacer=0)
    # First, for instruction fields that feature e.g. '(Ruby)', insert a
    # placeholder into the text (temporarily) so wrapping looks good when
    # displayed with those prepended strings.
    spacer += 3 if spacer > 0 # for '(', ')', and ' '
    para_string = ('x' * spacer) + para_string
    # Next, divide para (which is one long string with potentially many \n
    # in it) into an array of *likely* paragraphs.
    # Identify potential paragraphs (=two or more newlines).
    paras = para_string.split(/\n\n/)
    # Width at wrapping can be univerally set from here.
    width = 75
    # Iterate array and output hash with "is it an actual para' data.
    para_hashes = test_if_actual_paras(paras, width)
    # Then, wrap the likely paragraphs (those marked 'true').
    paras = para_hashes.map do |para|
      if para[:is_wrappable] # Wrap if it's a wrappable paragraph.
        wrap(para[:text], width)
      else # Otherwise, return the unwrapped paragraph.
        para[:text]
      end
    end
    paras.join("\n\n")[spacer..-1]
  end

  # Output an array of hashes with data about whether a para is really a para.
  def test_if_actual_paras(paras, width) # 'paras' is an array of strings (=paras).
    para_hashes = []
    paras.each do |para|
      is_wrappable = false
      # For each para, split on newlines.
      para_lines = para.split("\n") # This is another array of strings (lines).
      para_lines = [para_lines] unless para_lines.class == Array
      # If there is only one line in para, mark as a paragraph.
      if para_lines.length == 1
        is_wrappable = true
      # If 2 or more lines are under 50 in length, don't wrap.
      elsif ( para_lines.count {|line| line.length < 50} >= 2 )
        is_wrappable = false
      # Otherwise, if there's a line over 75, wrap.
      elsif (para_lines.any? {|line| line.length >= width})
        is_wrappable = true
      end
      # NOTE FOR LATER: doesn't handle edge cases where the author has a
      # paragraph that includes indented lines, using the indented lines as
      # paragraph separators. Those sorts of paragraphs will not be wrapped.
      para_hashes << {is_wrappable: is_wrappable, text: para} # para = string w/ \n
    end
    para_hashes
  end

  # Simply accepts a string paragraph with \n; wraps it at n characters wide.
  def wrap(text, width)
    # Strip newlines.
    text.gsub!("\n", " ") # 'text' is still a string paragraph, just lacks \n.
    # Add them in just before n words.
    newlines = []
    line = ''
    word_array = text.split(/\s+/)
    word_array.each do |word|
      # See if this word can be added to a line.
      if (line + " " + word).length >= width
        newlines << line + " "
        line = word + " "
      else
        line += word + " "
        newlines << line if word == word_array.last
      end
    end
    newlines.join("\n")
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
      ur_settings = { 'lang' => 'Ruby', 
                      'texted' => 'Pico', 
                      'last_change' => DateTime.now.to_s,
                      'unsaved_changes' => true }
      File.write(settings_file, ur_settings.to_json)
    end
  end

  # Loads JSON from settings.json into hash, or else returns {}.
  def load_settings_into_hash
    raw_settings = File.read("./data/settings.json")
    raw_settings = {} if raw_settings == ""
    settings_hash = ( raw_settings == {} ? {} : JSON.parse(raw_settings) )
  end

  def save_change_timestamp_to_settings
    $last_change = DateTime.now.to_s
    $last_archive = (DateTime.now - 1).to_s unless $last_archive
    $unsaved_changes = DateTime.parse($last_change) > DateTime.parse($last_archive)
    update_settings_file( { 'last_change'     => $last_change, 
                            'unsaved_changes' => $unsaved_changes } )
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
