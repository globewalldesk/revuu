var boo = 'hoo';
function checkScope() {
"use strict";
  let i = 52;
  if (true) {
    let i = 'fun fun';
    console.log("i is: ", i);     // 'fun fun'; Ruby doesn't have block scope.
  }
  console.log("i is: ", i);       // 52
  console.log("boo is " + boo);   // 'hoo'; this is like a Ruby global
  return i;
}
console.log(checkScope());        // '52'



console.log(' ')
//////////////////////////////////////////////////////////////////////////


var j = "fun";
let i = "outside";
console.log("j is " + j);
console.log("i is " + i);
function checkScope() {
"use strict";
  let i = 'function scope';
  console.log("j is " + j);
  if (true) {
    let i = 'block scope'
    console.log("i is in " + i);
  }
  console.log("i is in " + i);
  return i;
}
checkScope();



//////////////////////////////////////////////////////////////////////////


