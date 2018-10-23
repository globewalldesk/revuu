module ArchivView
  # Intro user to archive screen; clears screen and shows introductory text.
  def welcome_to_archive
    clear_screen
    title = "REVUU ARCHIVE SYSTEM"
    puts '*-' * (title.length / 2).round
    puts title
    puts '*-' * (title.length / 2).round
    puts <<~ARCHIVEHEADER
      Here, you can archive (i.e., export) and load (i.e., import) your data. 
      Use these tools to cache or reload a task set, to back up your data so 
      it won't be lost, or to share a task set with others.

    ARCHIVEHEADER
    puts archive_help
  end

  # List of dispatch_table commands for user.
  def archive_help
    <<~ARCHIVEHELP
    Archives: [c]reate/export  [l]oad/import  [s]how all  
    Also:     re[f]resh view  [h]elp  [q]uit archive system

    ARCHIVEHELP
  end

  # Pesters user for a valid archive name; returns it.
  def set_archive_name
    puts <<~SETARCHIVENAME 
    Press <Enter> for a generic archive name or enter a brief label;
    this could be your last name, a company or project name, or the
    name of some technology you're learning.

    SETARCHIVENAME
    archive_name = nil
    until is_valid?(archive_name)
      archive_name = get_user_command('a')
    end
    affix_date_and_ext(archive_name)
  end

  # Pesters user for name (number) of archive; returns name.
  def choose_archive
    # Display archives and also output an array of archive locations.
    archives = display_archives
    load_num = nil
    until [*(1..archives.length)].include? (load_num)
      puts "\nWhich of the archives above?"
      load_num = get_user_command('c').to_i
    end
    archives[load_num-1]
  end

  # Loads list of archive names, then displays them in numbered fashion.
  def display_archives
    puts "\nYour archives:"
    archives = Dir["archives/*.tar"].sort
    # Construct string
    line = ''
    archives.each_with_index do |a,i|
      addition = "(#{i+1}) #{a} ".gsub!('archives/', '')
      if (line + addition).length > 74
        puts line
        line = addition
      else
        line += addition
      end
      puts line if a == archives[-1]
    end
    archives
  end

end