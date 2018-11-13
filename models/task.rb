###############################################################################
# The Task class enables the user to input new tasks and do basic task manipulation.
class Task
  extend TaskFactory # This prepares the data needed to start a new task.
  include TaskView
  include TaskController

              # Attributes saved in tasks.json:
  attr_reader :id, :lang, :instructions, :tags, :score, :saved, :date_started,
              :next_review_date, :all_reviews,
              # Attributes inferred from this saved data:
              :langhash, :file, :location, :old_file, :old_location, :starter,
              :starter_location
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

  # Converts task to hash for further conversion to JSON. Used only when
  # TaskList saves a list. Returns a hash of attributes-to-save. RF
  def to_hash
    hash = {}
    self.instance_variables.each do |var|
      # These attributes don't need to be saved in tasks.json.
      skip = %w|langhash starter file location old_file old_location
                starter_location saved|
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
        @starter = add_id_to_java_starter if @lang == 'Java'
        File.write(@starter_location, @starter)
      end
    end

    # Given an ID, load the task's file locations. RF
    def get_file_locations
      # Determine filename for answer for this task.
      ext = @langhash.ext
      @file = "answer_#{@id}.#{ext}"
      @location = "./data/answers/#{@file}"
      # Determine filename for old answers for this task. (Helper.)
      @old_file = "answer_old_#{@id}.#{ext}"
      @old_location = "./data/answers/#{@old_file}"
      @starter_location = "./data/starters/starter_#{@id}.#{ext}"
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
        return DateTime.now + adjust_by
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
        return DateTime.now + adjust_by
      end
    end

end # of class Tasks
