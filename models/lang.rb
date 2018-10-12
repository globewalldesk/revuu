class Lang
  # Should probably go through the "advance planning" phase before daring to
  # change the code--I want to make sure I have all necessarily tasks for
  # performing the switch listed.

  # Also, before switching, I should definitely change to a new branch.

  # Convert lookup_lang_data_from_name_cmd to initialize: get_available_langs
  # assists in creating the various attributes, something like a 'defaults'
  # method, along with assign_language_globals. Instead, there will be one
  # $lang global.

  # So next you'll have to go back and change all of the references to the
  # various language globals.

  # A Lang instance appears to be created on startup (for the global) and also
  # to be edited or created (whatever) whenever the user opens a task for
  # editing. But I'm wondering whether, instead of editing the global (which is
  # handy since I don't have to think about which object is using the info),
  # the TaskController should just save a particular Lang instance with this
  # particular task.

  # solicit_languages_from_user (and the other similar method) is used only by 
  # TaskController, but it should actually be used on startup, outside of the 
  # context of a particular task, to set a bona fide global (which doesn't 
  # change). In any event, this belongs in the Lang class.

  # get_locations should set instance variables instead of globals. Not sure 
  # why these need to be a globals at all. Grep says its used only within the
  # Task model and controller.
end
