# revuu
If you are trying to commit a lot of programming techniques to memory, try
it--you'll like it. Revuu gives you one place to make or copy practical (how-to)
programming questions, auto-creating and keeping track of answer files, running
your answers in-app, scheduling reviews automatically, etc.

## User introduction

Revuu helps you review programming tasks, both simple and complex, improving
understanding and keeping your skills fresh. It was written with the notion that
programmers need repetition of not declarative but procedural knowledge.

This is the only tool we know of that makes it easy to drill your own hand-made,
complex web development tasks (such as Rails tasks) repeatedly, handling all the
set-up for you.

The great thing about Revuu is that it handles all file naming, retrieving,
opening with your text editor, saving, git branch management, and running for
you automatically, so you can focus on learning. It's a tremendous time-saver
for drilling coding skills.

When you perform a review, you try to perform a task.  Essentially, to use
Revuu, you'd add complex, not simple, tasks. Probably the ideal Revuu task would
require 2-10 minutes to complete.

The basic functions of the program are adding tasks, using the handy answer
filing and editing system (which probably works with your favorite text editor),
running the script and seeing the results, and recording that you've done a
review and that the next review should be done on a certain date. The two basic
views of the app are a paginated list of tasks and an individual task view.

Currently, we support Ruby, JavaScript (and Node), HTML, CSS, Python, Java, C,
C++, Rust, and Bash scripting. We support not just one-file scripting tasks but
also complex, directory-based tasks (which Revuu calls "repotasks"). We also
support many commonly-used text editors and IDEs.

Add copious, well-chosen tags in order to be able to sort tasks.

Revuu ships with a bunch of pre-made questions (in the "sample data" folder) and
answers by way of demonstration. Load by pressing 'a' to go to the archive
system, and then 'sa' to copy the sample data. Then press 'l' to load, and
choose the sample data.

You can also easily import (load) and export (archive, back up, share) your
data.

## Install and requirements
Clone the repo (instructions should be clear enough from Github). Should
probably make sure a recent version of Ruby (>2.2) is installed. Execute
`bundle install` to install the gem requirements.

Only works on \*nix systems (including modern Macs).

## Run and Use
Once Ruby, the app, and the gem dependencies are installed, you should be able
to start the app on your \*nix system just by typing `ruby revuu.rb`.

To learn how to use the system, press 'h' for help. It's pretty easy to learn,
and we have extensive help files.

## Author
Larry Sanger (yo.larrysanger@gmail.com)

## Development to do list

* Eventually, distribute files into subdirectories of 100 apiece based on IDs.
* Add a "sort by date added" or "sort by ID" feature.
* Make some archive safety improvements/clarifications.
* Add statistics (number of questions, averages, number overdue, number to do
today, etc.).

## Programmer notes

If Rubyists want to help out, I'd be very happy.

In order to make the codebase more maintainable, I did a major refactoring. My
strategy was (1) move the various helper code to "controller" and "view"
modules associated with "models," although the controller and view code are in
modules rather than classes, (2) starting from the basic classes App, TaskList,
and Task, I added a few more classes corresponding to major data-and-method
groupings, such as Lang and Archiv.

## Version notes

### 1.0 (September 27, 2018)
First published version:

Features include new tasks, list all tasks, delete
task, sort by tags, and various user and programmer documentation. There are
several features related to answering/reviewing tasks: saving a new review
(including date and score), writing an answer using a (one supported) text
editor, running the answer (using at the options of Ruby, Node.js, Java, C,
Bash scripting, and text; including both compiled and interpreted languages),
archiving old answers, and running old answers. From the same screen, the user
can edit task instructions, tags, date of next review, and user's current
score. Task, review, and settings data are all saved in JSON files.

### 1.1 (September 28, 2018)
Text editor support:

Added support for Atom, Eclipse, Pico, Nano, Vi, Vim, and other text editors.
This checks the user's system to see which are available and shows only those.
The app now checks that the settings file exists, pre-populates it with
defaults if not, and makes some other improvements to settings. Also added a
simple 'refresh' function for the task review and edit screen.

### 1.2 (October 1, 2018)
Navigation:

Added pagination and page navigation. Data about any persisted tag searches
and navigation page was added as attributes to the global TaskList object. So
the user can navigate to the second page of tasks, view one, quit that view,
and then be placed back on the second page of tasks. If the user starts from
tag search results (even the second page of them), he is returned to that page.
That means users can search for one particular language (or method) without
having to redo the search in between tasks.

### 1.3 (October 6, 2018)
Lots of little improvements:

Automatically inserts language name and variants into tag list. Similarly,
inserts language name in parentheses before the page title, not in the data,
but when the task is rendered to the user. 'x' command shows the "next due"
task to the user. Let user abandon task instead of inputting instructions or
tags. Changed 'Node.js' to 'JavaScript'. Fixed several bugs; now pretty
stable, but badly needs refactoring; started adding notes for doing that.
Now, when a task list is the result of filtering, there is a green message
at the top of the list saying "Filtered by {language name}". Moved gems to
Gemfile and required them via `Bundler.require(:default)`.

