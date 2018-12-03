module WrappingHelper

  # Given a string representing the contents of a longish file, output a
  # similar string with newlines redistributed so that the likely paragraphs
  # are wrapped before n (=75) characters while the code bits are not wrapped.
  # Spacer is used when the first line will have, e.g., '(JavaScript) '.
  def wrap_overlong_paragraphs(para_string, spacer=0)
    # First, for instruction fields that feature e.g. '(Ruby)', insert a
    # placeholder into the text (temporarily) so wrapping looks good when
    # displayed with those prepended strings.
    spacer += 3 if spacer > 0 # for '(', ')', and ' '
    para_string = ('x' * spacer) + para_string
    # Next, divide para (which is one long string with potentially many \n
    # in it) into an array of *likely* paragraphs.
    # Identify potential paragraphs (=two or more newlines).
    paras = para_string.split(/\n\n/)
    # Width at wrapping can be univerally set from here.
    width = 75
    # Iterate array and output hash with "is it an actual para' data.
    para_hashes = test_if_actual_paras(paras, width)
    # Then, wrap the likely paragraphs (those marked 'true').
    paras = para_hashes.map do |para|
      if para[:is_wrappable] # Wrap if it's a wrappable paragraph.
        wrap(para[:text], width)
      else # Otherwise, return the unwrapped paragraph.
        para[:text]
      end
    end
    paras.join("\n\n")[spacer..-1]
  end

  # Output an array of hashes with data about whether a para is really a para.
  def test_if_actual_paras(paras, width) # 'paras' is an array of strings (=paras).
    para_hashes = []
    paras.each do |para|
      is_wrappable = false
      # For each para, split on newlines.
      para_lines = para.split("\n") # This is another array of strings (lines).
      para_lines = [para_lines] unless para_lines.class == Array
      # If there is only one line in para, mark as a paragraph.
      if para_lines.length == 1
        is_wrappable = true
      # If 2 or more lines are under 50 in length, don't wrap.
      elsif ( para_lines.count {|line| line.length < 50} >= 2 )
        is_wrappable = false
      # Otherwise, if there's a line over 75, wrap.
      elsif (para_lines.any? {|line| line.length >= width})
        is_wrappable = true
      end
      # NOTE FOR LATER: doesn't handle edge cases where the author has a
      # paragraph that includes indented lines, using the indented lines as
      # paragraph separators. Those sorts of paragraphs will not be wrapped.
      para_hashes << {is_wrappable: is_wrappable, text: para} # para = string w/ \n
    end
    para_hashes
  end

  # Simply accepts a string paragraph with \n; wraps it at n characters wide.
  def wrap(text, width)
    # Strip newlines.
    text.gsub!("\n", " ") # 'text' is still a string paragraph, just lacks \n.
    # Add them in just before n words.
    newlines = []
    line = ''
    word_array = text.split(/\s+/)
    word_array.each_with_index do |word,i|
      # See if this word can be added to a line.
      if (line + " " + word).length >= width # Too long!
        newlines << line  # Add working line to array of lines (no space; end of line).
        line = word + " " # Start constructing new working line, with space.
        newlines << line if i + 1 == word_array.length # Last word gets own line!
      else # Not too long.
        line += word + " "  # So go ahead and add word to line, with space.
        newlines << line if i + 1 == word_array.length # Last word gets own line!
      end
    end
    newlines.map{|l| l.strip}.join("\n")
  end

end
