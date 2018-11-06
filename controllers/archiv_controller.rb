module ArchivController
    # Wrapper look for Archive-related commands.
    def archive_loop
      command = nil
      until command == 'q'
        command = get_user_command('a')
        dispatch_table(command)
      end
    end

    def dispatch_table(command)
      case command
      when 'c'
        archive = Archiv.new    # Since no argument, a name is created for 'archive'.
        archive.create_archive  # Uses the new name.
      when 'l'
        choose_archive_and_load
      when 's'
        display_archives; puts '';
      when 'd'
        delete_archive
      when 'f'
        welcome_to_archive
      when 'sa'
        copy_sample_data
      when 'h', '?'
        launch_instructions_system
        welcome_to_archive
      when 'q'
        return
      else
        puts 'Huh?'
      end
    end

    def choose_archive_and_load
      # User must choose one of the existing archives to load.
      archive_name = choose_archive
      # Backup existing data, if it exists; then delete; then unpack named archive;
      # then copy unpacked directories and files into data/.
      if archive_name
        archive = Archiv.new(archive: archive_name) # With argument, a name is saved.
        msg = archive.load_archive
        puts "Nothing new loaded; escaping." if msg == nil
      else
        puts "Escaping; didn't load anything.\n\n"
      end
    end

    def load_archive
      unless $tasks.list.empty?
        puts "\nDo you want to save an archive of the currently-loaded data first?"
        puts "\nNOTE! Be sure before proceeding. Don't overwrite new data with old!"
        puts "NOTE!! The currently-loaded data does have unsaved changes." if $unsaved_changes
        puts ''
        save_first = nil
        until save_first && (save_first == '' || 'ynq'.include?(save_first) )
          puts "Press <Enter> for [y], [n], or [q]uit (escape)."
          save_first = get_user_command("l")
        end
        return nil if save_first == 'q'
        if save_first == '' || save_first == 'y'
          Archiv.new(archive: affix_date_and_ext('')).create_archive # Does as it tells the user...
        end
      end
      system('rm -rf data/')
      # Actually copy from zip file to data folder, reconstructing the data folder!
      Minitar.unpack(self.archive, "./")
      # Reload the goods, just as App.new does. But REFACTORING PROBLEM: do I really
      # want to be calling #new here?
      puts "Done! Quit the archive system to see the newly-loaded archive."
      return true # indicating to #choose_archive_and_load that loading went fine.
    end

    def delete_archive
      # Show archives and solicit number.
      puts "OK, ready to delete. Choose wisely!"
      archive_name = choose_archive
      puts "Escaping without deleting." unless archive_name
      begin
        # Delete that archive.
        system("rm #{archive_name}")
      rescue "Couldn't delete, for some reason."
      ensure
        display_archives
        puts ''
      end
    end

    def copy_sample_data
      puts "\nThis simple function just makes a sample data set available in your"
      puts "list of archives. It's already done: "
      system('cp sample_data/* archives/')
      display_archives
      puts "You can now [l]oad this data and check it out.\n\n"
    end

end
