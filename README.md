# revuu
A new kind of learning tool for programming, Revuu makes it unusually easy and
fun to review coding tasks. You can create practical (how-to) programming
questions, auto-creating and keeping track of answer files, running your
answers in-app, scheduling reviews automatically, etc.

## User introduction

See https://www.youtube.com/watch?v=Mgrdg1uwDeA for the how and why of Revuu.

This is the only tool we know of that makes it easy to drill your own hand-made,
complex web development tasks (such as Rails tasks) repeatedly, handling all the
set-up, scheduling, file naming, retrieving, opening with your text editor,
opening a console at the right place, saving, git branch management, and running
for you. You can focus on the coding challenge you want to learn.

The basic functions of the program are adding tasks, opening the needed files
with your favorite text editor, running the script and seeing the results, and
recording that you've done a review and that the next review should be done on a
certain date.

Currently, we support Ruby, Rails, JavaScript (and Node), HTML, CSS, Python,
Java, C, C++, Rust, and Bash scripting. We support not just one-file scripting
tasks but also complex, directory-based tasks (which Revuu calls "repotasks"),
coordinating both edits to multiple files and also with console commands.

Add copious, well-chosen tags in order to be able to sort tasks. Sort tasks in
different ways. Change all task dates at once. Easily import (load) and export
(archive, back up, share) your data.

Try it! You can experiment with some included sample data.

## Install and requirements
Clone the repo (instructions should be clear enough from Github). A recent
version of Ruby (>2.2) is installed. Execute `bundle install` to install the
gem requirements. If you want to run a console automatically, you'll need xterm.

Only tested on Ubuntu and modern Macs, but should work in any \*nix-based
system. Won't work in Windows (sorry).

## Run and Use
Once Ruby, the app, and the gem dependencies are installed, you should be able
to start the app from the directory you installed it in just by typing `ruby revuu.rb` on the command line.

Revuu ships with a bunch of pre-made questions (in the "sample data" folder) and
answers by way of demonstration. Load by pressing 'a' to go to the archive
system, and then 'sa' to copy the sample data. Then press 'l' to load, and
choose the sample data.

To learn how to use the system, press '?' for help. It's pretty easy to learn,
and we have extensive help files.

## Author
Larry Sanger (email is domain sanger.io, username larry)

I'd love to have some detailed feedback. I've had very little so far (as of
January 2019).

## Development to do list

* Full text search with sorting by relevance score.
* Make various archive safety improvements/clarifications.
* Add statistics (number of questions, average review interval, average score,
average score per language, number to do today, etc.).

## Programmer notes

If Rubyists want to help out, I'd be very happy.

## Version notes

### 1.0 (September 27, 2018)
First published version:

Features include new tasks, list all tasks, delete task, sort by tags, and
various user and programmer documentation. There are several features related
to answering/reviewing tasks: saving a new review (including date and score),
writing an answer using a (one supported) text editor, running the answer
(using at the options of Ruby, Node.js, Java, C, Bash scripting, and text;
including both compiled and interpreted languages), archiving old answers, and
running old answers. From the same screen, the user can edit task instructions,
tags, date of next review, and user's current score. Task, review, and settings
data are all saved in JSON files.

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
Finished big refactoring of Task and TaskList classes:

Finished refactoring class `Task`. Renamed `helpers/` to `lib/`. Included
`TaskController` and `TaskView` in class `Task`, so they're no longer globals.
Fixed bugs and rendered UX more consistent. Should be ready to start work on
directory-based tasks!

### 3.1 (November 19, 2018)
Added Repotasks:

Big update. Introduced the rather massive new Repotask feature. Created
RepotaskFactory, the model, controller, and view files for Repotasks, and in
general made it possible to make questions based on entire directory-based
repositories, and git branches thereof. Also made instructions for repotask
system. Fixed various bugs; there are probably still a few, but the new
feature is pretty stable.

### 3.2 (November 23, 2018)
Colorize and migrate files to deep locations:

Added color-coding of languages. Added HTML, CSS, C++, and Rust. Moved answers,
old answers, and starter code into sub-sub-etc.-folders that support up to
100,000 different tasks in the same collection. Changed the logic to create
these new folders as needed and locate the files where they are buried deep.
Created a data migration script for people who have existing data; this was
extensively tested and should work flawlessly (worked flawlessly for me) behind
the scenes. Replaced Colorize gem (with the help of our first pull request,
thanks to githubcyclist!) with a few methods now at the end of `helpers.rb`.
Squashed many bugs associated with all these changes; few left.

### 3.3 (November 29, 2018)
Review history, view/run old repotask code, new video:

Added review history, making it easy to find tasks you reviewed recently.
Added the ability to view and run old, archived repotask code--very complex.
Deciding it was easy to support less colorful terminals, I made the code use
the more limited Colorize gem (which I had briefly removed) for terminals of
which `$COLORTERM` != 'truecolor'. Let user review deleted task before deleting.
Made and uploaded new helper video: https://www.youtube.com/watch?v=Mgrdg1uwDeA

### 3.4 (December 15, 2018)
Improved sorting and searching:

Added sorting of tasks by ID (date added) and average score. Display history of
reviews (in task view). Allowed partial (and regex) search of tags. Added
Bootstrap to supported tech. Small bug fixes.

### 3.5 (January 6, 2019)
Server running support and auto-advance:

In this extensive update, incredibly (to Revuu's author), a major bug was fixed.
Now the user can run Sinatra servers from within Revuu. This is a major step
toward enabling spaced repetition review of questions about complex web
frameworks--enabling the user to efficiently drill harder methods while Revuu
handles the complex setup. Be sure to add

    BUNDLE_GEMFILE='./Gemfile' &&

before the `ruby <server_file.rb>` Sinatra command. (Still need to update help
file with these instructions.)

Also we now automatically move the user to the next question to review (after
prompt) after recording a review; also, add an 'x' shortcut to do that directly.
Added search/sort for tasks without tags (other than default tags); type
'notags'. Added simple fix to end-of-year "unknown" date bug. We also added
functionality to ensure that spaced repetition recommendations do not cluster
together on any one day (if there's a cluster building, they fall to one side or
the other depending on which days have the fewest).

### 3.6 (January 22, 2019)
Added Rails, open terminal, and "change dates" feature:

We can now say that it is possible to add Rails repotasks. All Bash commands are
now to be typed in by the user in a special xterm console that pops up when the
user types 'co' (although you can still use "commands to run" if you like). The
console opens in the correct repo directory, at the correct branch, and reset
with the correct environment. Also added "change dates" feature, which edits all
task review dates by a day offset. Now, if you get behind, you can use this
feature to catch yourself up.

### 3.7

Add option to open terminal in all regular tasks (not just repotasks).
