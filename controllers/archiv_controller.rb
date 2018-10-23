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
      when 's'
        display_archives; puts '';
      when 'c'
        archive = Archiv.new    # Since no argument, a name is created for 'archive'.
        archive.create_archive  # Uses the new name.
      when 'l'
        choose_archive_and_load
      when 'f'
        welcome_to_archive
      when 'h'
        launch_instructions_system
        welcome_to_archive
      when 'q'
        $tasks.display_tasks
        return
      end
    end

    def choose_archive_and_load
      # User must choose one of the existing archives to load.
      archive_name = choose_archive
      # Backup existing data, if it exists; then delete; then unpack named archive;
      # then copy unpacked directories and files into data/.
      if archive_name
        archive = Archiv.new(archive: archive_name) # With argument, a name is saved.
        archive.load_archive
      end
    end

    def load_archive
      puts "OK, I'm loading #{self.archive}!"
    end
end