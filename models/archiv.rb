# Both logic and UI for creating, loading, and deleting archives of user data.
class Archiv

  class << self
    def launch_archive_system
      # Show welcome screen.
      welcome_to_archive
      # Launch archive loop (in controller).
      archive_loop
    end

  end

  attr_accessor :archive

  def initialize(args={})
    # Create a tar archive of the contents of data/.
    @archive = args[:archive] || set_archive_name # in ArchivView
  end

  # Makes a tarball of data/ and saves it in archives/. Returns a string
  # containing the name of the archive.
  def create_archive
    begin
      Dir.mkdir("archives") unless Dir.exists?("archives")
      Minitar.pack("./data", File.open("archives/#{@archive}", 'wb'))
      puts "Created #{@archive}."
      save_archive_timestamp_to_settings
    rescue StandardError => e
      puts "Oops, error: #{e}"
      puts "Archive not created."
      nil
    end
  end

  def save_archive_timestamp_to_settings
    $last_archive = DateTime.now.to_s
    $unsaved_changes = false
    update_settings_file({'last_archive' => $last_archive, 'unsaved_changes' => false})
  end

  private

    # Validates a user-submitted string as a suitable archive name; returns
    # boolean.
    def is_valid?(nm)
      return false if nm.nil?
      return true if nm == ''
      # Name must be a word character 1-20 in length.
      unless nm =~ /\W/
        # Don't let user put extension in name.
        if /(\.zip|\.gz|\.tar)/.match(nm)
          puts "Please don't include the file extension; just use a simple label."
          return false
        elsif nm[-1] == '_'
          puts "Please don't put _ at the end of your string."
          return false
        else
          return true
        end
      else
        puts "Please use only letters, numbers, and _, not over 20 characters."
        return false
      end
    end

    # Require pre-validated name string or ''; constructs and returns filename.
    def affix_date_and_ext(nm)
      date = DateTime.now.strftime("%Y%m%d")
      label = nm == '' ? 'archive' : nm + '_archive'
      return "#{label}_#{date}.tar".downcase
    end



end