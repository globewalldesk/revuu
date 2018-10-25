str = "hxexlxlxox xwxoxrxlxdx"
str2 = ''
str.chars.each_with_index { |e,i| str2 <<  str[i] unless i.odd? }
puts str2