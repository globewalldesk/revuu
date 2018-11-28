module RepotaskView

  def display_info
    super("REPOTASK")
    display_files
    display_repotask_commands(@tag_str)
  end

  def display_files
    puts "\nFILES TO EDIT FOR REPOTASK"
    show_array_with_numbers(@files, {colored:true})
    puts "GIT INFO  Repo: #{@repo}  Branch: #{@branch}\n\n"
  end

  def display_repotask_commands(tag_str)
    puts <<~DISPLAYREPOTASKCOMMANDS
    COMMANDS  Review: [1] open file #1  [o]pen repo  [r]un answer
                      [s]ave review  configure [l]anguage  [?] help
                Edit: [i]nstructions  [c]ommands to run  [fi]les  [t]ags#{tag_str}
                      [d]ate of next review  [sc]ore
                Also: re[f]resh view  [q]uit review and editing

    DISPLAYREPOTASKCOMMANDS
  end

end
