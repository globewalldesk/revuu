# revuu
Spaced repetition-like command line app for reviewing tasks, not declarative
knowledge--mostly for learning programming.

## User introduction

This app will help you review complex tasks. It was written with the notion
that programmers (and others) need repetition of not declarative but procedural
knowledge.

So when you perform a review, you don't try to answer a question in words.
Instead, you try to perform a task. Essentially, to use Revuu, you'd add
complex, not simple, tasks. Probably the ideal Revuu task would require
2-10 minutes to complete.

To record the fact that you've reviewed a task on a certain date, and given
yourself a certain score, enter the task ID number and then press 's'.

If you use Revuu to study programming, you can use the 'answer' feature for
supported languages. (Non-programmers should choose the "Other" option for the
language). This will enable you to use your code editor of choice to input an
answer (with the answer easily accessible right from the task display view) and
to run it with supported interpreters and compilers (also right from the task
display view).

Currently, we support Ruby, Node.js (JavaScript), Java, C, and Bash scripting.
We also support many commonly-used text editors and IDEs.

Add copious, well-chosen tags in order to be able to sort tasks.

Revuu ships with a bunch of pre-made questions by way of demonstration. You
can delete these and make your own, if you like.

Revuu has other features you'd expect such as editing of various fields.

## Install and requirements
Clone the repo into a new directory. Make sure a recent version of Ruby (>2.2)
is installed. The app doesn't use a Gemfile yet (!), so you'll have to install
two gems by hand: `gem install colorize` and `gem install chronic`.

Only works on \*nix systems. I might be able to get it to work on Windows if
anybody cares.

## Run
Once Ruby, the app, and the gem dependencies are installed, you should be able
to start the app on your \*nix system just by typing `ruby revuu.rb`.

## Use
The app ships with both tasks (mostly Ruby) and answers. The tasks are in
data/revuu.json, and, if you didn't want to delete them all by hand, you could
simply delete the data file and the app should still work.

Note that for now, the only text editor that Revuu's [r]un command now supports
is Sublime Text. I'll add more text editors soon.

Online help is available by pressing 'c' for 'commands'.

## Planned/hoped-for features.

* Add starter code (for user to edit in his answer) rather than putting this
directly in the instructions. Ensure that, as with Java now, unedited starter
code is not interpreted as an answer (so it won't overwrite the archive).
* Maybe change task and tag editing from Pico to the default text editor.
* Maybe add an actual spaced repetition option.
* As the test dataset grows well beyond 10, add pagination related features.
* Add statistics (number of questions, averages, number overdue, number to do
today, etc.).
* Give user option to append language to the title automatically.
* Add language to tag list.
* Alternatively, maybe, allow users to have different accounts/sections sorted
by languages.
* Maybe eventually allow users to save archived items individually, and give
them an easy way to browse and run them from within the app.

## Version notes

### 1.0 (September 27, 2018)

First published version. Features include new tasks, list all tasks, delete
task, sort by tags, and various user and programmer documentation. There are
a great many features related to answering/reviewing tasks: saving a new
review (including date and score), writing an answer using a (one supported)
text editor, running the answer (using at the options of Ruby, Node.js, Java,
C, Bash scripting, and text; including both compiled and interpreted
languages), archiving old answers, and running old answers. From the same
screen, the user can edit task instructions, tags, date of next review, and
user's current score. Task, review, and settings data are all saved in JSON
files.

### 1.1 (September 28, 2018)
Added support for Atom, Eclipse, Pico, Nano, Vi, Vim, and other text editors.
This checks the user's system to see which are available and shows only those.
The app now checks that the settings file exists, pre-populates it with
defaults if not, and makes some other improvements to settings. Also added a
simple 'refresh' function for the task review and edit screen.
