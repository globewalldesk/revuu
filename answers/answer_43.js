let nums = [3, -25, 0.67, 7, -12.25, 12.25, 12];
nums = nums.
         filter (n => n > 0 && Number.isInteger(n) ).
         map (m => Math.pow(m,2) )

console.log(nums)
