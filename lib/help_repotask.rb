module HelpRepotask
  def launch_repotask_instructions_system
    options = {
      instructions: repotask_instructions,
      title: 'REPOTASK HELP TOPICS:',
      qualifier: 'repotask '

    }
    launch_instructions_system(options)
    clear_screen
  end

  def repotask_instructions
    [ {
        title: "what's a repotask?",
        content: <<-WHATSAREPOTASK
A regular task can be performed using a single file.

A repotask is a task that can be performed only using at least two files
that interact. They might have many files, contained in a directory, and
are typically maintained in a repository (repo) that is managed by a
version control system--usually Git.

Revuu's Repotask system allows you to make and review tasks that are based
on potentially big, complex systems. Crazy, maybe, but true.

NOTE: You'll have to know a bit (not too much) about Git in order to make
repotasks. If you don't know about it yet and you're serious about coding,
then learn the basics--it's worth it.
WHATSAREPOTASK
      },
      {
        title: "how to set up a repo for a repotask",
        content: <<-REPOSETUP
To make a repotask, first you have to set up a repo. Here's how:

(1) Create or move a repo (a directory with two or more files and possibly
    some subdirectories) into data/repos/.
(2) If the directory hasn't been initialized with git already, type
    "git init" on the command line of the top folder of your directory.
(3) Get your files exactly as you'll like them, ideally for several
    different questions.
(4) Add and commit your files: from the top folder again, execute
    "git add ." followed by "git commit -m 'a description'". Voila! Your
    "master" git branch is ready for repotasks!
(5) If you need a slightly changed set of files for another repotask, you
    should check out a new branch. To do that, execute:
    'git checkout -b branch_name'. Then repeat steps (3) and (4).

Repeat as needed. Remember to commit your changes (as in (4) above) if you
many any further changes; or if you want to reject them and go back to
your most recent commit, execute "git reset --hard".
REPOSETUP
      },
      {
        title: "how to create a repotask",
        content: <<-NEWREPOTASK
To start a new repotask, from the task list, press 'r'. You'll be shown a
list of your repos; you'll have to choose one. Then you'll have to choose
from the branches of that repo. HINT: If you have trouble remembering
exactly how a branch looks, you can navigate (on the command line) to the
repo and execute "git checkout <repo name>". When you do this, you might
have to commit or reset some changes if your tree is "unclean."

The rest of the procedure is similar to that for regular tasks, except for
the "Input Run Commands" screen; here, you will have to input whatever
commands you'll need in order to run your program. This might include such
things as opening a web page in a browser, starting a server, or migrating
a database. (Note, you'll have to migrate down any database changes after
answering a question.) Basically, whatever commands you'd have to execute
if you were simply doing the task in a development context, list them.

Note that you can edit all of this information within the task view page.

It might seem like a bit of work to add a repotask, but it's not too bad
after you've learned how. And it's really, really worth it!
NEWREPOTASK
      },
      {
        title: "how to do (answer) a repotask",
        content: <<-DOREPOTASK
Doing a repotask is similar to doing a regular task. The main difference
is that you have to choose which file to edit, and you might have to work
with a few different languages to do the task (e.g., HTML and CSS). To
edit a particular file, simply press the number from the "FILES TO EDIT
FOR THIS TASK" list. If the file isn't there, you can always press 'o' to
open the repo or 'fi' to add files to the "FILES TO EDIT" list.

The only other things that are quite different are (1) your work is
deleted from the repo (Revuu executes 'git reset --hard' for you) so that
you maintain a "clean tree," something needed for Git to work properly. A
copy of your most recent attempt is, however, saved in an archive. Also,
(2) when you press 'r' to run, Revuu runs whatever commands you told it
to run in setting up the repotask. If you need to edit those commands (not
an uncommon thing), press 'c' for commands.

Doing everything else--saving a review, configuring language, editing
instructions, etc.--works the same as with regular tasks.
DOREPOTASK
      },
      {
        title: "why are repotasks (and Git) necessary?",
        content: <<-REPOSNEC
Repotasks are necessary because most of the more advanced programming
tasks involve multiple interacting files (and media and databases and
APIs). The most obvious example of this are modern websites, which use
HTML, CSS, and JavaScript.

The cool thing about Revuu and repotasks is that they actually enable you
to repeatedly practice relatively complex tasks without setting up a
complex context again and again--Revuu does that for you, once you've set
up the question once. Now you have a way to ensure you won't forget the
fiddly little details of CSS and other complex programming tasks.

Git is necessary to manage the many versions of a repo that you'll want to
add in order to make many questions about some tech. Revuu handles all the
complexity of managing Git branches for you; all you have to do is make
sure you keep your tree "clean," i.e., decide whether to commit a change
to a branch or else reset it.
REPOSNEC
      }
    ]
  end
end
