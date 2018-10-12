module HelpHelper
  
  # Note, passes along a copy of the launching object in order to return there.
  def launch_instructions_system
    clear_screen
    puts "Welcome to Revuu!"
    instr_choice = ''
    skip_list = false
    until instr_choice == 'q'
      unless skip_list
        display_instruction_choices
        puts 'Type a number above to learn how to use the system, or [q]uit: '
      end
      instr_choice = get_user_command('i')
      next if instr_choice == 'q'
      instr_choice = instr_choice.to_i
      if validate_instr_choice(instr_choice)
        display_instruction(instr_choice)
        skip_list = false
      else
        puts "Not a valid option.\n\n"
        skip_list = true
      end
    end
  end

  def display_instruction_choices
    # Prepare string containing big_instruction_array titles.
    title_string = "\nHELP TOPICS:\n"
    line_counter = 0
    new_line = ''
    $big_instruction_array.each_with_index do |instr, i|
      this_addition = "(#{i + 1}) #{instr[:title]} "
      # If addition this addition to the string would make it
      # over 75 characters, then add a newline to the string
      # and reset line_counter
      if (line_counter + this_addition.length) > 75
        title_string << new_line + "\n"
        new_line = this_addition
        line_counter = this_addition.length
      else
        new_line << this_addition
        if i == ($big_instruction_array.length - 1)
          title_string << new_line
        end
        line_counter += this_addition.length
      end
    end
    # Print the string.
    puts title_string + "\n\n"
  end

  def validate_instr_choice(i)
    # i is valid iff it (-1) is an index of $big_instruction_array
    (i-1).between?(0, $big_instruction_array.length - 1)
  end

  # Given an index number, print out the corresponding content from $big_instruction_array.
  def display_instruction(i)
    clear_screen
    print("(" + i.to_s + ") ")
    print $big_instruction_array[i-1][:title].capitalize + ":\n"
    puts('=' * 75)
    puts "#{$big_instruction_array[i-1][:content]}"
    puts('=' * 75)
  end

  $big_instruction_array = [
    {
      title: "introduction",
      content: <<-ENDINTRO
Welcome to Revuu!

This app will help you review programming tasks, improving understanding 
and keeping your skills fresh. It was written with the notion that 
programmers (and others) need repetition of not declarative but 
procedural knowledge.

So when you perform a review, you don't try to answer a question in 
words. Instead, you try to perform a task. Essentially, to use Revuu, 
you'd add complex, not simple, tasks. Probably the ideal Revuu task 
would require 2-10 minutes to complete.

The basic functions of the program are adding tasks, using the handy 
answer filing and editing system (which probably works with your 
favorite text editor), running the script and seeing the results, and 
recording that you've done a review and that the next review should be 
done on a certain date. The two basic views of the app are a paginated 
list of tasks and an individual task view.

Currently, we support Ruby, Node.js (JavaScript), Java, C, and Bash 
scripting. We also support many commonly-used text editors and IDEs.

Add copious, well-chosen tags in order to be able to sort tasks.

Revuu ships with a bunch of pre-made questions and answers by way of 
demonstration. You can delete these and make your own, if you like. The 
questions are mostly Ruby and JavaScript right now.
ENDINTRO
    },
    {
      title: "getting started",
      content: <<-GETTINGSTARTED
Basically, Revuu is all about (1) giving yourself programming tasks that 
drill skills you want to learn, (2) making it super-easy to write (with 
your text editor of choice) and run scripts from within Revuu, and 
(3) keeping track of how confident you feel and, consequently, when your 
next review for an skill should be.

The first thing you'll want to do is to check (and probably change) the
default text editor: from the task list view (the one you see when you 
first start the program), press 'e' for editor.

Since Revuu ships with a lot of ready-made questions, you should 
probably delete a lot of questions. You can delete all of them simply by 
navigating to /data and there deleting revuu.json (don't delete revuu.rb
--that's the app). If you want to delete them one at a time, you can do 
so by pressing 'd' and then typing the ID number of the question to 
delete.

If you retain any questions, you'll want to change the "next review" 
dates on them. You have to do that one at a time (or I can write a 
method to do that automatically--let me know if you want me to).

To *really* get started, you'll want to add questions based on your 
studies or by examining how you solved problems in your own code (you 
want to commit that stuff to memory, right?). To get started, just press 
'n' for new and follow the instructions.

After you write a task, you should answer it ('a' on the task view) and 
then make sure the answer is correct by running your script ('r'). 
GETTINGSTARTED
    },
    {
      title: 'create a task',
      content: <<-CREATEATASK
To write a new task for regular review, press 'n'. The app will lead you 
through what you need to do. 

I recommend that you keep the tasks fairly simple--enough to accomplish 
in, say, two to 10 minutes. It is also a good idea to make sure the 
outcome is objective, so you can check up on yourself easily.

If you don't like the default text editor, you can switch it by going to 
the task list (the one you see when you first start the program) and 
pressing 'e'.

Right now, Revuu supports Ruby, JavaScript, Java, C, and Bash (and text 
files). I can easily add more languages; just let me know. There's no 
reason to think your language of choice can't be supported.

As to tags, a key tip to bear in mind is to add any unusual methods, 
keywords, techniques, and concepts (that have clear names) to the tag 
list. Tags are separated by commas, although if you enter them one to a 
line, they'll be rendered in the correct format.

DO add tags, because otherwise you won't be able to search or filter.

Set an initial score for yourself based on how confident you are in 
doing the task. I don't think you have to have everything memorized to 
get a 5, but that's up to you. Your first review is scheduled for the 
same day. (See 'review a task' for more details.)
CREATEATASK
    },
    {
      title: 'review (practice, answer) a task',
      content: <<-REVIEWATASK
Revuu makes it really easy to review a task, i.e., writing a script that 
follows the instructions for a task. Just go to the task view (by 
entering its ID number) and press 'a'.

This will open up a file, with a well-chosen filename based on the task 
ID and programming language, using your text editor of choice (remember, 
you can change the default by choosing 'e' for editor from the top-level 
task list).

To run your script, whether it is in progress or finished, simply save 
and press 'r'. If the language is compiled, the command to compile will 
be run first automatically before executing the file.

If you have already written an answer before, the script prompts you to 
save/archive your old answer; this is done automatically for you just by 
pressing 'y'. It can be a great resource for your later review to see 
your earlier solutions. Note that programs that have a single main 
function (e.g., C and Java) overwrite rather than append the answer. 
Ruby and JavaScript, by contrast, simply append answers to the top of 
the list. You can actually read your old answers with 'o' and re-run 
your old scripts with 'rr'.
REVIEWATASK
    },
    {
      title: 'run an answer/script',
      content: <<-RUNANANSWER
One of the coolest things about Revuu is that you can run your scripts
right from within the app. After you've written your answer, simply type
'r' for run. You can also re-run archived answers with 'rr'. Any error
messages or stack traces that you'd see on the command line will appear
in the window.

It can be a handy way to remind yourself what you're expecting out of
an answer by re-running an archived answer.
RUNANANSWER
    },
    {
      title: 'edit task information',
      content: <<-EDITOTHERTASKINFO
Almost everything about a task can be edited after it has been created,
regardless of whether it's been answered before:

Type 'i' to edit instructions (i.e., the task text that appears at the
top of the task page).

Type 't' to edit tags. (Note, language tags are autogenerated.)

Type 'd' to edit/schedule the date of next review. Simply type such
words as "tomorrow" or "in 2 weeks" or "4 months anon". Past dates and
exact dates work too.

Type 'sc' to edit the score. This doesn't do much yet but it will in the
future.
EDITOTHERTASKINFO
    },
    {
      title: 'archive and view archive',
      content: <<-ARCHIVE
Another cool feature of Revuu is that the app automatically archives old
answers for you (this is done when you press 'a' and then choose 'y' to
archive), and then allows you view them again with 'o' for old answer
and to run them again with 'rr' for re-run. Note that while languages
like JavaScript and Ruby append newer answers to the top of the archive
file, languages that permit only one main function like C and Java 
entirely overwrite the old answer, which will be lost forever.
ARCHIVE
    },
    {
      title: 'delete a task',
      content: <<-DELETEATASK
To delete a task, first you have to be on the task list view (the top
level). Then press 'd' and enter the task ID number. WARNING: there is
no "are you sure?"-type prompt, so be careful about what number you
enter. The deleted task and its data will be gone forever; be careful.

If you just don't want to see a task for a long time, you can always
view the task and then press 'd' for date and put in something like
"in 100 years".
DELETEATASK
    },
    {
      title: 'refresh the view',
      content: <<-REFRESHTASKS
Sometimes Revuu gets to be rather messy, and important stuff has 
scrolled off the top of the screen. You can refresh your view, though.

If you're on the task list (the top level), press 'l' to list the tasks
--to clear the screen and redisplay the task list.

If you're viewing a particular task, press 'f' to refresh the task 
instructions and data.
REFRESHTASKS
    },
    {
      title: 'search and filter tasks',
      content: <<-SEARCHFILTER
First, make sure you have a decent system of tags to search and filter
on. Just type 't' for tag and type in a tag. It must closely match a 
tag to get any results.

The search and filter feature is not sophisticated yet. It is not
possible to search the text of task instructions.

Mainly the tag feature is useful to search on language tags. Language
tags are added (and edited) automatically by Revuu. (If you try to
delete them, they'll be re-added.)
SEARCHFILTER
    },
    {
      title: 'change text editor',
      content: <<-CHANGEEDITOR
To change the default text editor (for editing your answers), simply go
to the task list (top level) and type 'e' for editor. Revuu examines
your system to see what editors you have installed (that run from the
command line) and gives you the option to pick from those. Unless you
use a relatively unpopular text editor, yours is probably supported. If
not, write me and I can add it.
CHANGEEDITOR
    },
    {
      title: 'change programming language',
      content: <<-CHANGELANGUAGE
Each task has its own associated programming language, so you can use
several different languages at the same time on Revuu. You choose a
language when you create a task. But this can be changed at any time 
from the view page for a particular task (if you're not there, just type 
its ID number from the task list). The command is 'c' for configure
language.

(Just bear in mind that if you do change a language, your answer files
will no longer be accessible by typing 'a' and 'o'.)
CHANGELANGUAGE
    },
    {
      title: 'navigation',
      content: <<-NAVIGATE
To open a task, type its ID; to go back to the task list, press 'q'.

To view the next task (the one with the earliest due date), press 'x'
from the task list (top level) view.

To go to the next page of tasks (assuming you have over 10), press '>'
(or '.'). To go back, press '<' (or ','). To go to the end of several
pages, type '>>' (or '..'); to go to the beginning, '<<' (or ',,').
NAVIGATE
    }
  ]
end
