const arr = ['99', '23a', 'xyz'];
arr.forEach(s => console.log(s + (isNaN(s) ? " is not" : " is") + " numeric." ));