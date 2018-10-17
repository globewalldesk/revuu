# The purpose of the Lang class is primarily to generate (and hold) data about
# a language, given a particular programming language name such as 'Java' or
# 'JavaScript'. Hence, all that is needed to initialize a Lang object is such a
# language name. The class does double duty by exposing language-related class
# methods that could, perhaps, live in a separate helper module.
class Lang

  class << self
    # Returns *only* a canonical language name; doesn't create an object.
    # This is just a wrapper for the rather complex ::solicit_languages_from_user.
    # Might not be necessary. Always returns the name of a language.
    def pick_language_name(current)
      puts "\nSET LANGUAGE:"
      solicit_languages_from_user(current)
    end

    # Extracts from user answers that result in the name of the task's language.
    # Requires a string identifying the current language.
    def solicit_languages_from_user(current=$lang_defaults.name)
      default = $lang_defaults.name
      # Show user language.
      if default != current
        puts "Default language is #{default}; the current language is #{current}."
      else
        puts "Default language is #{default}."
      end
      # Check which languages are available on the system.
      available_langs = @@defined_langs.reject do |l|
        ! `which #{l[:cmd]}`
      end
      # If, amazingly, there's only one language, say so and exit.
      if available_langs.length == 1
        puts "There's only one language available and you're using it."
        return default
      end
      # Show available languages to user.
      print "Available languages:\n  "
      available_langs.each_with_index {|l,i| print "(#{i+1}) #{l[:name]} "}
      puts "\n"
      # Solicit new language.
      puts "Enter the number of a language to switch to or <Enter> for current."
      langnum = get_user_command('c')
      (return current) if langnum == ''
      langnum = langnum.to_i - 1 # -1 to compensate for +1 above.
      # Use default if number not listed.
      if ! available_langs[langnum]
        puts "That response isn't recognized."
        return current
      end
      return available_langs[langnum][:name]
    end

    # Accessor for @@defined_langs; for use by Task::validate_tags.
    def defined_langs
      @@defined_langs
    end

  end # of class methods

  # Language data hashes--now a new and improved class variable!
  @@defined_langs =
    [
      {name: 'Ruby', ext: 'rb', cmd: 'ruby', cmnt: '#', alts: [], spacer:
        "puts ''" },

      {name: 'JavaScript', ext: 'js', cmd: 'node', cmnt: '//', alts:
        ['JS', 'Node', 'Node.js'], spacer: "console.log(' ')"},

      {name: 'Java', ext: 'java', cmd: 'javac', cmd2: 'java <name-no-ext>',
        cmnt: '//', one_main_per_file: true, alts: []},

      {name: 'Python', ext: 'py', cmd: 'python', cmnt: '#', alts: [], spacer:
        'print("\n")'},

      {name: 'C', ext: 'c', cmd: 'gcc', cmd2: './a.out', cmnt: '/*',
        cmnt2: '*/', one_main_per_file: true, alts: ['C language',
        'C programming language']},

      {name: 'Bash', ext: 'sh', cmd: '/bin/bash', cmnt: '#', alts:
        ['command line', 'shell', 'shell scripting', 'Bash scripting', 'Linux',
          'Unix'], spacer: "echo '<--spacer-->'"},

      {name: 'Other', ext: 'txt', cmd: 'more', cmnt: '#', alts: [], spacer:
        "\n<--spacer-->\n"}
    ]

  # Lang objects expose language data as in a hash.
  attr_accessor :name, :ext, :cmd, :cmnt, :cmd2, :cmnt2, :one_main_per_file,
    :alts, :spacer

  def initialize(lang_name)
    l = fetch_lang_hash_from_name_cmd(lang_name)
    # User changes these starting with change_language.
    @name  = l[:name] # Programming language. Get from/set to settings.json.
    @ext   = l[:ext]                # Filename extension.
    @cmd   = l[:cmd]                # Command to execute (or compile).
    @cmnt  = l[:cmnt]               # Comment char in language.
    @cmd2  = l[:cmd2]  ? l[:cmd2]  : false  # Run after compiling in, e.g., C.
    @cmnt2 = l[:cmnt2] ? l[:cmnt2] : false  # Comment-ender in, e.g., C.
    @one_main_per_file = l[:one_main_per_file] ? l[:one_main_per_file] : false
    @lang_alts = l[:alts]
    @spacer = l[:spacer] ? l[:spacer] : ''  # String to append to archived file.
    return self
  end

  # Given a language name, return a language data hash.
  def fetch_lang_hash_from_name_cmd(lang_name) # Should be just 'lang' or 'lang_name'.
    @@defined_langs.find {|l| l[:name] == lang_name }
  end

end
