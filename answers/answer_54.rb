hashy = {}
[*('a'..'z')].each_with_index {|l,i| hashy[l.to_sym] = i + 1}
puts hashy.inspect
hashy = hashy.select {|k,v| v%3 == 0}
puts hashy.inspect
puts hashy.keys.inspect
