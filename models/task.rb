###############################################################################
# The Task class enables the user to input new tasks and do basic task manipulation.
class Task
  extend TaskFactory # This prepares the data needed to start a new task.
  include TaskView
  include TaskController

                  # Edited by Tasklist#change_all_review_dates
  attr_accessor   :next_review_date

              # Attributes saved in tasks.json:
  attr_reader :id, :lang, :instructions, :tags, :score, :saved, :date_started,
              :all_reviews,
              # Attributes inferred from this saved data:
              :langhash, :file, :location, :old_file, :old_location, :starter,
              :starter_location, :location_dir, :old_location_dir,
              :starter_location_dir
  # The long Task attribute set is a function of how complex Tasks are.

  # Initialization is a three-step process and differs depending on whether an
  # existing task is being loaded from datafile or a new task is being created:
  # (1) Populate attributes by user input on startup; defaults; or datafile.
  # (2) Load or calculate ID and populate ID-dependent attributes.
  # (3) For new tasks, save data as needed.                           RF
  def initialize(args = {})
    # Step (1).
    args = defaults.merge(args)
    @lang = args[:lang]
    @instructions = args[:instructions]
    @tags = args[:tags]
    @score = args[:score]
    @saved = args[:saved]
    @date_started = args[:date_started]
    @next_review_date = args[:next_review_date]
    @all_reviews = args[:all_reviews]
    @langhash = Lang.new(@lang)
    # Step (2).
    unless self.class == Repotask # See Repotask#initialize.
      if @saved # For use when loading old/existing tasks.
        @id = args[:id]
        load_locations_and_starter
      else      # For use when creating new tasks.
        @id = calculate_id
        # Step (3).
        load_locations_and_starter(args)  # (a) Load new starter & locations; save starter.
        save_change_timestamp_to_settings # (b) Save change timestamp.
        save_new_task                     # (c) Save task to tasks.json.
        launch_task_interface # Actually launch the task view for the new task.
      end
    end
  end

  # Converts task to hash for further conversion to JSON. Used only when
  # TaskList saves a list. Returns a hash of attributes-to-save. RF
  def to_hash
    hash = {}
    self.instance_variables.each do |var|
      # These attributes don't need to be saved in tasks.json.
      skip = %w|langhash starter file location old_file old_location
                starter_location saved reset_this_session location_dir
                old_location_dir starter_location_dir|
      next if skip.include? var.to_s[1..-1]
      hash[var.to_s[1..-1]] = self.instance_variable_get var
    end
    hash
  end

  # Change the language for this task. Rarely used. Doesn't delete old language
  # files if any were created. RT
  def change_language
    new_lang = Lang.solicit_languages_from_user('c', @lang)
    # Save if new, and tell user if he is now switching languages.
    if (new_lang && new_lang != 'q' && @lang != new_lang)
      puts "OK, switching from #{@lang} to #{new_lang}."
      # Save new language instance variables.
      @lang = new_lang
      @langhash = Lang.new(@lang)
      # Repopulate location attributes.
      get_file_locations
      # And save to tasks.json too.
      $tasks.save_tasklist
    else
      puts "Sticking with #{@lang}."
    end
  end

  private

    # Sandi Metz-recommended defaults method, merged w/ args in #initialize. RF
    def defaults
      {
        tags: [],
        score: 1,
        saved: true, # The 'args' passed when a new task is made include saved: false.
        lang: $lang_defaults.name,
        date_started: DateTime.now.to_s,
        next_review_date: DateTime.now.to_s, # First review is due immediately.
        all_reviews: []
      }
    end

    # Finds the highest ID in the list and returns a number 1 higher. If no
    # tasks in list yet, returns 1. RF
    def calculate_id
      if ! $tasks.list.empty?
        max = $tasks.list.max_by { |t| t.id.to_i }
        max.id.to_i + 1  # Permits gaps; deliberately doesn't reuse IDs.
      else
        1
      end
    end

    # This method loads file locations, @starter, and writes a new starter file,
    # depending on whether the task is new or saved. Bit convoluted. RF
    def load_locations_and_starter(args = {})
      get_file_locations  # This assigns @file, @location, @old_file,
                          # @old_location, and @starter_location.
      if @saved
        @starter = load_starter
      else # i.e., if a new task...
        @starter = args[:starter]
        @starter = add_id_to_java_starter if @lang == 'Java' and @starter
        create_folder_if_necessary(@location_dir)
        create_folder_if_necessary(@starter_location_dir)
        File.write(@starter_location, @starter) unless @starter.nil?
      end
    end

    # Given an ID, load the task's file locations. RF
    def get_file_locations
      # Determine filename for answer for this task.
      ext = @langhash.ext
      dir = determine_directory(@id)
      @file = "answer_#{@id}.#{ext}"
      @location_dir = "data/answers/#{dir}/"
      @location = "data/answers/#{dir}/#{@file}"
      # Determine filename for old answers for this task. (Helper.)
      @old_file = "answer_old_#{@id}.#{ext}"
      @old_location_dir = "data/answers/#{dir}/"
      @old_location = "data/answers/#{dir}/#{@old_file}"
      @starter_location_dir = "data/starters/#{dir}/"
      @starter_location = "data/starters/#{dir}/starter_#{@id}.#{ext}"
    end

    # Tests if a folder is necessary to create for a particular answer, old
    # answer, or starter file. Creates the folder if so. Unused return.
    def create_folder_if_necessary(dir)
      return if File.directory?(dir)
      `mkdir -p #{dir}`
    end

    # If starter file exists, return contents (for @starter); else nil. RF
    def load_starter
      if File.exist?(@starter_location) && File.stat(@starter_location).size > 0
        File.read(@starter_location)
      else
        nil
      end
    end

    # Adding @id to the class name is necessary here if the code is to be
    # runnable and since the @id isn't assigned by the factory methods. (The
    # factory method, Task#generate_new_task, only prepares the values
    # necessary to initialize the object.) RF
    def add_id_to_java_starter
      @starter = @starter.gsub!('answer_ {', "answer_#{@id} {")
    end

    # Used only when creating a new task. Simply adds the task to @list, saves
    # the task by saving the whole @list, and toggles @saved to true.  RF
    def save_new_task
      @saved = true
      # Add object to the front of the $tasks.list (where sorting would put it).
      $tasks.list.unshift(self)
      # Save the tasklist.
      $tasks.save_tasklist
    end

    # Expects score; return suggested timestamp of next review, according to a
    # simple spaced repetition algorithm. (User needn't accept this.)  RF
    def calculate_spaced_repetition_date(score)
      adjust_by = 0
      # If first review, it's an easy return.
      if @all_reviews.length == 0
        adjust_by = case score
        when 1
          1
        when 2
          1
        when 3
          2
        when 4
          4
        when 5
          7
        end
      else
        # Otherwise, it is the second or later review, and so we make some calculations.
        # Set interval (time between present and most recent review):
        interval = ( DateTime.now - DateTime.parse(@all_reviews[-1]['review_date']) ).round
        interval = 1 if interval < 1 # Minimum interval time = 1 day.
        adjust_by = case score
        when 1
          1
        when 2
          [(interval * 0.25), 2].max.round
        when 3
          [(interval * 0.5), 4].max.round
        when 4
          (interval * 1.5) < 5 ? 5 : interval * 1.5
        when 5
          (interval * 2.0) < 7 ? 7 : interval * 2.0
        end
      end
      return_date = adjust_date_to_avoid_clumping(DateTime.now + adjust_by)
    end

    # Given a timestamp, return a timestamp that avoids clumping too many
    # tasks on a date.
    def adjust_date_to_avoid_clumping(ts)
      # Don't bother, if ts is within the next two days.
      return (ts) if ts.between?(DateTime.now, DateTime.now + 2)
      # (1) Count number of tasks now scheduled for the date of the timestamp,
      # as well as on the two surrounding dates.
      # (1.a) Assign calendar dates to tasks within 72 hrs of ts (YYYYMMDD).
      nearby_timestamps = find_tasks_nearby_in_date(ts)
      # (1.b) Calculate the number of tasks on the three days surrounding ts.
      pdc, dc, ndc = count_nearby_days(ts, nearby_timestamps)
      day_counts = [pdc, dc, ndc]
      p day_counts
      # (2) If ts is over 120% the average, or the other two counts are too
      # low, then propose to put it on the date with the lowest percentage.
      average = day_counts.reduce(:+) / 3.0
      if ( dc + 1 < (average * 1.2) ) and
         ! ( pdc < (average * 0.8) ) and
         ! ( ndc < (average * 0.8) )
        return ts
      else
        # Seems klugy. Surely there's a more efficient way?
        least = day_counts.min
        index_of_least = day_counts.find_index(least)
        case index_of_least
        when 0
          puts "Recommend prev"
          return ts - 1
        when 1
          puts "Recommend staying put"
          return ts
        when 2
          puts "Recommend next"
          return ts + 1
        end
      end
    end

    # Given a timestamp (a DateTime object), return a subarray of $tasks that
    # are scheduled within two days of this one.
    def find_tasks_nearby_in_date(ts)
      nearby_timestamps = $tasks.list.find_all do |t|
        t = DateTime.parse(t.next_review_date)
        t.between?(ts-2, ts+2)
      end
      # Return just the timestamps (Date objects), not the whole Task objects.
      nearby_timestamps.map {|t| t.next_review_date}
    end


    def count_nearby_days(ts, timestamps)
      # Determine a calendar date for ts, for ts-24h, and ts+24h.
      prev_day = month_day_array(ts-1) # [month, day]
      day = month_day_array(ts)
      next_day = month_day_array(ts+1)
      prev_day_count = day_count = next_day_count = 0
      # Actually count up number of tasks falling on the three dates.
      timestamps.each do |timestamp|
        eval_day = month_day_array(timestamp)
        case eval_day
        when prev_day
          prev_day_count += 1
        when day
          day_count += 1
        when next_day
          next_day_count += 1
        end
      end
      return prev_day_count, day_count, next_day_count
    end

    # Given a timestamp, return an array of the form [month, day].
    def month_day_array(date)
      date = DateTime.parse(date) unless date.class == DateTime
      [date.strftime("%-m"), date.strftime("%-d")]
    end

end # of class Tasks
