const eddie = {name: 'Edward William Sanger', age: 7, sex: 'male'};
console.log("Name: " + eddie.name);
console.log("Age: " + eddie.age);
console.log("Sex: " + eddie.sex);
console.log("Making change...")
eddie.age = 8;
Object.freeze(eddie);
console.log("Name: " + eddie.name);
console.log("Age: " + eddie.age);
console.log("Sex: " + eddie.sex);
console.log("Attempting another change...");
eddie.age = 9;
console.log("Results:");
console.log("Name: " + eddie.name);
console.log("Age: " + eddie.age);
console.log("Sex: " + eddie.sex);
