# Until Revuu 3.2, all answers were held in a single directory, data/answers.
# Now we are putting them all into nested folders based on thousands,
# hundreds, and tens. Thus the user's answer for #32 will go in
# data/answers/0000/000/30; answer #2485 in data/answers/2000/400/80.

# Given an ID (string), return the directory (string) it goes in.
# Returns in the form '0000/000/00'.
def determine_directory(id)
  id = id.split('').reverse.join
  # Supports up to ten thousands of answers.
  id =~ /^(\d)(\d?)(\d?)(\d?)(\d?)/
  tens = $2 ? $2 : '0'
  huns = $3 ? $3 : '0'
  thous = $4 ? $4 : '0'
  tthous = $5 ? $5 : '0'
  "#{tthous}0000/#{thous}000/#{huns}00/#{tens}0"
end

def run_answer_fixer
  # Make array of answer files.
  Dir["./data/answers/*"].each do |f|
    # Skip it if it doesn't match; if it does, extract its ID.
    next unless f =~ /(answer_|answer_old_)(\d+)./
    # For each answer file, concatenate its proper directory.
    inner_location = determine_directory($1)
    # If the directory doesn't exist, create it.
    dir = "data/answers/#{inner_location}"
    `mkdir -p #{dir}` unless File.directory?(dir)
    # Move the answer file to the directory.
    `mv #{f} #{dir}`
  end
end

run_answer_fixer unless File.exist?("data/answers/00000")
