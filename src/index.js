var Main = require('./Main.purs')

var canvas = document.getElementById('turtleCanvas'),
  context = canvas.getContext('2d');

// set canvas dimensions through js; doing it by css only will stretch the drawing
canvas.setAttribute('width', window.innerWidth);
canvas.setAttribute('height', 400);

// put origin at center
context.translate(canvas.width / 2, canvas.height / 2);

window.Main = Main
Main.main(context)()