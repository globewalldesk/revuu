var johnDoe = {};
johnDoe.firstName = 'John';
johnDoe.lastName = 'Doe';
johnDoe.greet = function() {
  console.log("Hi, I'm " + this.firstName + " " + this.lastName + ".");
}

johnDoe.greet();
