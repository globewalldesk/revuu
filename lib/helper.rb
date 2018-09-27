module Helper
  $help =
    "\nCommands are:\n" +
    "  [n]ew task   [1] review/edit task #1   [l]ist all tasks   [d]elete task\n" +
    "  sort list by [t]ag   [c]ommands   [i]ntroduction"

  $introduction = <<ENDINTRO
Welcome to Revuu!

This app will help you review complex tasks. It was written with the notion
that programmers (and others) need repetition of not declarative but procedural
knowledge.

So when you perform a review, you don't try to answer a question in words.
Instead, you try to perform a task. Essentially, to use Revuu, you'd add
complex, not simple, tasks. Probably the ideal Revuu task would require
2-10 minutes to complete.

To record the fact that you've reviewed a task on a certain date, and given
yourself a certain score, enter the task ID number and then press 's'.

If you use Revuu to study programming, you can use the 'answer' feature for
supported languages. (Non-programmers should choose the "Other" option for the
language). This will enable you to use your code editor of choice to input an
answer (with the answer easily accessible right from the task display view) and
to run it with supported interpreters and compilers (also right from the task
display view).

Currently, we support Ruby, Node.js (JavaScript), Java, C, and Bash scripting.
The only supported text editor for now is Sublime Text but more will be added
soon.

Add copious, well-chosen tags in order to be able to sort tasks.

Revuu ships with a bunch of pre-made questions by way of demonstration. You
can delete these and make your own, if you like.

Revuu has other features you'd expect such as editing of various fields.
ENDINTRO

  def get_user_command(leader)
    print "#{leader}> "
    gets.chomp
  end

  def header
    puts sprintf("%-69s%s", " * R * E * V * U * U *",  "v. 1.0").
      colorize(:color => :black, :background => :white)
    puts "\n"
  end

  def get_locations(id)
    # Determine filename for answer for this task.
    $file = "answer_#{id}.#{$ext}"
    $location = "./answers/#{$file}"
    # Determine filename for old answers for this task. (Helper.)
    $old_file = "answer_old_#{id}.#{$ext}"
    $old_location = "./answers/#{$old_file}"
  end

  def solicit_languages_from_user
    # Show user language.
    puts "Default language is #{$lang}."
    # Load language data and make hashes for $ext and $cmnt (here only).
    language_data = get_available_langs
    # Check which languages are available on the system.
    available_langs = language_data.reject do |l|
      ! `which #{l[:cmd]}`
    end
    # If, amazingly, there's only one language, say so and exit.
    if available_langs.length == 1
      puts "There's only one language available and you're using it."
      return nil, nil
    end
    # Show available languages to user.
    print "Available languages:\n  "
    available_langs.each_with_index {|l,i| print "(#{i+1}) #{l[:name]} "}
    puts "\n"
    # Solicit new language.
    puts "Enter the number of a language to switch to or <Enter> for current."
    new_lang = get_user_command('c')
    (return nil, nil) if new_lang == ''
    new_lang = new_lang.to_i - 1 # -1 to compensate for +1 above.
    # Abandon if number not listed.
    if ! available_langs[new_lang]
      puts available_langs == 2 ?
        "Choose (1) or (2)." :
        "Input a number from (1) to (#{available_langs.length})."
      return nil, nil
    end
    # new_lang = the lang's index in the array of available langs.
    return new_lang, available_langs
  end

  # Language data hash.
  def get_available_langs
    [
      {name: 'Ruby', ext: 'rb', cmd: 'ruby', cmnt: '#'},
      {name: 'Node.js', ext: 'js', cmd: 'node', cmnt: '//'},
      {name: 'Java', ext: 'java', cmd: 'javac', cmd2: 'java <name-no-ext>',
        cmnt: '//', one_main_per_file: true},
      {name: 'C', ext: 'c', cmd: 'gcc', cmd2: './a.out', cmnt: '/*',
        cmnt2: '*/', one_main_per_file: true},
      {name: 'Bash', ext: 'sh', cmd: '/bin/bash', cmnt: '#'},
      {name: 'Other', ext: 'txt', cmd: 'more', cmnt: '#'}
    ]
  end

  # Given a language data hash, assign language globals.
  def assign_language_globals(l)
    # User changes these with configure_language.
    $lang  = l[:name] # Programming language. Get from/set to settings.json.
    $ext   = l[:ext]                # Filename extension.
    $cmd   = l[:cmd]                # Command to execute (or compile).
    $cmnt  = l[:cmnt]               # Comment char in language.
    $cmd2  = l[:cmd2]  ? l[:cmd2]  : false  # Run after compiling in, e.g., C.
    $cmnt2 = l[:cmnt2] ? l[:cmnt2] : false  # Comment-ender in, e.g., C.
    $one_main_per_file = l[:one_main_per_file] ? l[:one_main_per_file] : false
  end

  def archive_old_answer(task)
    old_archive = File.exist?($old_location) ? File.read($old_location) : ''
    # Load current answer file contents.
    contents = File.read($location)
    # If C, Java, etc., then completely overwrite old answer file
    if $one_main_per_file
      new_archive = contents
      # If Java, the main class needs to be renamed to be runnable.
      if task.lang == 'Java'
        new_archive.gsub!('public class answer', 'public class answer_old')
      end
    # Else the usual case: append newer answer to top of old_archive.
    else
      # Separate different archived answers with a line of comments.
      # Use $cmnt2 for /* ... */ style comments.
      comment_separator = ($cmnt2 ? (($cmnt*37) + $cmnt2) : ($cmnt*37) )
      # Concatenate current contents with archive file contents.
      new_archive =
        contents + ("\n\n\n" + comment_separator + "\n\n\n") + old_archive
    end
    # Write concatenated contents to the location of the archive.
    File.write($old_location, new_archive)
    # Finally, overwrite the current answer file with '' or Java template.
    create_answer_file(task)
  end

  def create_answer_file(task)
    if ! File.exist?($location)
      system("touch #{$location}")
    end
    if task.lang == 'Java'
      # So far, only Java files need to be written-to before getting started.
      File.write($location, java_starter(task))
    else
      File.write($location, '')
    end
  end

  def java_starter(task)
    return <<JAVASTARTER
public class answer_#{task.id} {
    public static void main(String[] args) {

    }
}
JAVASTARTER
  end

  def ensure_there_is_a_default_settings_file
    `touch ./data/settings.json` unless File.exists? ("./data/settings.json")
  end

  def update_language_default(new_lang_name)
    ensure_there_is_a_default_settings_file
    # Load existing settings into hash.
    raw_settings = File.read("./data/settings.json")
    raw_settings = {} if raw_settings == ""
    settings_hash = ( raw_settings == {} ? {} : JSON.parse(raw_settings) )
    # Merge new language info into hash.
    hash_to_write = settings_hash.merge({'lang' => new_lang_name})
    # Write new hash.
    File.write("./data/settings.json", hash_to_write.to_json)
  end

  def load_language_defaults_from_settings
    # Determine default language.
    raw_settings = File.read("./data/settings.json")
    settings = JSON.parse(raw_settings)
    lang = lookup_lang_data_from_name(settings['lang'])
    # Assign associated language globals (such as $lang and $ext).
    assign_language_globals(lang)
  end

  # Given a language name (as in Task#lang or as stored in settings.json)
  # return a language data hash.
  def lookup_lang_data_from_name(lang_name)
    langs = get_available_langs
    langs.find {|l| l[:name] == lang_name }
  end


end
