sightings = [ {bird: 'pigeon', date: '2007/04/16'}, {bird: 'bald eagle', 
  date: '1999/07/23'}, {bird: 'dodo', date: '2001/12/25'}, {bird: 'blue heron', 
  date: '2012/3/1'} ]
sightings.sort! { |x,y| x[:date] <=> y[:date] }
sightings.each { |s| printf("%12s: %-10s\n", s[:bird], s[:date]) }