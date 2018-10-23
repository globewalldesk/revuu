const Faves = { fruit: 'apple', music: 'Irish trad', prog_lang: 'Ruby' };
//const fruit = Faves.fruit;
//const music = Faves.music;
//const prog_lang = Faves.prog_lang;
const [fruit, music, prog_lang] = [Faves.fruit, Faves.music, Faves.prog_lang];
console.log(fruit, music, prog_lang);
