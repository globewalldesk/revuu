let nums = [3, -25, 0.67, 7, -12.25, 12.25, 12];
nums = nums.
  filter(x => x > 0 && Number.isInteger(x)).
  map(x => Math.pow(x, 2));
console.log(nums);