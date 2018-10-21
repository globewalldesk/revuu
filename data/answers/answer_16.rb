nums = *(1..5)

def printo(arr)
  for n in arr
    print("#{n * 3} ")
  end
end
printo(nums)
puts ''
nums = (1...6).to_a
printo(nums)
puts ''