/*
* Demonstrates the use of the GifAnimation library.
* the left animation is looping, the one in the middle 
* plays once on mouse click and the one in the right
* is a PImage array. 
* the first two pause if you hit the spacebar.
*/

import gifAnimation.*;
PImage hombre;
PImage[] animation;

Gif hombredoblado;
boolean pause = false;

public void setup() {
  size(400, 200);
  frameRate(100);
 hombre = loadImage ("hombre.png"); 
  println("gifAnimation " + Gif.version());
  // create the GifAnimation object for playback

  hombredoblado = new Gif(this, "hombre.gif");
  hombredoblado.play();
  hombredoblado.loop();

}

void draw() {
  background(255 );
 // image (hombre,width/2 - hombredoblado.width/2, height / 2 - hombredoblado.height / 2);
 image(hombredoblado, width/3 - hombredoblado.width/2, height / 2 - hombredoblado.height / 2);
if (mousePressed ){
  image(hombredoblado, width/2 - hombredoblado.width/2, height / 2 - hombredoblado.height / 2);
}
 // image(animation[(int) (animation.length / (float) (width) * mouseX)], width - 10 - animation[0].width, height / 2 - animation[0].height / 2);

}
/*
hombre.jump (0)
if toca contorno
hombre.play (),
hombre.ignoreRepeat();
*/

