const BUILDING = {
  name: 'Empire State Building', location: 'New York City'
}
Object.freeze(BUILDING);
console.log(BUILDING.location);
BUILDING.location = 'Palookaville';
console.log(BUILDING.location);