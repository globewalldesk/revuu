const TEACHER = 'Dr. Sanger'
const GRADE = 'A'
const STUDENTS = ['Albert', 'Bertha', 'Candy']

let grade = (x => console.log(TEACHER + " gave " + x + " an " + GRADE));

let stu = 'Albert';
grade(stu);
stu = 'Bertha';
grade(stu);
stu = "Candy";
grade(stu);
try {
  TEACHER = 'Mr. Rogers';
} catch(err) {
  console.log("Ugh, that didn't work: " + err + "\n");
}



//////////////////////////////////////////////////////////////////////////


