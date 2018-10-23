letters = [*('a'..'g')]
letters.map! {|l| l.next}
p letters