### 2.0 (October 10, 2018)
Refactoring and instructions:

The biggest change that justifies the major version number change is that
the code has been completely rearranged into /models, /controllers, and
/views folders, on analogy with web-based MVC development. There is still
quite a bit of refactoring to do, but this is a big enough change to warrant
the new number. In addition, there is now a large, detailed help system
accessible from both task list and task views. There are also a number of
smaller improvements.

### 2.1 (October 15, 2018)
Added spaced repetition and refactored with Lang class:

Added spaced repetition method (which semi-intelligently suggests a next date
for review). Along with other refactoring, surgically extracted the
language-related methods and structures and placed them carefully within a
brand new Lang class. Consequently, user can now change default language, and
it is now a real default. Stopped calling many accessor methods on named
objects in favor of just using instance variables, after confirming that
controllers and views are adequately self-contained; hence the analogy to MVC
code structure is almost complete. Fixed bugs including a problem with the
"date prettifier."

### 2.2 (October 18, 2018)
Added starter code and Python:

Code that a task writer wants the user to use in solving a problem is dubbed
"starter code"; this code was included in the task instructions, but has now
been separated out, so the user doesn't have to copy and paste it from the
question. Also, added Python support. Fixed various bugs, especially a tag bug.

### 2.3 (October 26, 2018)
Archive system and autowrap:

Added fully-functional data archive system with full CRUD functionality, such
as creating new tarballs, loading old ones, showing them, and deleting them.
I make my data available via a new `sample_data/` folder that won't interfere
with your data, if and when you want to pull down the latest, greatest version.
Autowrap overwide text fields and tags (without autowrapping code, hopefully);
debugged this. Made introductory video to get people using Revuu! Moved
`answers/` to `data/answers` (so all data is in the same place now) and renamed
`data/revuu.json` to `data/tasks.json` (so now all data is ready to copy in one
folder). Prepared codebase for clean start (and safe `git pull`ing) by cleaning
out the content of `data/` and encouraging user to use sample data. Also,
experimentally changed (shortened) the spaced repetition intervals, since they
had been too long for me.

### 2.4 (November 1, 2018)
Misc bug fixes and improvements:

Adjusted spaced repetition intervals again. Cleaned up datafile (`tasks.json`),
which had been needlessly saving calculated attributes, reducing file size by
22%. Improvements to UX when adding tasks (allowing user to quit). Finally
fixed three bugs with the wrapping method. Added time to the last reviewed
date. Added # of tags to task view screen. Since my task IDs have entered three
digits, I hid them and replaced them with 0-9 in the task list view.

### 2.5 (November 8, 2018)
Refactored TaskList and new TaskFactory:

Started major refactoring in preparation for the big "directory-based tasks"
feature. Moved main dispatch table to class `TaskList`; removed `$tasks`
references from within `TaskList` class and modules; included
`TasklistController` and `TasklistView` in `TaskList` class; removed global
inclusion from revuu.rb. Fixed very bad (inadvertantly deleted tasks!) bug
introduced when switching to 0-9 in task list view. Thoroughly refactored
`revuu.rb`, settings methods (now located in settings_helper.rb), and added
edge case logic for missing settings. Also refactored `TaskList` class and
both modules, fixing bugs, thereby loading the tasklist instantly (as before),
making the tasklist UX more consistent, etc. Consolidated `Task` class methods,
as well as all methods used in creating new tasks, in a brand new
`task_factory.rb` helper); also, refactored all task-creation methods.

### 3.0 (November 13, 2018)
Finished big refactoring of Task and TaskList classes

Finished refactoring class `Task`. Renamed `helpers/` to `lib/`. Included
`TaskController` and `TaskView` in class `Task`, so they're no longer globals.
Fixed bugs and rendered UX more consistent. Should be ready to start work on
directory-based tasks!

### 3.1 (November 19, 2018)
Added Repotasks

Big update. Introduced the rather massive new Repotask feature. Created
RepotaskFactory, the model, controller, and view files for Repotasks, and in
general made it possible to make questions based on entire directory-based
repositories, and git branches thereof. Also made instructions for repotask
system. Fixed various bugs; there are probably still a few, but the new
feature is pretty stable.

### 3.2

Added color-coding of languages. Added HTML, CSS, and C++. Moved answers, old
answers, and starter code into sub-sub-etc.-folders that support up to
99,999 different tasks in the same collection. Changed the logic to create
these new folders as needed and locate the files where they are buried deep.
Created a data migration script for people who have existing data; this was
extensively tested and should work flawlessly (worked flawlessly for me) behind
the scenes. Added Rust
