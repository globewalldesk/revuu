module HelpHelper
  # Note, passes along a copy of the launching object in order to return there.
  def launch_instructions_system(options = nil)
    clear_screen
    skip_list = false
    instr_choice = ''
    options ||= {
      instructions: big_instruction_array,
      title: 'REVUU HELP TOPICS:',
      qualifier: ''
    }
    until instr_choice == 'q'
      unless skip_list
        display_instruction_choices(options)
        puts "Type a number above to learn how to use the " +
             "#{options[:qualifier]}system, or [q]uit: "
      end
      instr_choice = get_user_command('i')
      next if instr_choice == 'q'
      instr_choice = instr_choice.to_i
      if validate_instr_choice(instr_choice, options)
        # Repotasks have a whole nother instruction system.
        unless options[:instructions][instr_choice-1][:title] ==
               "NEW! How to use the repotask system"
          display_instruction(instr_choice, options)
          skip_list = false
        else
          launch_repotask_instructions_system
        end
      else
        puts "Not a valid option.\n\n"
        skip_list = true
      end
    end
    return "You can type '?' to get back to help."
  end

  def display_instruction_choices(options)
    instructions = options[:instructions]
    # Prepare string containing big_instruction_array titles.
    title = options[:title]
    title_string = '=+' * (title.length/2).round
    title_string += "\n#{title}\n"
    title_string += ('=+' * (title.length/2).round) + "\n"
    line_counter = 0
    new_line = ''
    instructions.each_with_index do |instr, i|
      this_addition = "(#{i + 1}) #{instr[:title]} "
      # If addition this addition to the string would make it
      # over 75 characters, then add a newline to the string
      # and reset line_counter
      if (line_counter + this_addition.length) > 75
        title_string << new_line + "\n"
        new_line = this_addition
        if (instructions.length - 1 == i)
          title_string << new_line
        end
        line_counter = this_addition.length
      else
        new_line << this_addition
        if (instructions.length - 1 == i)
          title_string << new_line
        end
        line_counter += this_addition.length
      end
    end
    # Print the string.
    puts title_string + "\n\n"
  end

  def validate_instr_choice(i, options)
    # i is valid iff it (-1) is an index of $big_instruction_array
    (i-1).between?(0, options[:instructions].length - 1)
  end

  # Given an index number, print out the corresponding content from $big_instruction_array.
  def display_instruction(i, options)
    instructions = options[:instructions]
    clear_screen
    print("(" + i.to_s + ") ")
    print instructions[i-1][:title].capitalize + ":\n"
    puts('=' * 75)
    puts "#{instructions[i-1][:content]}"
    puts('=' * 75)
  end

  def big_instruction_array
    [ {
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

Currently, we support Ruby, JavaScript (Node.js), Python, Java, C, and
Bash scripting. We also support many commonly-used text editors and
IDEs.

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
navigating to /data and there deleting tasks.json (don't delete revuu.rb
--that's the app). If you want to delete them one at a time, you can do
so by pressing 'd' and then typing the number next to the question you
want to delete.

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

Right now, Revuu supports Ruby, JavaScript, Python, Java, C, and Bash
(and text files). I can easily add more languages; just let me know.
There's no reason to think your language of choice can't be supported.

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
      title: 'how do I add a title?',
      content: <<-ADDTITLE
It's simple to add a title to your task: the first line of the task
instructions serves as a title. Revuu's author skips down a line or two
after the title just for clarity to the reader.
ADDTITLE
    },
    {
      title: 'review (practice, answer) a task',
      content: <<-REVIEWATASK
Revuu makes it really easy to review a task, i.e., writing a script that
follows the instructions for a task. Just go to the task view (by
entering the number next to it) and press 'a'.

This will open up a file, with a well-chosen filename based on the task
ID and programming language, using your text editor of choice (remember,
you can change the default by choosing 'e' for editor from the top-level
task list).

To run your script, whether it is in progress or finished, simply save
and press 'r'. If the language is compiled, the command to compile will
be run first automatically before executing the file.

Be sure to press 's' for save a review after you're done. See the
separate help items about this and also about how spaced repetition
works.

Note, if you have already written an answer before, the script prompts
you to save/archive your old answer; this is done automatically for you
just by pressing 'y'. It can be a great resource for your later review
to see your earlier solutions. Note that programs that have a single
main function (e.g., C and Java) overwrite rather than append the
answer. Ruby and JavaScript, by contrast, simply append answers to the
top of the list. You can actually read your old answers with 'o' and
re-run your old scripts with 'rr'.
REVIEWATASK
    },
    {
      title: 'save (record) a review',
      content: <<-SAVEAREVIEW
After you have successfully finished a task, you should press 's' for
save (or record) the information that a review was performed. This
prompts you to do two things: first, to judge your level of mastery of
the material. Mastery doesn't necessarily mean your total memorization
of every little thing; sometimes, we have mastered something that we
still have to look up information to finish.

Second, Revuu asks you to either (1) accept the date that the spaced
repetition algorithm recommends for your next review, simply by pressing
"Enter", or (2) enter the date yourself (or, rather, a plain English
string such as "two weeks from now" or "next Tuesday").

Bear in mind that your judgment about when you should review the
material is probably more reliable than the algorithm. Please look at
the help item titled "how the spaced repetition algorithm works."
SAVEAREVIEW
    },
    {
      title: 'how the spaced repetition algorithm works',
      content: <<-SPACEDREPETITION
In general, spaced repetition is the learning technique of spacing out
reviews of learned information in ever-increasing increments, unless
more frequent repetitions prove to be necessary.

Here are the rules that Revuu's simple version of this algorithm follows
(note, "interval" means the interval between today and the most recent
review):

Score  First review         All later reviews
    1  tomorrow             tomorrow
    2  tomorrow             greater of 0.25 the interval or in 2 days
    3  in 2 days            greater of 0.5 of the interval or in 4 days
    4  in 4 days            in 1.5 times the interval
    5  in 1 week            in 2 times the interval

Please DO NOT rely religiously on this algorithm. Your judgment is
probably considerably more reliable than the algorithm. Sometimes you
might benefit from frequent repetition of material that you are
confident of; sometimes you might not want to see some material that is
shaky for months to come, may because it isn't important.
SPACEDREPETITION
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
      title: 'save, run, and view old answers',
      content: <<-OLDANSWERS
Another cool feature of Revuu is that the app automatically archives old
answers for you (this is done when you press 'a' and then choose 'y' to
archive), and then allows you view them again with 'o' for old answer
and to run them again with 'rr' for re-run. Note that while languages
like JavaScript and Ruby append newer answers to the top of the archive
file, languages that permit only one main function like C and Java
entirely overwrite the old answer, which will be lost forever.
OLDANSWERS
    },
    {
      title: 'delete a task',
      content: <<-DELETEATASK
To delete a task, first you have to be on the task list view (the top
level). Then press 'd' and enter the number next to the task you want to
delete. WARNING: there is no "are you sure?"-type prompt, so be careful
about what number you enter. The deleted task and its data will be gone
forever; be careful.

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
several different languages at the same time on Revuu. To set the
default language (which you accept by hitting "Enter" when you're
creating a new task), go to the task list (top level) and type 'p' for
programming language.

As to the language of an individual task, you set it when you create the
task. But this can be changed at any time from the view page for a
particular task (if you're not there, just type the number next to it
from the task list). The command is 'c' for configure language.
CHANGELANGUAGE
    },
    {
      title: 'navigation',
      content: <<-NAVIGATE
To open a task, type the number next to it; to get back to the task
list, press 'q'.

To view the next task (the one with the earliest due date), press 'x'
from the task list (top level) view.

To go to the next page of tasks (assuming you have over 10), press '>'
(or '.'). To go back, press '<' (or ','). To go to the end of several
pages, type '>>' (or '..'); to go to the beginning, '<<' (or ',,').
NAVIGATE
    },
    {
      title: 'how do I delete all loaded data and start afresh?',
      content: <<-DESTROY
Simply press 'de'. If you really don't care about your data and want it
erased forever, this is a good option. It's also how you'd get rid of
the sample data after you looked it over. It's also how you'd start a
new data collection with a specific topic after properly archiving
another collection with a different topic.
DESTROY
    },
    {
      title: 'can I save different data repositories separately?',
      content: <<-DIFFREPOS
Revuu's archive system allows you to manage questions from different
topics (or people) separately. You can restrict a review session to one
language or another by searching on a language tag.

To make different data repos for different topics (or people),
(1) Press 'a' from the task list to go to the archive system, and with
'c', for 'create archive', save the current data set *using a tag*.
(2) Back in the task view, press 'de' to destroy all the questions.
(3) Start a new repo. When you're ready to archive it, return to the
archive system and use a *different* tag from the first.

Whenever you want to switch from data set to data set, then:
(4) Go to the archive system with 'a'.
(5) Press 'c' to create an archive of your latest data and be sure to
use the CORRECT tag, i.e., the one of the one you're saving.
(6) Then press 'l' to load the archive you want to switch to.
DIFFREPOS
    },
    {
      title: 'back up, share, and import data',
      content: <<-ARCHIVESYSTEM
Revuu has a fairly extensive archive system. Press 'a' from the tasklist
to launch it.

Your live data is saved in the data/ folder, not the archives/ folder.
When you archive (with 'c' for create archive) your data, you are simply
making a tarball, a copy, of the data/ folder and placing the copy in
archives/. Grab it from there to share with others.

When you press 'l' for load archive, you are getting ready to use an
existing archive (tarball); you'll overwrite your currently live data.

If you're new to Revuu, you can check out some sample data by
(1) pressing 'sa', (2) pressing 'l' and then choosing the sample data
archive you just imported, then (3) 'q' to quit the archive system.
From the task list, you can always delete this data en mass with 'de'.

WARNING 1: Please be aware that this will first ERASE any existing live
data in data/. You can make an archive of your live data with 'c'.

WARNING 2: Overwriting your most recent archive, and permanently losing
it, is possible if you accidentally load some old data into your data/
folder (i.e., make it live) and then archive that. So be careful not to
re-archive old data.

That said, it is possible (using tags) to work with and switch between
different archives. Just be sure, always, to use tagged names for your
archive files rather than the default plain "archive_YYYYMMDD.tar" name.
ARCHIVESYSTEM
    },
    {
      title: 'NEW! How to use the repotask system'
    }
 ]
  end
end
