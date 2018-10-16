var j = 'global';
console.log("j is: ", j);

function checkScope() {
"use strict";
  let i = 'function scope';
  if (true) {
    let i = 'block scope';
    console.log("i is: ", i);
  }
  console.log("i is: ", i);
  console.log("j is: ", j);
  j = 'changed in a function';
  console.log("j is: ", j);
  return i;
}
let i = checkScope();
console.log("i is: ", i);
