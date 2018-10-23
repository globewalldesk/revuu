require_relative 'helpers'
include Helpers
str = <<HERE
This is a long para that should be wrapped. Here's some more ** text that will be wrapped yeah!  Here's some more. Will this
break as well?

This shouldn't be wrapped.
Nor this.
Nor this.

HERE
puts '=' * 29
puts wrap_overlong_paragraphs(str)
