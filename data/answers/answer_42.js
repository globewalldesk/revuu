const factorial = (arr) =>
  arr.reduce((x,y) => x * y)

const arr = [5, 4, 3, 2, 1];
console.log(factorial(arr));