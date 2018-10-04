function show_habits() {
  const SOLID = 'brush teeth';
  let habits = ['exercise', 'shower', 'call Mom'];
  let habit = 'exercise';
  let last = habits.reduce(function(acc, habit) {
    console.log("Today I guess I will skip this habit: " + habit);
    return habit;
  });
  habit = last;
  console.log("The last habit I skipped was this: " + habit);
  console.log("I never skip this: " + SOLID)
  try {
    SOLID = 'brush teeth in evening';
    console.log("I tried to skip this: " + SOLID);
  } catch(err) {
    console.log("I couldn't skip this: " + SOLID);
    console.log("I got this error: " + err); 
  }
}

show_habits();