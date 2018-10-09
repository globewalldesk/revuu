module TaskView

  # Given a prompt and a test, wring an acceptable answer from the user or let
  # him abandon adding the new task.
  # REFACTOR: UGH, fix this or split it in two!
  def get_input(args)
    while true
      args[:prompt] += "\nThen press Ctrl-W to save and Ctrl-X to submit. "
      args[:prompt] += "\nPress <Enter> now to continue (or [q]uit)... "
      print args[:prompt]
      choice = gets.chomp
      # Ways to abandon input have two possible effects...
      if (choice == "q")
        return 'q'
      end
      system("rm tmp/temp.tmp") if File.file?("./tmp/temp.tmp")
      system("pico tmp/temp.tmp")
      input = File.read("./tmp/temp.tmp").strip if File.file?("./tmp/temp.tmp")
      system("rm tmp/temp.tmp") if File.file?("./tmp/temp.tmp")
      if args[:required]
        if input
          if input.length < 3
            puts("Surely not long enough...")
          else
            puts "#{args[:type]} saved."
            return input
          end
        else
          if args[:type] == 'Instructions'
            puts "Abandoning task (no input)."
            return nil
          end
        end
      else
        input ? (puts "#{args[:type]} saved."; return input) : (return nil)
      end
    end
  end # of ::get_input

  def get_tags_from_user
    get_input(type: 'Tags', prompt:
      "\nINPUT TAGS:\nOn the next screen, you'll input tags, separated by commas (optional).",
      required: false)
  end

  def get_initial_score_from_user
    puts "\nINITIAL SCORE:"
    puts "Input initial score (5: mastered, 4: confident, 3: shaky, 2: barely recall, 1: blank)"
    score = get_user_command('n').to_i
    score = 1 unless [1, 2, 3, 4, 5].include? score
    return score
  end

  def display_info
    clear_screen
    puts '=' * 75
    puts 'TASK INSTRUCTIONS:'
    puts '(' + @lang + ') ' + @instructions
    puts '=' * 75
    date = DateTime.parse(@date_started).strftime("%-m/%-d/%Y")
    printf("  ID: %d   Started: %-10s   Reviews: %d   Score: %s\n",
      @id, date, @all_reviews.length, @score)
    last_date_timestamp = @all_reviews.empty? ?
      nil : @all_reviews.max_by {|r| r['review_date']}['review_date']
    last_precise_date = last_date_timestamp ?
      DateTime.parse(last_date_timestamp).strftime("%-m/%-d/%Y") : 'none yet'
    next_precise_date = DateTime.parse(@next_review_date).
      strftime("%-m/%-d/%Y")
    puts "  Review dates >>  Last: #{last_precise_date}  Next: #{next_precise_date} (#{prettify_timestamp(@next_review_date)})"
    puts "\nCOMMANDS  Review: [s]ave review  [a]nswer  [r]un answer  answers [h]elp"
    puts   "                  [c]onfigure language  [o]ld answers  [rr]un old answers"
    puts   "            Edit: [i]nstructions  [t]ags  [d]ate of next review  [sc]ore"
    puts   "            Also: re[f]resh view  [q]uit review and editing\n\n"
  end

  def get_score(prompt)
    puts "Input score (5: mastered, 4: confident, 3: shaky, 2: barely recall, 1: blank)"
    score = get_user_command(prompt).to_i
    unless [1, 2, 3, 4, 5].include?(score)
      puts "Score must be between 1 and 5."
      return nil
    end
    score
  end

  def get_next_review_date(prompt)
    puts "Do next review when? (Use regular English.)"
    date = get_user_command(prompt)
    date = Chronic.parse(date) # Gem parses ordinary English input to Time obj.
    unless date.class == Time
      puts "ERROR: couldn't parse date."
      return nil
    end
    date = DateTime.parse(date.to_s).to_s # Convert Time to DateTime string.
    pretty = DateTime.parse(date).
      strftime("%-m/%-d/%Y (#{prettify_timestamp(date)})")
    date
  end


end
