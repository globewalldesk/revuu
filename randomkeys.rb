def gen_key
  str = ''
  2.times { str += [*('a'..'z')].sample }
  4.times { str += rand(10).to_s}
  str
end

def gen_val
  rand(10000)
end

def gen_hash
  h = {}
  20.times { key = gen_key.to_sym; val = gen_val; h[key] = val }
  h
end

p gen_hash

gen_hash += {foo: :bar}
p gen_hash
