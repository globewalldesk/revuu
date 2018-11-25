# The purpose of the Lang class is primarily to generate (and hold) data about
# a language, given a particular programming language name such as 'Java' or
# 'JavaScript'. Hence, all that is needed to initialize a Lang object is such a
# language name. The class does double duty by exposing language-related class
# methods that could, perhaps, live in a separate helper module.
class Lang

  class << self
    # Extracts from user answers that result in the name of the task's language.
    # Requires a string identifying the current language.
    def solicit_languages_from_user(prompt, current)
      default = $lang_defaults ? $lang_defaults.name : 'Other'
      # Show user language.
      if default != current
        puts "Default language is #{default}; the current language is #{current}."
      else
        puts "Default language is #{default}."
      end
      # Check which languages are available on the system.
      available_langs = @@defined_langs.reject do |l|
        `which #{l[:cmd]}` == ''
      end
      # If, amazingly, there's only one language, say so and exit.
      if available_langs.length == 1
        puts "There's only one language available and you're using it."
        return default
      end
      # Show available languages to user and solicit a number.
      puts "Here are the languages we support that are on your system."
      puts "Enter the number of a language; <Enter> for current; or [q]uit:"
      choice = wrap_items_with_numbers(available_langs.map{|l| l[:name]},
                                       {colored: true, enter_OK: true})
      puts ''
      return 'q' if choice == 'q'
      return current if (choice == '' || choice == current)
      return choice
    end

    # Read accessor for @@defined_langs; for use by Task::prep_tags.
    def defined_langs
      @@defined_langs
    end

    # An array of all the language names, plus the alternative names.
    # Used in the task_factory's tag massager method.
    def all_lang_names_and_alts(lang)
      all_names = []
      l = @@defined_langs.find {|l| lang == l[:name]}
      all_names << l[:name]
      all_names.concat(l[:alts]) unless l[:alts].empty?
      all_names
    end

  end # of class methods

  # Language data hashes--now a new and improved class variable!
  @@defined_langs =
    [
      {name: 'Ruby', ext: 'rb', cmd: 'ruby', cmnt: '#', alts: [], spacer:
        "puts ''", color: :free_speech_red },

      {name: 'JavaScript', ext: 'js', cmd: 'node', cmnt: '//', alts:
        ['JS', 'Node', 'Node.js'], spacer: "console.log(' ')", color:
        :festival},

      {name: 'HTML', ext: 'html', cmd: 'firefox', cmnt: '<!--', cmnt2: '-->',
        alts: ['HTML5'], spacer: "<p>&nbsp;</p>", one_main_per_file: true,
        color: :tahiti_gold},

      {name: 'CSS', ext: 'css', cmd: 'firefox', cmnt: '/*', cmnt2: '*/',
        alts: ['CSS3'], spacer: '', color: :denim},

      {name: 'Bash', ext: 'sh', cmd: '/bin/bash', cmnt: '#', alts:
        ['command line', 'shell', 'shell scripting', 'Bash scripting', 'Linux',
          'Unix'], spacer: "echo '<--spacer-->'", color: :chateau_green},

      {name: 'SQL', ext: 'rb', cmd: 'ruby', cmd2: 'psql tysql postgres',
        cmnt: '#', alts: ['postgresql', 'psql'], spacer: "puts ''", color: :malibu},

      {name: 'C', ext: 'c', cmd: 'gcc', cmd2: './a.out', cmnt: '/*',
        cmnt2: '*/', one_main_per_file: true, alts: ['C language',
        'C programming language'], color: :echo_blue},

      {name: 'C++', ext: 'cpp', cmd: 'g++', cmd2: './a.out', alts: ['C plus plus'],
        cmnt: '//', spacer: 'cout<<"\n";', color: :med_aquamarine},

      {name: 'Java', ext: 'java', cmd: 'javac', cmd2: 'java <name-no-ext>',
        cmnt: '//', one_main_per_file: true, alts: [], color: :carrot_orange},

      {name: 'Python', ext: 'py', cmd: 'python', cmnt: '#', alts: [], spacer:
        'print("\n")', color: :saffron},

      {name: 'Rust', ext: 'rs', cmd: 'rustc', cmd2: './<name-no-ext>', cmnt: '//',
        alts: ['Rust programming language'], one_main_per_file: true, color: :brown,
        spacer: 'println!("\n")'},

      {name: 'Other', ext: 'txt', cmd: 'more', cmnt: '#', alts: [], spacer:
        "\n<--spacer-->\n", color: :light_magenta}
    ]

  # Lang objects expose language data as in a hash.
  attr_accessor :name, :ext, :cmd, :cmnt, :cmd2, :cmnt2, :one_main_per_file,
    :alts, :lang_alts, :spacer, :color

  def initialize(lang_name)
    l = fetch_lang_hash_from_name_cmd(lang_name)
    # User changes these with Task#change_language.
    @name  = l[:name] # Programming language. Get from/set to settings.json.
    @ext   = l[:ext]                # Filename extension.
    @cmd   = l[:cmd]                # Command to execute (or compile).
    @cmnt  = l[:cmnt]               # Comment char in language.
    @cmd2  = l[:cmd2]  ? l[:cmd2]  : false  # Run after compiling in, e.g., C.
    @cmnt2 = l[:cmnt2] ? l[:cmnt2] : false  # Comment-ender in, e.g., C.
    @one_main_per_file = l[:one_main_per_file] ? l[:one_main_per_file] : false
    @lang_alts = l[:alts]
    @spacer = l[:spacer] ? l[:spacer] : ''  # String to append to archived file.
    @color = l[:color]
    return self
  end

  # Given a language name, return a language data hash.
  def fetch_lang_hash_from_name_cmd(lang_name) # Should be just 'lang' or 'lang_name'.
    @@defined_langs.find {|l| l[:name] == lang_name }
  end

end
