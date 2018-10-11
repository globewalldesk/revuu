###############################################################################
# The Task class enables the user to input new tasks and do basic task manipulation.
class Task

  # Massage user-input tags so standardized. Returns tag array.
  def self.validate_tags(tags)
    # Convert newlines to commas.
    tags.gsub!("\n", ',') if tags
    # Convert user input string, which should be comma-separted, into array.
    tags = (tags ? tags.split(',').map!(&:strip) : [])
    # Strip out language tags so you can put 'em in correctly; also, strip empty tags.
    tags.reject! {|tag| ['JavaScript', 'JS',
      'Node', 'Node.js', 'Bash', 'command line', 'bash scripting', 'shell',
      'shell scripting', 'linux', 'Unix', 'Java', 'Ruby', 'C',
      'C programming language', 'C language'].include? tag }
    # Put in canonical language tags; splat operators ensure that subarrays aren't created.
    tags = tags.unshift(*[$lang, *$lang_alts])
  end

  attr_accessor :instructions, :tags, :score, :saved, :lang
  attr_reader :id, :date_started, :next_review_date, :all_reviews

  def initialize(args = {})
    args = defaults.merge(args)
    @instructions = args[:instructions]
    @tags = args[:tags]
    @score = args[:score]
    @saved = args[:saved]
    @lang = args[:lang]
    @id = args[:id]
    @date_started = args[:date_started]
    @next_review_date = args[:next_review_date]
    @all_reviews = args[:all_reviews]
    if @saved == false
      @id = calculate_id
      # First review is due immediately.
      @next_review_date = DateTime.now.to_s # Saved as string.
      save_new_task
      edit
    end
  end

  # Converts task to hash for further conversion to JSON.
  def to_hash
    hash = {}
    self.instance_variables.each do |var|
      hash[var.to_s[1..-1]] = self.instance_variable_get var
    end
    hash
  end

  # Given a task ID, set the globals for the task's answer files & location. 
  def get_locations(id)
    # Determine filename for answer for this task.
    $file = "answer_#{id}.#{$ext}"
    $location = "./answers/#{$file}"
    # Determine filename for old answers for this task. (Helper.)
    $old_file = "answer_old_#{id}.#{$ext}"
    $old_location = "./answers/#{$old_file}"
  end

  private

    def defaults
      {
        tags: [],
        score: 1,
        saved: false,
        lang: $lang,
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

end # of class Tasks