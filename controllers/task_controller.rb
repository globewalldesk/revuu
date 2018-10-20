module TaskController

  # Loads data and launches edit view for particular task.
  def edit
    display_info
    command = ''
    until command == 'q'
      command = get_user_command('+')
      process_edit_input(command)
    end
    $tasks.display_tasks
  end

  # Given a user command in the Task view, dispatch as appropriate.
  def process_edit_input(command)
    case command
    when 's' # Record information about review.
      record_review
    when 'a' # See Answer module for this and many of the next features.
      write_answer
    when 'h'
      launch_instructions_system
      display_info # Display the task after returning from help.
    when 'r'
      run_answer
    when 'rr'
      run_answer('old')
    when 'o'
      view_old_answers
    when 'c'
      self.change_language
    when 'i' # Edit instructions.
      edit_field('instructions')
    when 't' # Edit tags.
      edit_field('tags')
    when 'd' # Edit date of next review (might be based on spaced repetition algorithm).
      date = get_next_review_date('d')
      save_review_date(date) if date
    when 'sc' # Edit score.
      edit_score
    when 'st'
      edit_starter
    when 'f'
      display_info
    else
      puts 'Huh?' unless command == 'q'
    end
  end

  def record_review
    puts "Good, you completed a review."
    # Get @score from user.
    score = get_score('r')
    return unless score
    # Get @next_review_date from user (might be based on spaced repetition algorithm).
    date = get_next_review_date('r', score)
    return unless date
    # Update current @score.
    @score = score
    # Update @next_review_date.
    @next_review_date = date
    # Save review date and score to @all_reviews.
    @all_reviews << {score: @score, 'review_date' => DateTime.now.to_s}
    # Save updated task data to JSON file.
    $tasks.save_tasklist
    # Refresh view.
    display_info
  end

  def edit_field(field)
    # Load current attribute contents into temp file.
    contents = (field == 'tags' ?
      (self.instance_variable_get("@#{field}").join(', ') if
      self.instance_variable_get("@#{field}") ) :
      self.instance_variable_get("@#{field}") )
    contents = wrap_overlong_paragraphs(contents) if field == 'tags'
    File.write("./tmp/#{field}.tmp", contents)
    # Open file for editing.
    system("pico tmp/#{field}.tmp")
    # Save upon closing: grab text.
    attrib = File.read("./tmp/#{field}.tmp").strip
    # Strip newlines if tags (otherwise commas are introduced).
    attrib.gsub!("\n", '') if field == 'tags'
    if attrib.empty? && field == 'instructions'
      puts "ERROR: Instructions cannot be blank."
      return nil
    end
    # Use validation method if field type is tags.
    if field == 'tags'
      attrib = self.class.validate_tags(attrib, @lang)
    end
    # In helpers/helpers.rb:
    attrib = wrap_overlong_paragraphs(attrib) if attrib.class == String
    # Set instance variable to contents of edited temp file.
    self.instance_variable_set("@#{field}", attrib)
    # Save updated instructions to JSON file if you've made it this far.
    $tasks.save_tasklist
    # Refresh view.
    display_info
  end

  # Asks the user if he wants to write some starter code. If so, opens a temp
  # file in the text editor, then grabs the text when the user gives the OK,
  # deletes the file, and returns the text (or nil).
  def starter_code_sequence(java=nil) # Lang needed for file extension.
    starter_desired = get_starter_code?
    if starter_desired
      get_input(type: 'Starter', required: false, prompt:
        "Edit the starter code on the next screen.",
        java: java)
    else
      nil
    end
  end

  # Used only in the "date of next review" command.
  def save_review_date(date)
    @next_review_date = date
    $tasks.save_tasklist
    display_info
  end

  # Used only in the "edit score" command
  def edit_score
    score = get_score('s')
    score ? @score = score : (return nil)
    $tasks.save_tasklist
    display_info
  end

  def archive_old_answer
    old_archive = File.exist?(@old_location) ? File.read(@old_location) : ''
    # Load current answer file contents.
    contents = File.read(@location)
    # If C, Java, etc., then completely overwrite old answer file
    if @langhash.one_main_per_file
      new_archive = contents
      # If Java, the main class needs to be renamed to be runnable.
      if @lang == 'Java'
        new_archive.gsub!('public class answer', 'public class answer_old')
      end
    else
    # Else the usual case: append newer answer to top of old_archive.
      # Separate different archived answers with a line of comments.
      # Use $cmnt2 for /* ... */ style comments.
      comment_separator = (@langhash.cmnt2 ? ((@langhash.cmnt*37) +
        @langhash.cmnt2) : (@langhash.cmnt*37) )
      # Concatenate current contents with archive file contents.
      new_archive =
        contents + ("\n\n\n" + @langhash.spacer + "\n" + comment_separator +
            + "\n\n\n") + old_archive
    end
    # Write concatenated contents to the location of the archive.
    File.write(@old_location, new_archive)
    # Finally, overwrite the current answer file with '' or Java template.
    create_answer_file
  end

  def create_answer_file
    if ! File.exist?(@location)
      system("touch #{@location}")
    end
    if @starter
      File.write(@location, @starter)
    elsif @lang == 'Java'
      # So far, only Java files need to be written-to before getting started.
      File.write(@location, java_starter)
    else
      File.write(@location, '')
    end
  end

  def java_starter
    return <<-JAVASTARTER
public class answer_#{@id} {
    public static void main(String[] args) {
        /* do not edit 'answer_<id>' */
    }
}
JAVASTARTER
  end

  # Adding @id to the class name is necessary here if the code is to be
  # runnable and if the @id isn't assigned by the factory method. (The
  # factory method, Task#generate_new_task, only prepares the values
  # necessary to initialize the object.)
  def add_id_to_java_starter
    @starter = @starter.gsub!('answer_ {', "answer_#{@id} {")
  end

end
