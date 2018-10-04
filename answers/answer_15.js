var arr = ['99', '23a', 'xyz'];

arr.forEach(x => 
  console.log(x + (isNaN(x) ? " is not " : " is ") + "numeric.") );