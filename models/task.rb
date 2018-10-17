###############################################################################
# The Task class enables the user to input new tasks and do basic task manipulation.
class Task

  class << self
    # Prepares data for new task.
    def generate_new_task
      clear_screen
      # Get task instructions from user.
      instructions = self.get_input(type: 'Instructions', prompt:
        "INPUT INSTRUCTIONS:\nOn the next screen, you'll type in the instructions for your new task. ",
        required: true)         # <-- needs a lot of work/refactoring
      return nil if instructions == nil or instructions == 'q' # Instructions required.
      # Get language from user; returns a canonical, approved name for saving.
      lang = Lang.pick_language_name($lang_defaults.name)
      # Get tags from user. Arrives as string.
      tags = get_tags_from_user # <-- needs a lot of work/refactoring
      return nil if tags == 'q'  # TEMPORARY kluge
      # Add standard tags and massage tags. Output is an array or 'q'.
      tags = Task.validate_tags(tags, lang)
      # Note: tags are not required.
      # Get initial score from user.
      score = get_initial_score_from_user
      # Construct new task!
      Task.new(instructions: instructions, tags: tags, score: score, lang: lang)
    end # of ::generate_new_task

    # Massage user-input tags so standardized. Returns tag array.
    def validate_tags(tags, lang)
      # Convert newlines to commas.
      tags.gsub!("\n", ',') if tags
      # Convert user input string, which should be comma-separted, into array.
      tags = (tags ? tags.split(',').map!(&:strip) : [])
      # Strip out language tags so you can put 'em in correctly; also, strip empty tags.
      tags.reject! {|tag| ['JavaScript', 'JS',
        'Node', 'Node.js', 'Bash', 'command line', 'bash scripting', 'shell',
        'shell scripting', 'linux', 'Unix', 'Java', 'Ruby', 'C',
        'C programming language', 'C language', 'Python'].include? tag }
      # Making use of an accessor of the Lang class variable 'defined_langs',
      # first 'find' the hash matching the param 'lang'; return [:alts] value.
      lang_alts = Lang.defined_langs.find {|l| l[:name] == lang }[:alts]
      puts lang, lang_alts
      # Put in canonical language tags; splat operators ensure that subarrays aren't created.
      tags = tags.unshift(*[lang, *lang_alts])
    end
  end # Of class methods

  attr_accessor :instructions, :tags, :score, :saved, :lang, :langhash, :file, :location,
                :old_file, :old_location
  attr_reader :id, :date_started, :next_review_date, :all_reviews

  def initialize(args = {})
    args = defaults.merge(args)
    @instructions = args[:instructions]
    @tags = args[:tags]
    @score = args[:score]
    @saved = args[:saved]
    @lang = args[:lang]
    @date_started = args[:date_started]
    @next_review_date = args[:next_review_date]
    @all_reviews = args[:all_reviews]
    if @saved # For use when loading old/existing tasks.
      @id = args[:id]
      @langhash = Lang.new(@lang)
      get_locations # This assigns @file, @location, @old_file, and @old_location
    else      # For use when creating new tasks.
      @id = calculate_id
      @langhash = Lang.new(@lang)
      # First review is due immediately.
      @next_review_date = DateTime.now.to_s # Saved as string.
      get_locations # This assigns @file, @location, @old_file, and @old_location
      save_new_task
      edit
    end
  end

  # Converts task to hash for further conversion to JSON.
  def to_hash
    hash = {}
    self.instance_variables.each do |var|
      next if var.to_s[1..-1] == 'langhash' # No need to save this object.
      hash[var.to_s[1..-1]] = self.instance_variable_get var
    end
    hash
  end

  # Given a task ID, set the globals for the task's answer files & location.
  def get_locations
    # Determine filename for answer for this task.
    ext = @langhash.ext
    @file = "answer_#{@id}.#{ext}"
    @location = "./answers/#{@file}"
    # Determine filename for old answers for this task. (Helper.)
    @old_file = "answer_old_#{@id}.#{ext}"
    @old_location = "./answers/#{@old_file}"
  end

  def change_language
    new_lang = Lang.pick_language_name(@lang)
    # Save if new, and tell user if he is now switching languages.
    if (@lang != new_lang)
      puts "OK, switching from #{@lang} to #{new_lang}."
      # Save new language instance variables.
      @lang = new_lang
      @langhash = Lang.new(@lang)
      # Repopulate location attributes.
      get_locations
      # And save to revuu.json too.
      $tasks.save_tasklist
    else
      puts "Sticking with #{@lang}."
    end
  end

  private

    def defaults
      {
        tags: [],
        score: 1,
        saved: false,
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
          2
        when 3
          4
        when 4
          7
        when 5
          10
        end
        return DateTime.now + adjust_by

      else
        # Otherwise, it is the second or later review, and so we make some calculations.
        # Set interval (time between present and most recent review):
        interval = ( DateTime.now - DateTime.parse(@all_reviews[0]['review_date']) ).round
        interval = 1 if interval < 1 # Minimum interval time = 1 day.
        adjust_by = case score
        when 1
          1
        when 2
          [(interval * 0.25), 4].max.round
        when 3
          [(interval * 0.8), 7].max.round
        when 4
          interval * 2
        when 5
          interval * 3
        end
        return DateTime.now + adjust_by
      end
    end

end # of class Tasks
