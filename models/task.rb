###############################################################################
# The Task class enables the user to input new tasks and do basic task manipulation.
class Task
  extend TaskFactory # This prepares the data needed to start a new task.

  attr_accessor :instructions, :tags, :score, :saved, :lang, :langhash, :file,
                :location, :old_file, :old_location, :starter, :starter_location
  attr_reader :id, :date_started, :next_review_date, :all_reviews

  def initialize(args = {})
    args = defaults.merge(args)
    @lang = args[:lang]
    @instructions = wrap_overlong_paragraphs(args[:instructions], @lang.length)
    @tags = args[:tags]
    @score = args[:score]
    @saved = args[:saved]
    @date_started = args[:date_started]
    @next_review_date = args[:next_review_date]
    @all_reviews = args[:all_reviews]
    if @saved # For use when loading old/existing tasks.
      @id = args[:id]
      @langhash = Lang.new(@lang)
      get_locations # This assigns @file, @location, @old_file, and @old_location
      @starter = load_starter
    else      # For use when creating new tasks.
      @id = calculate_id
      @langhash = Lang.new(@lang)
      # First review is due immediately.
      @next_review_date = DateTime.now.to_s # Saved as string.
      get_locations # This assigns @file, @location, @old_file, and @old_location
      @starter = args[:starter]
      @starter = add_id_to_java_starter if @lang == 'Java'
      File.write(@starter_location, @starter)
      save_change_timestamp_to_settings
      save_new_task
      edit
    end
  end

  # Converts task to hash for further conversion to JSON.
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

  # Given a task ID, set the globals for the task's answer files & location.
  def get_locations
    # Determine filename for answer for this task.
    ext = @langhash.ext
    @file = "answer_#{@id}.#{ext}"
    @location = "./data/answers/#{@file}"
    # Determine filename for old answers for this task. (Helper.)
    @old_file = "answer_old_#{@id}.#{ext}"
    @old_location = "./data/answers/#{@old_file}"
    @starter_location = "./data/starters/starter_#{@id}.#{ext}"
  end

  def change_language
    new_lang = Lang.solicit_languages_from_user('c', @lang)
    # Save if new, and tell user if he is now switching languages.
    if (new_lang && new_lang != 'q' && @lang != new_lang)
      puts "OK, switching from #{@lang} to #{new_lang}."
      # Save new language instance variables.
      @lang = new_lang
      @langhash = Lang.new(@lang)
      # Repopulate location attributes.
      get_locations
      # And save to tasks.json too.
      $tasks.save_tasklist
    else
      puts "Sticking with #{@lang}."
    end
  end

  # Adding @id to the class name is necessary here if the code is to be
  # runnable and if the @id isn't assigned by the factory method. (The
  # factory method, Task#generate_new_task, only prepares the values
  # necessary to initialize the object.)
  def add_id_to_java_starter
    @starter = @starter.gsub!('answer_ {', "answer_#{@id} {")
  end

  private

    def defaults
      {
        tags: [],
        score: 1,
        saved: true,
        lang: $lang_defaults.name,
        date_started: DateTime.now.to_s,
        all_reviews: []
      }
    end

    def calculate_id
      if ! $tasks.list.empty?
        max = $tasks.list.max_by { |t| t.id.to_i }
        max.id.to_i + 1
      else
        1
      end
    end

    def save_new_task
      @saved = true
      # Add object to $tasks.list.
      $tasks.list.unshift(self)
      # Save the tasklist.
      $tasks.save_tasklist
    end

    # Input score; return timestamp.
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

    # If starter exists, return it (to be loaded in @starter).
    def load_starter
      if File.exist?(@starter_location)
        File.read(@starter_location)
      else
        nil
      end
    end

end # of class Tasks
