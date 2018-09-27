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
The only supported text editor for now is Sublime Text but more will be added
soon.

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
