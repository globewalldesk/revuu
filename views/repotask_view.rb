module RepotaskView

  def display_info
    super("REPOTASK")
    display_files
    display_repotask_commands(@tag_str)
  end

  def display_files
    puts "\nFILES TO EDIT FOR REPOTASK"
    unless @files
      puts "No files specified. Press 'fi' to add some, if you like.\n\n"
      return
    end
    show_array_with_numbers(@files, {colored:true})
    puts "GIT INFO  Repo: #{@repo}  Branch: #{@branch}\n\n"
  end

  def display_repotask_commands(tag_str)
    puts <<~DISPLAYREPOTASKCOMMANDS
    COMMANDS  Review: [1] open file #1  [o]pen repo  [r]un answer [s]ave review
                      [oo]pen old  [rr]un old  review [h]istory  [?] help
                Edit: [i]nstructions  [c]ommands to run  [fi]les  [t]ags#{tag_str}
                      [d]ate of next review  [sc]ore
                Also: re[f]resh  config [l]anguage  [q]uit review and editing

    DISPLAYREPOTASKCOMMANDS
  end

end
