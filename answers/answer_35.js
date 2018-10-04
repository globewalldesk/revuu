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
