activities = Hash.new('fun')
puts activities[:fred]  #=> fun
# This output, because 'fun' in that syntax means the default value for any
# as-yet unknown key, and :fred was an unknown key.
