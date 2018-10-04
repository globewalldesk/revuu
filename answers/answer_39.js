const FUN_OBJECT = {
  name: 'George',
  favorite_activity: 'being held and cuddled by the abominable snowman'
}
console.log(FUN_OBJECT.name + "'s favorite activity is " + FUN_OBJECT.favorite_activity + ".");
Object.freeze(FUN_OBJECT);
FUN_OBJECT.favorite_activity = 'bowling';
console.log(FUN_OBJECT.name + "'s favorite activity is still " + FUN_OBJECT.favorite_activity + ".");
