const unchangeable = 'sex';
let changeable = 'weight';
console.log("unchangeable = " + unchangeable + "; " +
  "changeable = " + changeable);
const george = function() {
  console.log("unchangeable = " + unchangeable + "; " +
    "changeable = " + changeable);
  const localc = 'local const';
  let locall = 'local let';
  console.log(localc, "...", locall);
  try {
    localc = 'foo';
  } catch(err) {
    console.log("Uh oh: " + err)
  }
  locall = 'bar';
  console.log(localc, "...", locall);
  changeable = 'I yam a changed variable!'
}
george();
console.log("unchangeable = " + unchangeable + "; " +
  "changeable = " + changeable);
