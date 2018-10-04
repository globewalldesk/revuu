const UNTOUCHABLE = ['a', 'b', 'c'];
try {
  UNTOUCHABLE = [1,2,3];
} catch(err) {
  console.log("Oops: " + err);
}
[0,1,2].forEach(x => UNTOUCHABLE[x] = x + 1);
console.log(UNTOUCHABLE);