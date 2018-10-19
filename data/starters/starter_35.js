function checkScope() {
"use strict";
  if (true) {
    console.log("i is: ", i);
  }
  console.log("i is: ", i);
  return i;
}
checkScope();
